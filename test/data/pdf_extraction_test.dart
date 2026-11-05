import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paytrail/data/ingest/csv_table.dart';
import 'package:paytrail/data/ingest/payment_classifier.dart';
import 'package:paytrail/domain/entities/payment.dart';
import 'package:paytrail/domain/money.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

/// Builds a one-page invoice PDF and returns its bytes.
Future<Uint8List> _invoicePdf() async {
  final pw.Document doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text('INVOICE #INV-2042'),
          pw.Text('Bill to: Acme Studio'),
          pw.Text('For: Website revamp - Phase 2'),
          pw.Text('Amount due: INR 30,000'),
          pw.Text('Payable by 2026-12-10'),
        ],
      ),
    ),
  );
  return Uint8List.fromList(await doc.save());
}

/// Mirrors GmailClient's private PDF reader, so the extraction path is covered
/// without a live mailbox.
String _extractText(Uint8List bytes) {
  final sfpdf.PdfDocument document = sfpdf.PdfDocument(inputBytes: bytes);
  final String text = sfpdf.PdfTextExtractor(document).extractText();
  document.dispose();
  return text;
}

void main() {
  group('PDF invoice extraction', () {
    test('reads the text out of a generated invoice PDF', () async {
      final Uint8List bytes = await _invoicePdf();
      final String text = _extractText(bytes);
      // The extractor emits one token per line; the parsers tolerate that
      // because they match across whitespace, so assert on the tokens.
      expect(text, contains('2042'));
      expect(text, contains('Acme'));
      expect(text, contains('30,000'));
    });

    test('the amount in the PDF is found by the generic parser', () async {
      final String text = _extractText(await _invoicePdf());
      expect(firstAmountIn(text, fallbackCurrency: 'INR'),
          const Money(3000000, 'INR'));
    });

    test('a PDF invoice classifies as owed, with its due date', () async {
      final String text = _extractText(await _invoicePdf());
      final PaymentClassification c = classifyPayment(
        text: text,
        channel: IngestSource.email,
        occurredAt: DateTime(2026, 11, 1),
      );
      expect(c.kind, PaymentKind.owed);
      expect(c.dueDate, DateTime(2026, 12, 10));
    });
  });
}
