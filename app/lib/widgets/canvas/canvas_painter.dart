import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/journal_models.dart';

class CanvasPainter extends CustomPainter {
  final List<DrawnStroke> strokes;
  final DrawnStroke? activeStroke;

  CanvasPainter({
    required this.strokes,
    this.activeStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    // 2. Draw current active stroke
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }
  }

  void _drawStroke(Canvas canvas, DrawnStroke stroke) {
    if (stroke.points.isEmpty) return;

    if (stroke.isGeometric && stroke.geometricShape != null) {
      _drawGeometricShape(canvas, stroke);
      return;
    }

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = stroke.toolType == StrokeToolType.highlighter
          ? StrokeCap.square
          : StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.toolType == StrokeToolType.highlighter) {
      paint.blendMode = BlendMode.darken;
    }

    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points.first.toOffset(), stroke.strokeWidth / 2, paint..style = PaintingStyle.fill);
      return;
    }

    if (stroke.toolType == StrokeToolType.fountainPen) {
      _drawFountainPen(canvas, stroke);
      return;
    }

    // Draw smooth quadratic bezier path through midpoints
    final path = Path();
    final firstPoint = stroke.points[0].toOffset();
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < stroke.points.length - 1; i++) {
      final p0 = stroke.points[i].toOffset();
      final p1 = stroke.points[i + 1].toOffset();
      final midPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    final lastPoint = stroke.points.last.toOffset();
    path.lineTo(lastPoint.dx, lastPoint.dy);

    canvas.drawPath(path, paint);
  }

  void _drawFountainPen(Canvas canvas, DrawnStroke stroke) {
    for (int i = 0; i < stroke.points.length - 1; i++) {
      final p1 = stroke.points[i];
      final p2 = stroke.points[i + 1];

      final dist = (Offset(p2.x, p2.y) - Offset(p1.x, p1.y)).distance;
      // Faster stroke -> slightly thinner, slower -> richer ink
      final dynamicWidth = (stroke.strokeWidth * (1.2 - (dist / 40).clamp(0.0, 0.7))) * p1.pressure;

      final segmentPaint = Paint()
        ..color = stroke.color
        ..strokeWidth = math.max(1.0, dynamicWidth)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(p1.toOffset(), p2.toOffset(), segmentPaint);
    }
  }

  void _drawGeometricShape(Canvas canvas, DrawnStroke stroke) {
    final pts = stroke.points;
    if (pts.length < 2) return;

    final start = pts.first.toOffset();
    final end = pts.last.toOffset();

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (stroke.geometricShape) {
      case 'line':
        canvas.drawLine(start, end, paint);
        break;
      case 'rectangle':
        final rect = Rect.fromPoints(start, end);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);
        break;
      case 'circle':
        final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
        final radiusX = (end.dx - start.dx).abs() / 2;
        final radiusY = (end.dy - start.dy).abs() / 2;
        canvas.drawOval(Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2), paint);
        break;
      case 'triangle':
        final top = Offset((start.dx + end.dx) / 2, math.min(start.dy, end.dy));
        final bottomLeft = Offset(math.min(start.dx, end.dx), math.max(start.dy, end.dy));
        final bottomRight = Offset(math.max(start.dx, end.dx), math.max(start.dy, end.dy));
        final triPath = Path()
          ..moveTo(top.dx, top.dy)
          ..lineTo(bottomRight.dx, bottomRight.dy)
          ..lineTo(bottomLeft.dx, bottomLeft.dy)
          ..close();
        canvas.drawPath(triPath, paint);
        break;
      case 'arrow':
        canvas.drawLine(start, end, paint);
        final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
        const arrowLength = 18.0;
        const arrowAngle = 0.5;
        final p1 = end - Offset(math.cos(angle - arrowAngle) * arrowLength, math.sin(angle - arrowAngle) * arrowLength);
        final p2 = end - Offset(math.cos(angle + arrowAngle) * arrowLength, math.sin(angle + arrowAngle) * arrowLength);
        canvas.drawLine(end, p1, paint);
        canvas.drawLine(end, p2, paint);
        break;
      default:
        canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}

class ShapeRecognizer {
  /// Analyzes a drawn stroke and returns a recognized geometric shape if it matches
  static String? detectShape(List<StrokePoint> points) {
    if (points.length < 8) return null;

    final start = points.first.toOffset();
    final end = points.last.toOffset();
    final directDistance = (end - start).distance;

    double pathLength = 0;
    for (int i = 0; i < points.length - 1; i++) {
      pathLength += (points[i + 1].toOffset() - points[i].toOffset()).distance;
    }

    if (pathLength < 30) return null;

    // 1. Straight Line Check: path length close to direct line distance
    if (directDistance / pathLength > 0.88) {
      return 'line';
    }

    // 2. Closed Loop Check: start is very close to end
    final isClosed = directDistance < 45 || (directDistance / pathLength < 0.25);

    if (isClosed) {
      // Find bounding box
      double minX = points.first.x, maxX = points.first.x;
      double minY = points.first.y, maxY = points.first.y;

      for (final p in points) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }

      final boxWidth = maxX - minX;
      final boxHeight = maxY - minY;
      final boxArea = boxWidth * boxHeight;
      if (boxArea < 400) return null;

      final aspectRatio = boxWidth / boxHeight;

      // Approximate Circle vs Rectangle:
      // Perimeter of circle: pi * d ~ 3.14 * width
      // Perimeter of rect: 2 * (w + h)
      final expectedCirclePerimeter = math.pi * ((boxWidth + boxHeight) / 2);
      final circleRatio = pathLength / expectedCirclePerimeter;

      if (circleRatio > 0.80 && circleRatio < 1.30 && aspectRatio > 0.65 && aspectRatio < 1.5) {
        return 'circle';
      }

      // Check if it resembles a rectangle
      return 'rectangle';
    }

    return null;
  }
}
