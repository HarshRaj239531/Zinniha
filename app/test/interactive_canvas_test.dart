import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/journal_models.dart';
import 'package:app/widgets/canvas/interactive_canvas.dart';

void main() {
  testWidgets('InteractiveCanvas renders without overflow on 360x640 mobile screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final page = JournalPage(id: 'p1', pageIndex: 0);
    final page2 = JournalPage(id: 'p2', pageIndex: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InteractiveCanvas(
            page: page,
            secondPage: page2,
            isDoubleSpread: true,
            paperType: PaperType.dotGrid,
            currentTool: StrokeToolType.pen,
            currentColor: Colors.black,
            currentStrokeWidth: 3.0,
            currentOpacity: 1.0,
            onStrokeCompleted: (_) {},
            onStrokesUpdated: (_) {},
            onElementsUpdated: (_) {},
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
