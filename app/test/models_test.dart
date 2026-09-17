import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/journal_models.dart';
import 'package:app/widgets/canvas/canvas_painter.dart';

void main() {
  group('Journal Models Test', () {
    test('Journal and PageElement JSON serialization & cloning', () {
      final el = PageElement(
        id: 'el-1',
        type: ElementType.stickyNote,
        x: 150,
        y: 200,
        width: 250,
        height: 250,
        textContent: 'Hello Journal',
        fontFamily: 'Caveat',
        fontSize: 20,
      );

      final json = el.toJson();
      final restored = PageElement.fromJson(json);

      expect(restored.id, 'el-1');
      expect(restored.type, ElementType.stickyNote);
      expect(restored.x, 150);
      expect(restored.textContent, 'Hello Journal');
      expect(restored.fontFamily, 'Caveat');

      final clone = restored.clone('el-clone');
      expect(clone.id, 'el-clone');
      expect(clone.textContent, 'Hello Journal');
      expect(clone.x, 170); // shifted by 20
    });

    test('DrawnStroke serialization and shape recognition', () {
      final stroke = DrawnStroke(
        id: 'stroke-1',
        toolType: StrokeToolType.fountainPen,
        colorValue: 0xFF2B2D42,
        strokeWidth: 4.0,
        opacity: 0.9,
        points: [
          StrokePoint(x: 10, y: 10),
          StrokePoint(x: 20, y: 20),
          StrokePoint(x: 30, y: 30),
          StrokePoint(x: 40, y: 40),
          StrokePoint(x: 50, y: 50),
          StrokePoint(x: 60, y: 60),
          StrokePoint(x: 70, y: 70),
          StrokePoint(x: 80, y: 80),
          StrokePoint(x: 90, y: 90),
        ],
      );

      final json = stroke.toJson();
      final restored = DrawnStroke.fromJson(json);
      expect(restored.id, 'stroke-1');
      expect(restored.toolType, StrokeToolType.fountainPen);
      expect(restored.points.length, 9);

      // Straight line detection
      final recognized = ShapeRecognizer.detectShape(stroke.points);
      expect(recognized, 'line');
    });
  });
}
