import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/journal_models.dart';
import '../widgets/canvas/paper_painter.dart';
import '../widgets/canvas/canvas_painter.dart';

class ExportService {
  /// Renders a JournalPage onto an offscreen canvas and encodes as PNG bytes
  static Future<Uint8List?> exportPageToPng(JournalPage page, {PaperType paperType = PaperType.dotGrid}) async {
    const double width = 1200;
    const double height = 1575;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

    // 1. Draw Paper background
    final paperPainter = PaperPainter(paperType: page.paperTypeOverride ?? paperType);
    paperPainter.paint(canvas, const Size(width, height));

    // 2. Draw Vector strokes (scaled from 800 to 1200)
    final scale = width / 800.0;
    canvas.scale(scale, scale);

    final canvasPainter = CanvasPainter(strokes: page.strokes);
    canvasPainter.paint(canvas, const Size(800, 1050));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  /// Exports the entire journal as a PDF document and opens the print/save preview
  static Future<void> exportJournalToPdf(BuildContext context, Journal journal) async {
    final pdf = pw.Document();

    for (int i = 0; i < journal.pages.length; i++) {
      final page = journal.pages[i];
      final pngBytes = await exportPageToPng(page, paperType: journal.defaultPaper);

      if (pngBytes != null) {
        final pdfImage = pw.MemoryImage(pngBytes);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (pw.Context ctx) {
              return pw.FullPage(
                ignoreMargins: true,
                child: pw.Image(pdfImage, fit: pw.BoxFit.cover),
              );
            },
          ),
        );
      }
    }

    if (context.mounted) {
      await Printing.layoutPdf(
        name: '${journal.title.replaceAll(' ', '_')}.pdf',
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    }
  }

  /// Shows the Export dialog with options for PNG or PDF
  static void showExportDialog(BuildContext context, Journal journal, int currentPageIndex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.file_download_outlined, color: Color(0xFF2A9D8F)),
            const SizedBox(width: 8),
            const Text('Export Journal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your high-resolution export format:',
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF2A9D8F).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.picture_as_pdf, color: Color(0xFF2A9D8F)),
              ),
              title: const Text('Export Entire Journal (PDF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('All ${journal.pages.length} pages ready for print or tablet apps', style: const TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.of(ctx).pop();
                exportJournalToPdf(context, journal);
              },
            ),
            const Divider(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFE07A5F).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.image_outlined, color: Color(0xFFE07A5F)),
              ),
              title: const Text('Export Current Page (PNG)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('Page ${currentPageIndex + 1} as lossless high-res image', style: const TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.of(ctx).pop();
                final pngBytes = await exportPageToPng(
                  journal.pages[currentPageIndex],
                  paperType: journal.defaultPaper,
                );
                if (pngBytes != null && context.mounted) {
                  await Printing.sharePdf(
                    bytes: pngBytes,
                    filename: '${journal.title}_page_${currentPageIndex + 1}.png',
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
