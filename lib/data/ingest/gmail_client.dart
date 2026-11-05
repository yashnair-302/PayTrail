import 'dart:convert';
import 'dart:typed_data';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/ingest/payment_event.dart';
import '../../domain/ingest/payment_source_adapter.dart';
import '../../domain/money.dart';
import 'csv_table.dart';

/// Reads payment notices from the user's Gmail, and sends reminders as the
/// user — only from the platforms for reading, and only reminders the user
/// reviewed for sending.
///
/// The constraints that define this class are enforced rather than promised:
///
/// * **Reading is read-only.** Scanning uses only `gmail.readonly`; the scan
///   path cannot send, delete or modify mail.
/// * **Sending is a separate, opt-in scope.** `gmail.send` is requested at
///   connect time so reminders can go out from the connected mailbox (and land
///   in its Sent folder). It is granted by the user at the consent screen, used
///   only by [sendEmail], and only for a message the user already reviewed and
///   tapped send on. It grants no read of existing mail.
/// * **Sender allowlist in the query itself.** The Gmail search string is built
///   from the adapters' domains, so the server only ever returns platform mail.
///   Messages from anywhere else are never downloaded, not merely ignored.
/// * **The allowlist is checked again on the way out.** Each returned message
///   is re-verified against the adapter's own domains before parsing, so a
///   malformed query or a spoofed display name cannot get a message read.
class GmailClient {
  GmailClient(this._registry);

  /// Read-only. The narrowest Gmail scope that exists; used for scanning.
  static const List<String> scopes = <String>[gmail.GmailApi.gmailReadonlyScope];

  /// Send-only. Granted separately; lets [sendEmail] post as the connected
  /// account without any ability to read existing mail.
  static const List<String> sendScopes = <String>[gmail.GmailApi.gmailSendScope];

  /// Requested together when connecting, so a single consent covers both
  /// scanning (read) and sending reminders (send).
  static const List<String> connectScopes = <String>[
    gmail.GmailApi.gmailReadonlyScope,
    gmail.GmailApi.gmailSendScope,
  ];

  final PaymentSourceRegistry _registry;

  bool _initialised = false;

  /// Prepares the plugin. Safe to call repeatedly.
  ///
  /// [serverClientId] comes from the Google Cloud console and is supplied by
  /// the app at startup rather than hardcoded here, so the OAuth client can be
  /// swapped without touching this file.
  Future<void> initialize({String? clientId, String? serverClientId}) async {
    if (_initialised) return;
    await GoogleSignIn.instance.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
    _initialised = true;
  }

