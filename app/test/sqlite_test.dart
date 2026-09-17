import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app/models/journal_models.dart';
import 'package:app/services/sqlite_database_service.dart';
import 'package:app/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await SqliteDatabaseService.close();
  });

  group('SQLite Database Service Tests', () {
    test('SqliteDatabaseService saves and loads journals with pages, elements, and strokes', () async {
      final testJournal = Journal(
        id: 'sql-journal-1',
        title: 'Offline SQLite Diary',
        coverTexture: CoverTexture.leather,
        coverColorValue: 0xFF4A3525,
        accentColorValue: 0xFFD4AF37,
        ribbonColorValue: 0xFF8D6E63,
        defaultPaper: PaperType.dotGrid,
        pages: [
          JournalPage(
            id: 'sql-page-1',
            pageIndex: 0,
            paperTypeOverride: PaperType.lined,
            isBookmarked: true,
            elements: [
              PageElement(
                id: 'sql-elem-1',
                type: ElementType.stickyNote,
                x: 100,
                y: 150,
                width: 200,
                height: 200,
                textContent: 'Offline SQLite Note',
              ),
            ],
            strokes: [
              DrawnStroke(
                id: 'sql-stroke-1',
                toolType: StrokeToolType.fountainPen,
                colorValue: 0xFF2C3E50,
                strokeWidth: 3.5,
                opacity: 0.95,
                points: [
                  StrokePoint(x: 10, y: 10, pressure: 0.8),
                  StrokePoint(x: 50, y: 50, pressure: 0.9),
                ],
              ),
            ],
          ),
        ],
      );


      // Save to SQLite
      await SqliteDatabaseService.saveAllJournals([testJournal]);

      // Verify hasJournals() is true
      final hasData = await SqliteDatabaseService.hasJournals();
      expect(hasData, isTrue);

      // Load from SQLite
      final loaded = await SqliteDatabaseService.loadAllJournals();
      expect(loaded.length, equals(1));
      expect(loaded.first.id, equals('sql-journal-1'));
      expect(loaded.first.title, equals('Offline SQLite Diary'));
      expect(loaded.first.coverTexture, equals(CoverTexture.leather));

      // Verify nested pages
      expect(loaded.first.pages.length, equals(1));
      final loadedPage = loaded.first.pages.first;
      expect(loadedPage.id, equals('sql-page-1'));
      expect(loadedPage.paperTypeOverride, equals(PaperType.lined));
      expect(loadedPage.isBookmarked, isTrue);

      // Verify nested elements
      expect(loadedPage.elements.length, equals(1));
      expect(loadedPage.elements.first.id, equals('sql-elem-1'));
      expect(loadedPage.elements.first.type, equals(ElementType.stickyNote));
      expect(loadedPage.elements.first.textContent, equals('Offline SQLite Note'));

      // Verify nested strokes
      expect(loadedPage.strokes.length, equals(1));
      expect(loadedPage.strokes.first.id, equals('sql-stroke-1'));
      expect(loadedPage.strokes.first.toolType, equals(StrokeToolType.fountainPen));
      expect(loadedPage.strokes.first.points.length, equals(2));

    });

    test('SqliteDatabaseService deletes journal with cascade', () async {
      final j = Journal(
        id: 'sql-to-delete',
        title: 'Delete Me',
        pages: [
          JournalPage(
            id: 'page-del-1',
            pageIndex: 0,
            elements: [
              PageElement(
                id: 'elem-del-1',
                type: ElementType.sticker,
                x: 0,
                y: 0,
                width: 50,
                height: 50,
              ),
            ],
          ),
        ],
      );

      await SqliteDatabaseService.saveAllJournals([j]);
      expect(await SqliteDatabaseService.hasJournals(), isTrue);

      await SqliteDatabaseService.deleteJournal('sql-to-delete');
      final loaded = await SqliteDatabaseService.loadAllJournals();
      expect(loaded.isEmpty, isTrue);
    });

    test('StorageService loads seeded journals offline', () async {
      final journals = await StorageService.loadJournals();
      expect(journals.isNotEmpty, isTrue);
      expect(journals.any((j) => j.title.contains('Creative Journal')), isTrue);
    });
  });
}
