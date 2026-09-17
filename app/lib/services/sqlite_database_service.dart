import 'dart:convert';
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/journal_models.dart';

class SqliteDatabaseService {
  static const String _dbName = 'harsh_studio.db';
  static const int _dbVersion = 1;

  static Database? _database;
  static bool _ffiInitialized = false;
  static String? customDatabasePath;

  /// Ensure platform-appropriate database factory is ready
  static void _ensureInitialized() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      if (!_ffiInitialized) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        _ffiInitialized = true;
      }
    }
  }

  /// Get or initialize the SQLite database
  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    _ensureInitialized();
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with path and schema
  static Future<Database> _initDatabase() async {
    String dbPath;
    if (customDatabasePath != null) {
      dbPath = customDatabasePath!;
    } else if (kIsWeb) {
      dbPath = _dbName;
    } else {
      try {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          final appDocDir = await getApplicationDocumentsDirectory();
          dbPath = p.join(appDocDir.path, 'HarshStudio', _dbName);
          final file = File(dbPath);
          if (!file.parent.existsSync()) {
            file.parent.createSync(recursive: true);
          }
        } else {
          // Mobile (Android / iOS)
          final databasesPath = await getDatabasesPath();
          dbPath = p.join(databasesPath, _dbName);
        }
      } catch (_) {
        dbPath = inMemoryDatabasePath;
      }
    }

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) async {
        // Enable Foreign Keys for automatic ON DELETE CASCADE
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }


  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // 1. Journals table
    await db.execute('''
      CREATE TABLE journals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        cover_texture TEXT NOT NULL,
        cover_color_value INTEGER NOT NULL,
        accent_color_value INTEGER NOT NULL,
        ribbon_color_value INTEGER NOT NULL,
        default_paper TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Pages table
    await db.execute('''
      CREATE TABLE pages (
        id TEXT PRIMARY KEY,
        journal_id TEXT NOT NULL,
        page_index INTEGER NOT NULL,
        paper_type_override TEXT,
        is_bookmarked INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (journal_id) REFERENCES journals (id) ON DELETE CASCADE
      )
    ''');

    // 3. Elements table (stickers, washi tapes, notes, templates, text)
    await db.execute('''
      CREATE TABLE elements (
        id TEXT PRIMARY KEY,
        page_id TEXT NOT NULL,
        type TEXT NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        json_data TEXT NOT NULL,
        FOREIGN KEY (page_id) REFERENCES pages (id) ON DELETE CASCADE
      )
    ''');

    // 4. Strokes table (vector drawn strokes, pen types, smoothing)
    await db.execute('''
      CREATE TABLE strokes (
        id TEXT PRIMARY KEY,
        page_id TEXT NOT NULL,
        tool_type TEXT NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        json_data TEXT NOT NULL,
        FOREIGN KEY (page_id) REFERENCES pages (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Check if SQLite database currently contains any journals
  static Future<bool> hasJournals() async {
    try {
      final db = await database;
      final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM journals');
      final count = Sqflite.firstIntValue(countResult) ?? 0;
      return count > 0;
    } catch (_) {
      return false;
    }
  }

  /// Load all journals with their nested pages, elements, and strokes
  static Future<List<Journal>> loadAllJournals() async {
    final db = await database;

    // 1. Query all journals
    final journalRows = await db.query('journals', orderBy: 'created_at ASC');
    if (journalRows.isEmpty) return [];

    final List<Journal> journals = [];

    for (final jRow in journalRows) {
      final journalId = jRow['id'] as String;

      // 2. Query pages for this journal
      final pageRows = await db.query(
        'pages',
        where: 'journal_id = ?',
        whereArgs: [journalId],
        orderBy: 'page_index ASC',
      );

      final List<JournalPage> pages = [];

      for (final pRow in pageRows) {
        final pageId = pRow['id'] as String;

        // 3. Query elements for this page
        final elementRows = await db.query(
          'elements',
          where: 'page_id = ?',
          whereArgs: [pageId],
          orderBy: 'order_index ASC',
        );

        final List<PageElement> elements = elementRows.map((eRow) {
          final json = jsonDecode(eRow['json_data'] as String) as Map<String, dynamic>;
          return PageElement.fromJson(json);
        }).toList();

        // 4. Query strokes for this page
        final strokeRows = await db.query(
          'strokes',
          where: 'page_id = ?',
          whereArgs: [pageId],
          orderBy: 'order_index ASC',
        );

        final List<DrawnStroke> strokes = strokeRows.map((sRow) {
          final json = jsonDecode(sRow['json_data'] as String) as Map<String, dynamic>;
          return DrawnStroke.fromJson(json);
        }).toList();

        // Parse paper type override
        PaperType? paperOverride;
        final paperOverrideStr = pRow['paper_type_override'] as String?;
        if (paperOverrideStr != null) {
          paperOverride = PaperType.values.firstWhere(
            (p) => p.name == paperOverrideStr,
            orElse: () => PaperType.dotGrid,
          );
        }

        pages.add(
          JournalPage(
            id: pageId,
            pageIndex: pRow['page_index'] as int,
            paperTypeOverride: paperOverride,
            isBookmarked: (pRow['is_bookmarked'] as int) == 1,
            elements: elements,
            strokes: strokes,
          ),
        );
      }

      journals.add(
        Journal(
          id: journalId,
          title: jRow['title'] as String,
          coverTexture: CoverTexture.values.firstWhere(
            (t) => t.name == jRow['cover_texture'],
            orElse: () => CoverTexture.leather,
          ),
          coverColorValue: jRow['cover_color_value'] as int,
          accentColorValue: jRow['accent_color_value'] as int,
          ribbonColorValue: jRow['ribbon_color_value'] as int,
          defaultPaper: PaperType.values.firstWhere(
            (p) => p.name == jRow['default_paper'],
            orElse: () => PaperType.dotGrid,
          ),
          createdAt: DateTime.tryParse(jRow['created_at'] as String) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(jRow['updated_at'] as String) ?? DateTime.now(),
          pages: pages,
        ),
      );
    }

    return journals;
  }

  /// Save all journals atomically in a single SQLite transaction
  static Future<void> saveAllJournals(List<Journal> journals) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1. Clear existing rows (cascading foreign keys will handle pages, elements, strokes)
      await txn.delete('journals');

      // 2. Insert fresh journals and children
      for (final j in journals) {
        await txn.insert(
          'journals',
          {
            'id': j.id,
            'title': j.title,
            'cover_texture': j.coverTexture.name,
            'cover_color_value': j.coverColorValue,
            'accent_color_value': j.accentColorValue,
            'ribbon_color_value': j.ribbonColorValue,
            'default_paper': j.defaultPaper.name,
            'created_at': j.createdAt.toIso8601String(),
            'updated_at': j.updatedAt.toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (int pIdx = 0; pIdx < j.pages.length; pIdx++) {
          final page = j.pages[pIdx];
          await txn.insert(
            'pages',
            {
              'id': page.id,
              'journal_id': j.id,
              'page_index': pIdx,
              'paper_type_override': page.paperTypeOverride?.name,
              'is_bookmarked': page.isBookmarked ? 1 : 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          for (int eIdx = 0; eIdx < page.elements.length; eIdx++) {
            final elem = page.elements[eIdx];
            await txn.insert(
              'elements',
              {
                'id': elem.id,
                'page_id': page.id,
                'type': elem.type.name,
                'order_index': eIdx,
                'json_data': jsonEncode(elem.toJson()),
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          for (int sIdx = 0; sIdx < page.strokes.length; sIdx++) {
            final stroke = page.strokes[sIdx];
            await txn.insert(
              'strokes',
              {
                'id': stroke.id,
                'page_id': page.id,
                'tool_type': stroke.toolType.name,
                'order_index': sIdx,
                'json_data': jsonEncode(stroke.toJson()),
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
    });
  }

  /// Delete a journal and cascade delete all its pages, elements, and strokes
  static Future<void> deleteJournal(String journalId) async {
    final db = await database;
    await db.delete('journals', where: 'id = ?', whereArgs: [journalId]);
  }

  /// Close database connection
  static Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
