import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/main.dart';
import 'package:app/models/journal_models.dart';
import 'package:app/screens/journal_canvas_screen.dart';
import 'package:app/screens/page_manager_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches and renders Bookshelf on desktop', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ZinnihaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Zinnia Studio'), findsOneWidget);
    expect(find.text('FREE & UNLOCKED'), findsOneWidget);
  });

  testWidgets('JournalCanvasScreen renders on narrow mobile device (360x640) without any overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testJournal = Journal(
      id: 'test-j-1',
      title: 'Creative Journal 2026',
      pages: [
        JournalPage(id: 'page-1', pageIndex: 0),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: JournalCanvasScreen(
          journal: testJournal,
          allJournals: [testJournal],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify top bar title and back button are visible
    expect(find.byTooltip('Return to Bookshelf'), findsOneWidget);
    expect(find.text('Creative Journal 2026'), findsOneWidget);

    // Verify bottom page bar
    expect(find.text('Page 1 of 1'), findsOneWidget);
  });

  testWidgets('PageManagerModal renders on mobile screen (360x640) without any overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testJournal = Journal(
      id: 'test-j-modal',
      title: 'Daily Notes & Goals 2026',
      pages: [
        JournalPage(id: 'page-1', pageIndex: 0),
        JournalPage(id: 'page-2', pageIndex: 1),
        JournalPage(id: 'page-3', pageIndex: 2),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PageManagerModal(
            journal: testJournal,
            currentPageIndex: 0,
            onSelectPage: (_) {},
            onJournalUpdated: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Daily Notes & Goals 2026'), findsOneWidget);
    expect(find.text('Page 1'), findsOneWidget);
    expect(find.text('Page 2'), findsOneWidget);
    expect(find.text('Page 3'), findsOneWidget);
  });
}

