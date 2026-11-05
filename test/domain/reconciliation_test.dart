import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/domain/entities/client.dart';
import 'package:paytrail/domain/entities/milestone.dart';
import 'package:paytrail/domain/entities/payment.dart';
import 'package:paytrail/domain/entities/payment_source.dart';
import 'package:paytrail/domain/entities/project.dart';
import 'package:paytrail/domain/ingest/payment_event.dart';
import 'package:paytrail/domain/ingest/reconciliation.dart';
import 'package:paytrail/domain/money.dart';
import 'package:paytrail/domain/repositories/ledger_repository.dart';

final DateTime kToday = DateTime(2026, 9, 25);

PaymentEvent event({
  String sourceId = SourceIds.fiverr,
  int grossMinor = 100000,
  int? netMinor,
  String currency = 'INR',
  String? externalTxnId = 'FO1',
  DateTime? occurredAt,
  String? clientHint,
  String? projectHint,
  IngestSource channel = IngestSource.statement,
}) {
  return PaymentEvent(
    sourceId: sourceId,
    channel: channel,
    grossAmount: Money(grossMinor, currency),
    netAmount: netMinor == null ? null : Money(netMinor, currency),
    occurredAt: occurredAt ?? kToday,
    externalTxnId: externalTxnId,
    clientHint: clientHint,
    projectHint: projectHint,
    raw: 'raw',
  );
}

MilestoneWithContext candidate({
  String id = 'm1',
  String clientName = 'Acme Studio',
  String? company,
  String? externalRef,
  int grossMinor = 100000,
  int paidMinor = 0,
  int commissionRateBps = 0,
  String currency = 'INR',
  String sourceId = SourceIds.fiverr,
  DateTime? dueDate,
  MilestoneStage stage = MilestoneStage.invoiced,
}) {
  return MilestoneWithContext(
    milestone: Milestone(
      id: id,
      projectId: 'p-$id',
      title: 'Phase $id',
      grossAmount: Money(grossMinor, currency),
      dueDate: dueDate ?? kToday,
      sourceId: sourceId,
      commissionRateBps: commissionRateBps,
      tdsRateBps: 0,
      stage: stage,
      amountPaid: Money(paidMinor, currency),
      createdAt: kToday,
      updatedAt: kToday,
    ),
    project: Project(
      id: 'p-$id',
      clientId: 'c-$id',
      name: 'Project $id',
      defaultSourceId: sourceId,
      defaultCurrency: currency,
      externalRef: externalRef,
      createdAt: kToday,
      updatedAt: kToday,
    ),
    client: Client(
      id: 'c-$id',
      name: clientName,
      company: company,
      createdAt: kToday,
      updatedAt: kToday,
    ),
  );
}

