import 'package:flutter/material.dart';
import '../../models/journal_models.dart';

class PaperPainter extends CustomPainter {
  final PaperType paperType;

  const PaperPainter({required this.paperType});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Paper Color
    Color bgColor;
    switch (paperType) {
      case PaperType.blank:
        bgColor = const Color(0xFFFAF8F5); // warm ivory
        break;
      case PaperType.dotGrid:
        bgColor = const Color(0xFFFDFCF7); // soft warm paper
        break;
      case PaperType.lined:
        bgColor = const Color(0xFFFDFBF7);
        break;
      case PaperType.squareGrid:
        bgColor = const Color(0xFFFBFBF9);
        break;
      case PaperType.darkDots:
        bgColor = const Color(0xFF1E2229); // slate midnight
        break;
      case PaperType.vintageKraft:
        bgColor = const Color(0xFFEBDCB9); // warm kraft parchment
        break;
      case PaperType.watercolor:
        bgColor = const Color(0xFFF7F5F0);
        break;
    }

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Pattern overlay
    switch (paperType) {
      case PaperType.dotGrid:
        _drawDotGrid(canvas, size, const Color(0xFFB0A89F), 1.2, 26.0);
        break;
      case PaperType.darkDots:
        _drawDotGrid(canvas, size, const Color(0xFF6B7280), 1.2, 26.0);
        break;
      case PaperType.lined:
        _drawLined(canvas, size);
        break;
      case PaperType.squareGrid:
        _drawGrid(canvas, size);
        break;
      case PaperType.vintageKraft:
        _drawKraftTexture(canvas, size);
        _drawDotGrid(canvas, size, const Color(0xFF9E8B6E), 1.0, 26.0);
        break;
      case PaperType.watercolor:
        _drawWatercolorTexture(canvas, size);
        break;
      case PaperType.blank:
        // Clean blank page
        break;
    }

    // 3. Page margin subtle drop shadow or book spine shadow
    final spineShadow = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x18000000), Color(0x00000000)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, 18, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, 18, size.height), spineShadow);
  }

  void _drawDotGrid(Canvas canvas, Size size, Color dotColor, double radius, double spacing) {
    final dotPaint = Paint()
      ..color = dotColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    for (double x = spacing; x < size.width - spacing / 2; x += spacing) {
      for (double y = spacing; y < size.height - spacing / 2; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, dotPaint);
      }
    }
  }

  void _drawLined(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFCFD2D6).withValues(alpha: 0.8)
      ..strokeWidth = 1.0;

    final marginPaint = Paint()
      ..color = const Color(0xFFE5989B).withValues(alpha: 0.6)
      ..strokeWidth = 1.2;

    const topOffset = 60.0;
    const lineSpacing = 28.0;

    for (double y = topOffset; y < size.height - 30; y += lineSpacing) {
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), linePaint);
    }

    // Vertical margin line on left
    canvas.drawLine(const Offset(65, 30), Offset(65, size.height - 30), marginPaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFD3D6DC).withValues(alpha: 0.7)
      ..strokeWidth = 0.9;

    const spacing = 22.0;

    for (double x = spacing; x < size.width - 10; x += spacing) {
      canvas.drawLine(Offset(x, 20), Offset(x, size.height - 20), gridPaint);
    }

    for (double y = spacing; y < size.height - 10; y += spacing) {
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), gridPaint);
    }
  }

  void _drawKraftTexture(Canvas canvas, Size size) {
    // Subtle kraft vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFB08968).withValues(alpha: 0.15),
        ],
        radius: 0.9,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  void _drawWatercolorTexture(Canvas canvas, Size size) {
    final grain = Paint()
      ..color = const Color(0xFFDDBEA9).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), size.width * 0.4, grain);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), size.width * 0.35, grain);
  }

  @override
  bool shouldRepaint(covariant PaperPainter oldDelegate) => oldDelegate.paperType != paperType;
}
