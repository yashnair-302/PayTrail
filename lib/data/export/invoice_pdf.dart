import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/formatting.dart';
import '../../domain/export/income_report.dart';
import '../../domain/money.dart';
import '../../domain/money_bag.dart';

/// Renders invoices and client statements to PDF.
///
/// Layout only — every figure is computed in the domain layer and handed over
/// ready to print. Keeping the arithmetic out of the renderer is what lets the
/// same numbers appear on the invoice, the statement and the CSV without three
/// chances to disagree.
class InvoicePdf {
  const InvoicePdf();

  /// Base grey, used for rules and secondary text.
  static const PdfColor _ink = PdfColor.fromInt(0xFF1A1A1A);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B6B6B);
  static const PdfColor _rule = PdfColor.fromInt(0xFFDDDDDD);
  static const PdfColor _accent = PdfColor.fromInt(0xFF1F6F5C);

  Future<Uint8List> buildInvoice(InvoiceDocument invoice) async {
    final pw.Document document = pw.Document(
      title: 'Invoice ${invoice.number}',
      author: invoice.businessName,
    );

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 44, 40, 40),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            _invoiceHeader(invoice),
            pw.SizedBox(height: 28),
            _parties(invoice),
            pw.SizedBox(height: 28),
            _lineTable(invoice),
            pw.SizedBox(height: 18),
            _totals(invoice),
            if (invoice.notes != null && invoice.notes!.trim().isNotEmpty) ...[
              pw.SizedBox(height: 28),
              pw.Text(
                'Notes',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: _muted,
                  letterSpacing: 0.6,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(invoice.notes!, style: const pw.TextStyle(fontSize: 10)),
            ],
            pw.Spacer(),
            _footer(invoice),
          ],
        ),
      ),
    );

    return document.save();
  }

  pw.Widget _invoiceHeader(InvoiceDocument invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Text(
              invoice.businessName,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
              ),
            ),
            if (invoice.businessAddress != null)
              pw.Text(
                invoice.businessAddress!,
                style: const pw.TextStyle(fontSize: 9, color: _muted),
              ),
            for (final String line in <String>[
              if (invoice.businessEmail != null) invoice.businessEmail!,
              if (invoice.businessPhone != null) invoice.businessPhone!,
              if (invoice.businessTaxId != null) 'GSTIN/PAN: ${invoice.businessTaxId}',
            ])
              pw.Text(line, style: const pw.TextStyle(fontSize: 9, color: _muted)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: <pw.Widget>[
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: _accent,
                letterSpacing: 2,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(invoice.number, style: const pw.TextStyle(fontSize: 11)),
            pw.SizedBox(height: 8),
            _labelledValue('Issued', formatDate(invoice.issuedOn)),
            _labelledValue('Due', formatDate(invoice.dueOn)),
          ],
        ),
      ],
    );
  }

  pw.Widget _labelledValue(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: <pw.Widget>[
          pw.Text('$label  ', style: const pw.TextStyle(fontSize: 9, color: _muted)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  pw.Widget _parties(InvoiceDocument invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _rule),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            'BILL TO',
            style: pw.TextStyle(fontSize: 8, color: _muted, letterSpacing: 0.8),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            invoice.clientCompany ?? invoice.clientName,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          if (invoice.clientCompany != null)
            pw.Text(
              'Attn: ${invoice.clientName}',
              style: const pw.TextStyle(fontSize: 9, color: _muted),
            ),
          if (invoice.clientAddress != null)
            pw.Text(
              invoice.clientAddress!,
              style: const pw.TextStyle(fontSize: 9, color: _muted),
            ),
          if (invoice.clientEmail != null)
            pw.Text(
              invoice.clientEmail!,
              style: const pw.TextStyle(fontSize: 9, color: _muted),
            ),
        ],
      ),
    );
  }

  pw.Widget _lineTable(InvoiceDocument invoice) {
    return pw.Column(
      children: <pw.Widget>[
        pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _ink, width: 1)),
          ),
          child: pw.Row(
            children: <pw.Widget>[
              pw.Expanded(
                flex: 6,
                child: pw.Text(
                  'DESCRIPTION',
                  style: pw.TextStyle(fontSize: 8, color: _muted, letterSpacing: 0.8),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'DUE',
                  style: pw.TextStyle(fontSize: 8, color: _muted, letterSpacing: 0.8),
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  'AMOUNT',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontSize: 8, color: _muted, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ),
        for (final InvoiceLine line in invoice.lines)
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 9),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _rule)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Expanded(
                  flex: 6,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Text(line.description,
                          style: const pw.TextStyle(fontSize: 10)),
                      if (line.reference != null)
                        pw.Text(
                          'Ref ${line.reference}',
                          style: const pw.TextStyle(fontSize: 8, color: _muted),
                        ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    line.dueDate == null ? '' : formatDate(line.dueDate!),
                    style: const pw.TextStyle(fontSize: 9, color: _muted),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    formatMoney(line.amount),
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget _totals(InvoiceDocument invoice) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 240,
        child: pw.Column(
          children: <pw.Widget>[
            _totalRow('Subtotal', formatMoney(invoice.subtotal)),
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 6),
              height: 1,
              color: _ink,
            ),
            _totalRow(
              'Total due',
              formatMoney(invoice.total),
              emphasise: true,
            ),
            if (invoice.tdsAmount != null) ...<pw.Widget>[
              pw.SizedBox(height: 8),
              // Shown as a note, not deducted: the invoice is raised for the
              // full amount and TDS is the client's statutory withholding
              // against it, which they remit on the freelancer's behalf.
              pw.Text(
                'Of which ${formatMoney(invoice.tdsAmount!)} is expected to be '
                'withheld as TDS.',
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(fontSize: 8, color: _muted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _totalRow(String label, String value, {bool emphasise = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: emphasise ? 11 : 10,
              fontWeight: emphasise ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: emphasise ? 13 : 10,
              fontWeight: emphasise ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _footer(InvoiceDocument invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Container(height: 1, color: _rule),
        pw.SizedBox(height: 8),
        pw.Text(
          'Payment due by ${formatDate(invoice.dueOn)}. '
          'Please quote ${invoice.number} with your remittance.',
          style: const pw.TextStyle(fontSize: 8, color: _muted),
        ),
      ],
    );
  }

  /// A client statement for a date range.
  Future<Uint8List> buildStatement({
    required String businessName,
    required String clientName,
    required IncomeReport report,
    required MoneyBag outstanding,
  }) async {
    final pw.Document document = pw.Document(
      title: 'Statement — $clientName',
      author: businessName,
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 44, 40, 40),
        header: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      'STATEMENT',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: _accent,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.Text(
                      clientName,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: <pw.Widget>[
                    pw.Text(businessName, style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      '${formatDate(report.from)} – ${formatDate(report.to)}',
                      style: const pw.TextStyle(fontSize: 9, color: _muted),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 14),
          ],
        ),
        build: (pw.Context context) => <pw.Widget>[
          if (report.isEmpty)
            pw.Text(
              'No payments were received in this period.',
              style: const pw.TextStyle(fontSize: 10, color: _muted),
            )
          else ...<pw.Widget>[
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: _ink)),
              ),
              child: pw.Row(
                children: <pw.Widget>[
                  _headCell('DATE', 2),
                  _headCell('PROJECT', 4),
                  _headCell('MILESTONE', 4),
                  _headCell('RECEIVED', 2, alignRight: true),
                ],
              ),
            ),
            for (final IncomeRow row in report.rows)
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 7),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: _rule)),
                ),
                child: pw.Row(
                  children: <pw.Widget>[
                    _bodyCell(formatShortDate(row.receivedAt), 2),
                    _bodyCell(row.projectName, 4),
                    _bodyCell(row.milestoneTitle, 4),
                    _bodyCell(
                      formatMoney(row.amountReceived),
                      2,
                      alignRight: true,
                    ),
                  ],
                ),
              ),
          ],
          pw.SizedBox(height: 18),
          _summaryBlock('Received in this period', report.totalReceived),
          pw.SizedBox(height: 6),
          _summaryBlock('Still outstanding', outstanding),
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _headCell(String text, int flex, {bool alignRight = false}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(fontSize: 8, color: _muted, letterSpacing: 0.8),
      ),
    );
  }

  pw.Widget _bodyCell(String text, int flex, {bool alignRight = false}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  /// One total per currency, never a single combined figure.
  pw.Widget _summaryBlock(String label, MoneyBag bag) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 260,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: <pw.Widget>[
                if (bag.isEmpty)
                  pw.Text('—', style: const pw.TextStyle(fontSize: 10))
                else
                  for (final Money amount in bag.amounts)
                    pw.Text(
                      formatMoney(amount),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