void main() {
  group('dedupeKey', () {
    test('the same payment from three channels shares one key', () {
      // This is the whole point: a notification, an email and a statement row
      // describing one payout must collapse to a single key.
      final PaymentEvent fromNotification =
          event(channel: IngestSource.notification);
      final PaymentEvent fromEmail = event(channel: IngestSource.email);
      final PaymentEvent fromStatement = event(channel: IngestSource.statement);

      expect(fromNotification.dedupeKey, fromEmail.dedupeKey);
      expect(fromEmail.dedupeKey, fromStatement.dedupeKey);
    });

    test('ignores the time of day, which the channels disagree about', () {
      expect(
        event(occurredAt: DateTime(2026, 9, 25, 2)).dedupeKey,
        event(occurredAt: DateTime(2026, 9, 25, 23)).dedupeKey,
      );
    });

    test('is case-insensitive on the transaction id', () {
      expect(
        event(externalTxnId: 'FO1').dedupeKey,
        event(externalTxnId: 'fo1').dedupeKey,
      );
    });

    test('distinguishes genuinely different payments', () {
      final PaymentEvent base = event();
      expect(base.dedupeKey, isNot(event(grossMinor: 100001).dedupeKey));
      expect(base.dedupeKey, isNot(event(currency: 'USD').dedupeKey));
      expect(base.dedupeKey, isNot(event(externalTxnId: 'FO2').dedupeKey));
      expect(
        base.dedupeKey,
        isNot(event(occurredAt: DateTime(2026, 9, 26)).dedupeKey),
      );
      expect(base.dedupeKey, isNot(event(sourceId: 'upwork').dedupeKey));
    });

    test('two same-day same-amount events with no id collapse together', () {
      // A real limitation, and a deliberate trade: two identical untracked
      // notifications on one day are indistinguishable, and treating them as
      // one is safer than recording money twice.
      expect(
        event(externalTxnId: null).dedupeKey,
        event(externalTxnId: null).dedupeKey,
      );
    });
  });

  group('deduplicate', () {
    test('lets new events through', () {
      final DedupeResult result = deduplicate(
        incoming: <PaymentEvent>[event(externalTxnId: 'A'), event(externalTxnId: 'B')],
        knownKeys: <String>{},
      );
      expect(result.acceptedCount, 2);
      expect(result.duplicateCount, 0);
    });

    test('rejects what has already been recorded', () {
      final PaymentEvent seen = event(externalTxnId: 'A');
      final DedupeResult result = deduplicate(
        incoming: <PaymentEvent>[seen, event(externalTxnId: 'B')],
        knownKeys: <String>{seen.dedupeKey},
      );

      expect(result.acceptedCount, 1);
      expect(result.duplicates.single.reason, 'Already recorded');
    });

    test('catches a duplicate inside one file', () {
      // Re-downloading an overlapping date range is the likeliest way to
      // double-import, so the batch is screened against itself too.
      final DedupeResult result = deduplicate(
        incoming: <PaymentEvent>[
          event(externalTxnId: 'A'),
          event(externalTxnId: 'A'),
        ],
        knownKeys: <String>{},
      );

      expect(result.acceptedCount, 1);
      expect(result.duplicates.single.reason, 'Appears twice in this file');
    });

    test('an empty batch is not an error', () {
      final DedupeResult result =
          deduplicate(incoming: <PaymentEvent>[], knownKeys: <String>{'x'});
      expect(result.acceptedCount, 0);
      expect(result.duplicateCount, 0);
    });
  });

  group('suggestMatches', () {
    test('a project reference match outranks everything else', () {
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(projectHint: 'FO-ORDER-9', grossMinor: 999),
        candidates: <MilestoneWithContext>[
          candidate(id: 'wrong', grossMinor: 100000),
          candidate(id: 'right', externalRef: 'FO-ORDER-9', grossMinor: 500000),
        ],
      );

      expect(matches.first.candidate.milestone.id, 'right');
      expect(matches.first.reasons, contains('Project reference matches FO-ORDER-9'));
    });

    test('an exact outstanding balance is strong evidence', () {
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(externalTxnId: null, grossMinor: 60000),
        candidates: <MilestoneWithContext>[
          candidate(id: 'partial', grossMinor: 100000, paidMinor: 40000),
          candidate(id: 'other', grossMinor: 250000),
        ],
      );

      expect(matches.first.candidate.milestone.id, 'partial');
      expect(
        matches.first.reasons,
        contains('Settles the outstanding balance exactly'),
      );
    });

    test('matches the net amount on a commissioned milestone', () {
      // A Fiverr payout of 800 against a 1,000 milestone at 20%.
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(grossMinor: 80000, externalTxnId: null),
        candidates: <MilestoneWithContext>[
          candidate(id: 'fiverr', grossMinor: 100000, commissionRateBps: 2000),
        ],
      );
      expect(matches, isNotEmpty);
      expect(
        matches.first.reasons,
        contains('Settles the outstanding balance exactly'),
      );
    });

    test('a client name match counts, across spelling differences', () {
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(clientHint: 'acme_studio', externalTxnId: null),
        candidates: <MilestoneWithContext>[
          candidate(id: 'acme', clientName: 'Acme Studio', grossMinor: 777),
        ],
      );
      expect(matches.first.reasons, contains('Client name matches Acme Studio'));
    });

    test('very short names are not treated as evidence', () {
      // "Co" would otherwise match half the ledger.
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(clientHint: 'Co', externalTxnId: null, grossMinor: 777),
        candidates: <MilestoneWithContext>[
          candidate(id: 'x', clientName: 'Co', grossMinor: 100000),
        ],
      );
      expect(
        matches.where((MatchSuggestion m) =>
            m.reasons.any((String r) => r.startsWith('Client name'))),
        isEmpty,
      );
    });

    test('never suggests a milestone in another currency', () {
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(currency: 'USD', grossMinor: 100000),
        candidates: <MilestoneWithContext>[
          candidate(id: 'inr', currency: 'INR', grossMinor: 100000),
        ],
      );
      expect(matches, isEmpty);
    });

    test('never suggests settled or cancelled work', () {
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(),
        candidates: <MilestoneWithContext>[
          candidate(id: 'paid', grossMinor: 100000, paidMinor: 100000),
          candidate(id: 'cancelled', stage: MilestoneStage.cancelled),
        ],
      );
      expect(matches, isEmpty);
    });

    test('returns nothing rather than a wild guess', () {
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(
          sourceId: 'upwork',
          externalTxnId: null,
          grossMinor: 3,
          occurredAt: DateTime(2020, 1, 1),
        ),
        candidates: <MilestoneWithContext>[
          candidate(id: 'unrelated', grossMinor: 500000),
        ],
      );
      expect(matches, isEmpty);
    });

    test('a well-evidenced match is marked strong enough to preselect', () {
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(
          projectHint: 'FO-9',
          clientHint: 'Acme Studio',
          grossMinor: 100000,
        ),
        candidates: <MilestoneWithContext>[
          candidate(id: 'm', externalRef: 'FO-9', grossMinor: 100000),
        ],
      );
      expect(matches.first.isStrong, isTrue);
    });

    test('ranks candidates best first', () {
      final List<MatchSuggestion> matches = suggestMatches(
        event: event(clientHint: 'Acme Studio', grossMinor: 100000),
        candidates: <MilestoneWithContext>[
          candidate(id: 'weak', clientName: 'Globex', grossMinor: 90000),
          candidate(id: 'strong', clientName: 'Acme Studio', grossMinor: 100000),
        ],
      );
      expect(matches.first.candidate.milestone.id, 'strong');
      expect(matches.first.score, greaterThan(matches.last.score));
    });
  });
}