  /// Signs in and requests the read-only scope, prompting the user.
  ///
  /// Returns the account's email so the settings screen can show whose mailbox
  /// is connected — a user must always be able to see that, and revoke it.
  Future<String?> connect() async {
    if (!_initialised) {
      throw StateError('GmailClient.initialize must be called first.');
    }
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google sign-in is not available on this platform.',
      );
    }

    final GoogleSignInAccount account =
        await GoogleSignIn.instance.authenticate(scopeHint: connectScopes);
    final GoogleSignInClientAuthorization authorization =
        await account.authorizationClient.authorizeScopes(connectScopes);
    // Touch the authorization so a refused consent surfaces here rather than at
    // the first sync.
    authorization.authClient(scopes: connectScopes).close();
    return account.email;
  }

  /// Revokes the app's access to the account.
  Future<void> disconnect() async {
    if (!_initialised) return;
    await GoogleSignIn.instance.disconnect();
  }

  /// Returns a client if the scope is already granted, without prompting.
  Future<auth.AuthClient?> _silentClient() async {
    final GoogleSignInAccount? account =
        await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (account == null) return null;
    final GoogleSignInClientAuthorization? authorization =
        await account.authorizationClient.authorizationForScopes(scopes);
    if (authorization == null) return null;
    return authorization.authClient(scopes: scopes);
  }

  /// The Gmail search string: platform senders only, within the window.
  ///
  /// Built from the registry rather than written out, so a new adapter widens
  /// the search automatically and — more importantly — an adapter that is
  /// removed narrows it.
  String buildQuery({
    DateTime? since,
    Set<String> extraSenders = const <String>{},
  }) {
    // The built-in platform domains plus whatever senders the user added, so the
    // request Google answers is already narrowed to the senders in play.
    final List<String> senders = <String>{
      ..._registry.allEmailDomains,
      ...extraSenders.map((String s) => s.trim().toLowerCase()),
    }.where((String s) => s.isNotEmpty).toList()
      ..sort();
    final String fromClause =
        senders.map((String sender) => 'from:$sender').join(' OR ');
    final StringBuffer query = StringBuffer('($fromClause)');
    if (since != null) {
      // Gmail's `after:` takes a date, and is inclusive, so a day is subtracted
      // to avoid missing a message that arrived later on the last sync day.
      final DateTime from = since.subtract(const Duration(days: 1));
      query.write(' after:${from.year}/${from.month}/${from.day}');
    }
    return query.toString();
  }

  /// Reads recent platform mail and returns the payments found in it.
  ///
  /// [since] limits the window; passing the last sync time keeps each run
  /// small. Returns an empty result rather than throwing when the user has not
  /// connected an account.
  Future<IngestResult> fetchPayments({
    DateTime? since,
    int maxMessages = 100,
    Set<String> customSenders = const <String>{},
  }) async {
    final auth.AuthClient? client = await _silentClient();
    if (client == null) {
      return const IngestResult(
        events: <PaymentEvent>[],
        issues: <IngestIssue>[
          IngestIssue(detail: 'No Google account is connected.'),
        ],
      );
    }

    final List<PaymentEvent> events = <PaymentEvent>[];
    final List<IngestIssue> issues = <IngestIssue>[];

    try {
      final gmail.GmailApi api = gmail.GmailApi(client);
      final gmail.ListMessagesResponse listing = await api.users.messages.list(
        'me',
        q: buildQuery(since: since, extraSenders: customSenders),
        maxResults: maxMessages,
      );

      for (final gmail.Message stub in listing.messages ?? <gmail.Message>[]) {
        final String? id = stub.id;
        if (id == null) continue;

        try {
          final gmail.Message full =
              await api.users.messages.get('me', id, format: 'full');
          final EmailMessage? message = _toEmailMessage(full);
          if (message == null) continue;

          // Second lock on the same door: the query should already have
          // excluded everything else, but a parser must never see a message
          // from outside the allowlist.
          final PaymentSourceAdapter? adapter =
              _registry.byEmailDomain(message.senderDomain);
          if (adapter != null) {
            final PaymentEvent? event = adapter.parseEmail(message);
            if (event != null) events.add(event);
          } else if (_matchesCustomSender(message, customSenders)) {
            // A sender the user added by hand: no platform adapter understands
            // its format, so fall back to a generic read of the body — plus any
            // PDF invoice attached, whose text is pulled in and parsed the same
            // way, since a custom sender's amount often lives only in the PDF.
            final String pdfText = await _extractPdfText(api, full);
            final PaymentEvent? event =
                _genericPaymentFrom(message, extraText: pdfText);
            if (event != null) events.add(event);
          }
        } catch (error) {
          issues.add(IngestIssue(detail: 'Could not read a message: $error'));
        }
      }
    } catch (error) {
      issues.add(IngestIssue(detail: 'Could not reach Gmail: $error'));
    } finally {
      client.close();
    }

    return IngestResult(events: events, issues: issues);
  }

  /// Sends a plain-text email as the connected account.
  ///
  /// Used by the reminders flow so a chase goes out from the user's own mailbox
  /// (and appears in its Sent folder) rather than a third-party address. The
  /// message is one the user already reviewed and tapped send on.
  ///
  /// Throws [GmailSendException] if no account is connected with the send scope
  /// granted, so the caller can fall back to opening a mail app. [initialize]
  /// must have been called first (idempotent).
  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    if (!_initialised) {
      throw StateError('GmailClient.initialize must be called first.');
    }
    final auth.AuthClient? client = await _sendClient();
    if (client == null) {
      throw const GmailSendException(
        'Gmail is not connected with send permission. Reconnect Gmail under '
        'Data sources to send reminders from your account.',
      );
    }
    try {
      final gmail.GmailApi api = gmail.GmailApi(client);
      await api.users.messages.send(
        gmail.Message(
          raw: _buildRawMessage(to: to, subject: subject, body: body),
        ),
        'me',
      );
    } finally {
      client.close();
    }
  }

  /// A client authorised for the send scope, without prompting. Null when the
  /// account is not connected or has not granted send.
  Future<auth.AuthClient?> _sendClient() async {
    final GoogleSignInAccount? account =
        await GoogleSignIn.instance.attemptLightweightAuthentication();
    if (account == null) return null;
    final GoogleSignInClientAuthorization? authorization =
        await account.authorizationClient.authorizationForScopes(sendScopes);
    if (authorization == null) return null;
    return authorization.authClient(scopes: sendScopes);
  }

  /// Builds a base64url-encoded RFC 822 message for the Gmail API.
  ///
  /// No `From` header: Gmail stamps the authenticated account, so setting one
  /// would at best be redundant and at worst be rejected. The body is sent as
  /// base64 so a UTF-8 message with long lines needs no escaping.
  static String _buildRawMessage({
    required String to,
    required String subject,
    required String body,
  }) {
    final String encodedBody = _chunk76(base64.encode(utf8.encode(body)));
    final String mime = <String>[
      'To: $to',
      'Subject: ${_encodeHeader(subject)}',
      'MIME-Version: 1.0',
      'Content-Type: text/plain; charset="UTF-8"',
      'Content-Transfer-Encoding: base64',
      '',
      encodedBody,
    ].join('\r\n');
    return base64Url.encode(utf8.encode(mime));
  }

  /// RFC 2047 encodes a header only when it has non-ASCII characters, so plain
  /// subjects stay human-readable in the raw message.
  static String _encodeHeader(String value) {
    final bool ascii = value.runes.every((int r) => r < 128);
    if (ascii) return value;
    return '=?UTF-8?B?${base64.encode(utf8.encode(value))}?=';
  }

  /// Splits a base64 string into 76-character lines, as MIME requires.
  static String _chunk76(String s) {
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < s.length; i += 76) {
      out.write(s.substring(i, i + 76 > s.length ? s.length : i + 76));
      out.write('\r\n');
    }
    return out.toString().trimRight();
  }

  /// Whether [message] is from one of the user's [customSenders].
  ///
  /// A custom sender is matched as a full address when it contains `@`, and
  /// otherwise as a domain — exactly or as a subdomain (`pay.client.com` matches
  /// `client.com`), mirroring how the built-in domain allowlist behaves.
  static bool _matchesCustomSender(
    EmailMessage message,
    Set<String> customSenders,
  ) {
    if (customSenders.isEmpty) return false;
    final String address = message.fromAddress.toLowerCase();
    final String domain = message.senderDomain;
    for (final String raw in customSenders) {
      final String sender = raw.trim().toLowerCase();
      if (sender.isEmpty) continue;
      if (sender.contains('@')) {
        if (address == sender) return true;
      } else if (domain == sender || domain.endsWith('.$sender')) {
        return true;
      }
    }
    return false;
  }

  /// Pulls readable text out of any PDF attachments on [message].
  ///
  /// Text-based PDFs (the invoices apps and accounting tools generate) extract
  /// cleanly; a scanned, image-only PDF has no text layer and yields nothing,
  /// which is handled by returning an empty string rather than failing the whole
  /// sync. Each attachment is fetched by its id — Gmail does not inline
  /// attachment bytes in the message body.
  static Future<String> _extractPdfText(
    gmail.GmailApi api,
    gmail.Message message,
  ) async {
    final String? messageId = message.id;
    if (messageId == null) return '';

    final StringBuffer out = StringBuffer();
    for (final gmail.MessagePart part in _flattenParts(message.payload)) {
      final String filename = (part.filename ?? '').toLowerCase();
      final bool isPdf = part.mimeType == 'application/pdf' ||
          filename.endsWith('.pdf');
      final String? attachmentId = part.body?.attachmentId;
      if (!isPdf || attachmentId == null) continue;

      try {
        final gmail.MessagePartBody body = await api.users.messages.attachments
            .get('me', messageId, attachmentId);
        final String? data = body.data;
        if (data == null) continue;
        final Uint8List bytes = base64Url.decode(base64Url.normalize(data));
        final String text = _pdfBytesToText(bytes);
        if (text.trim().isNotEmpty) out.writeln(text);
      } catch (_) {
        // One unreadable attachment must not sink the rest of the sync.
      }
    }
    return out.toString();
  }

  static String _pdfBytesToText(Uint8List bytes) {
    try {
      final sfpdf.PdfDocument document = sfpdf.PdfDocument(inputBytes: bytes);
      final String text = sfpdf.PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (_) {
      // Encrypted or image-only PDF: nothing to read, not an error.
      return '';
    }
  }

  /// Every part of a MIME tree, flattened, so a nested attachment is reached.
  static List<gmail.MessagePart> _flattenParts(gmail.MessagePart? part) {
    if (part == null) return const <gmail.MessagePart>[];
    final List<gmail.MessagePart> all = <gmail.MessagePart>[part];
    for (final gmail.MessagePart child
        in part.parts ?? const <gmail.MessagePart>[]) {
      all.addAll(_flattenParts(child));
    }
    return all;
  }

  /// A best-effort payment from a sender with no platform adapter: the first
  /// currency amount in the mail (or an attached PDF), dated by when it arrived.
  ///
  /// Deliberately loose — it has no format to rely on. Returning the wrong
  /// figure costs one dismissal in the review queue, where every event lands
  /// before the ledger; returning nothing when there is no amount keeps a plain
  /// "thanks for your email" from becoming a payment.
  static PaymentEvent? _genericPaymentFrom(
    EmailMessage message, {
    String extraText = '',
  }) {
    final String text = '${message.subject}\n${message.body}\n$extraText';
    // Direct clients of Indian freelancers usually pay in INR, so that is the
    // fallback when the mail names an amount without a currency symbol.
    final Money? amount = firstAmountIn(text, fallbackCurrency: 'INR');
    if (amount == null || !amount.isPositive) return null;

    final String sender = message.fromAddress.split('@').first;
    return PaymentEvent(
      sourceId: SourceIds.direct,
      channel: IngestSource.email,
      grossAmount: amount,
      netAmount: amount,
      occurredAt: DateTime(
        message.receivedAt.year,
        message.receivedAt.month,
        message.receivedAt.day,
      ),
      clientHint: sender.isEmpty ? message.senderDomain : sender,
      description: message.subject,
      raw: message.subject,
    );
  }

  /// Flattens a Gmail message into the plain structure the parsers accept.
  EmailMessage? _toEmailMessage(gmail.Message message) {
    final gmail.MessagePart? payload = message.payload;
    if (payload == null) return null;

    String header(String name) {
      for (final gmail.MessagePartHeader h
          in payload.headers ?? <gmail.MessagePartHeader>[]) {
        if ((h.name ?? '').toLowerCase() == name) return h.value ?? '';
      }
      return '';
    }

    final String from = _bareAddress(header('from'));
    if (from.isEmpty) return null;

    final int? millis = int.tryParse(message.internalDate ?? '');
    return EmailMessage(
      id: message.id ?? '',
      fromAddress: from,
      subject: header('subject'),
      body: _extractPlainText(payload),
      receivedAt: millis == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }

  /// `"Fiverr" <no-reply@fiverr.com>` becomes `no-reply@fiverr.com`.
  ///
  /// The display name is discarded before any matching happens: it is
  /// attacker-controlled and matching on it would defeat the allowlist.
  static String _bareAddress(String value) {
    final RegExpMatch? angled = RegExp(r'<([^>]+)>').firstMatch(value);
    final String raw = (angled?.group(1) ?? value).trim().toLowerCase();
    return raw.contains('@') ? raw : '';
  }

  /// Walks the MIME tree for readable text, preferring `text/plain`.
  ///
  /// Marketplace mail is usually multipart with an HTML twin; the plain part is
  /// both easier to regex and free of the markup that would otherwise produce
  /// false amount matches from inline CSS.
  static String _extractPlainText(gmail.MessagePart part) {
    final String? plain = _findPart(part, 'text/plain');
    if (plain != null) return plain;
    final String? html = _findPart(part, 'text/html');
    if (html == null) return '';
    return html
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), ' ')
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String? _findPart(gmail.MessagePart part, String mimeType) {
    if (part.mimeType == mimeType) {
      final String? data = part.body?.data;
      if (data != null) return _decodeBase64Url(data);
    }
    for (final gmail.MessagePart child in part.parts ?? <gmail.MessagePart>[]) {
      final String? found = _findPart(child, mimeType);
      if (found != null) return found;
    }
    return null;
  }

  static String _decodeBase64Url(String data) {
    try {
      return utf8.decode(base64Url.decode(base64Url.normalize(data)));
    } catch (_) {
      return '';
    }
  }
}

/// Thrown by [GmailClient.sendEmail] when the account is not connected with the
/// send scope granted. The reminders flow catches it and falls back to opening
/// the user's mail app, so a missing permission never loses the reminder.
class GmailSendException implements Exception {
  const GmailSendException(this.message);

  final String message;

  @override
  String toString() => message;
}
