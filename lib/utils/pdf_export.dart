import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../main.dart';
import 'package:intl/intl.dart';

Future<void> exportDreamsToPdf(List<Dream> dreams) async {
  final pdf = pw.Document();
  final dateFormat = DateFormat('yyyy-MM-dd');

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(level: 0, child: pw.Text('My Dreams', style: const pw.TextStyle(fontSize: 28))),
        ...dreams.map((dream) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(dream.title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text(dateFormat.format(dream.date), style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
              if (dream.tags.isNotEmpty)
                pw.Wrap(
                  spacing: 4,
                  children: dream.tags.map((tag) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(tag, style: const pw.TextStyle(fontSize: 10)),
                  )).toList(),
                ),
              pw.SizedBox(height: 6),
              pw.Text(dream.description, style: const pw.TextStyle(fontSize: 14)),
            ],
          ),
        )),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}
