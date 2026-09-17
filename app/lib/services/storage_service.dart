import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_models.dart';

class StorageService {
  static const String _storageKey = 'zinniha_journals_v1';
  static const Uuid _uuid = Uuid();

  static Future<List<Journal>> loadJournals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data == null || data.isEmpty) {
      final seedJournals = _createSeedJournals();
      await saveJournals(seedJournals);
      return seedJournals;
    }

    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((item) => Journal.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      final seedJournals = _createSeedJournals();
      await saveJournals(seedJournals);
      return seedJournals;
    }
  }

  static Future<void> saveJournals(List<Journal> journals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(journals.map((j) => j.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  static List<Journal> _createSeedJournals() {
    // 1. Creative Journal 2026
    final journal1 = Journal(
      id: _uuid.v4(),
      title: 'Creative Journal 2026',
      coverTexture: CoverTexture.leather,
      coverColorValue: 0xFF4A3525, // Deep rich saddle leather
      accentColorValue: 0xFFD4AF37, // Metallic gold foil
      ribbonColorValue: 0xFF8D6E63,
      defaultPaper: PaperType.dotGrid,
      pages: [
        // Page 1: Welcome & Studio spread
        JournalPage(
          id: _uuid.v4(),
          pageIndex: 0,
          paperTypeOverride: PaperType.dotGrid,
          elements: [
            // Top decorative washi tape
            PageElement(
              id: _uuid.v4(),
              type: ElementType.washi,
              x: 180,
              y: 50,
              width: 320,
              height: 44,
              assetKey: 'washi_pastel_floral',
              rotation: -0.04,
              zIndex: 1,
            ),
            // Header Title Text
            PageElement(
              id: _uuid.v4(),
              type: ElementType.text,
              x: 200,
              y: 110,
              width: 380,
              height: 70,
              textContent: 'Welcome to your Creative Space',
              fontFamily: 'Playfair Display',
              fontSize: 26,
              textColor: 0xFF2D3142,
              isBold: true,
              zIndex: 2,
            ),
            // Subtitle
            PageElement(
              id: _uuid.v4(),
              type: ElementType.text,
              x: 200,
              y: 180,
              width: 380,
              height: 60,
              textContent: 'Tactile digital journaling, planning & sketching. 100% free forever.',
              fontFamily: 'Caveat',
              fontSize: 20,
              textColor: 0xFF5C6B73,
              zIndex: 2,
            ),
            // Aesthetic Sticky Note
            PageElement(
              id: _uuid.v4(),
              type: ElementType.stickyNote,
              x: 140,
              y: 260,
              width: 240,
              height: 220,
              assetKey: 'note_butter_yellow',
              textContent: 'Today\'s Affirmation:\n\n"Creativity is intelligence having fun."\n\n- Albert Einstein',
              fontFamily: 'Caveat',
              fontSize: 19,
              textColor: 0xFF3D3A34,
              rotation: -0.05,
              zIndex: 3,
            ),
            // Polaroid Frame with sticker
            PageElement(
              id: _uuid.v4(),
              type: ElementType.polaroid,
              x: 420,
              y: 270,
              width: 220,
              height: 260,
              textContent: 'Morning Coffee & Journaling ✨',
              assetKey: 'sticker_coffee_cup',
              fontFamily: 'Caveat',
              fontSize: 16,
              rotation: 0.06,
              zIndex: 3,
            ),
            // Botanical Sticker
            PageElement(
              id: _uuid.v4(),
              type: ElementType.sticker,
              x: 160,
              y: 520,
              width: 140,
              height: 140,
              assetKey: 'sticker_monstera',
              zIndex: 4,
            ),
            // Planner Badge Sticker
            PageElement(
              id: _uuid.v4(),
              type: ElementType.sticker,
              x: 430,
              y: 560,
              width: 130,
              height: 50,
              assetKey: 'sticker_badge_today',
              zIndex: 4,
            ),
          ],
        ),

        // Page 2: Daily Planner Spread
        JournalPage(
          id: _uuid.v4(),
          pageIndex: 1,
          paperTypeOverride: PaperType.lined,
          elements: [
            PageElement(
              id: _uuid.v4(),
              type: ElementType.template,
              templateType: 'daily_planner',
              x: 120,
              y: 60,
              width: 560,
              height: 640,
              zIndex: 1,
              extraData: {
                'title': 'Daily Focus',
                'priority1': 'Draft new creative concepts',
                'priority2': 'Walk in the park (30 min)',
                'priority3': 'Evening watercolor sketch',
                'waterCups': 4,
              },
            ),
            PageElement(
              id: _uuid.v4(),
              type: ElementType.sticker,
              x: 550,
              y: 60,
              width: 110,
              height: 110,
              assetKey: 'sticker_wildflower',
              rotation: 0.1,
              zIndex: 2,
            ),
          ],
        ),

        // Page 3: Habit Tracker & Mood Spread
        JournalPage(
          id: _uuid.v4(),
          pageIndex: 2,
          paperTypeOverride: PaperType.dotGrid,
          elements: [
            PageElement(
              id: _uuid.v4(),
              type: ElementType.template,
              templateType: 'habit_tracker',
              x: 120,
              y: 60,
              width: 560,
              height: 380,
              zIndex: 1,
              extraData: {
                'habits': [
                  {'name': 'Read 20 pages', 'completed': [true, true, true, false, true, true, false]},
                  {'name': 'Meditate 10 min', 'completed': [true, true, false, true, true, true, true]},
                  {'name': 'Drink 2L Water', 'completed': [true, true, true, true, false, true, true]},
                  {'name': 'Creative sketch', 'completed': [false, true, true, true, true, false, true]},
                ],
              },
            ),
            PageElement(
              id: _uuid.v4(),
              type: ElementType.template,
              templateType: 'mood_tracker',
              x: 120,
              y: 470,
              width: 560,
              height: 240,
              zIndex: 1,
              extraData: {
                'currentMood': 'Ecstatic',
              },
            ),
          ],
        ),
      ],
    );

    // 2. Daily Gratitude & Mindfulness
    final journal2 = Journal(
      id: _uuid.v4(),
      title: 'Mindfulness & Gratitude',
      coverTexture: CoverTexture.botanical,
      coverColorValue: 0xFF2D4B39, // Deep forest sage
      accentColorValue: 0xFFE0C068, // Antique soft gold
      ribbonColorValue: 0xFF81C784,
      defaultPaper: PaperType.vintageKraft,
      pages: [
        JournalPage(
          id: _uuid.v4(),
          pageIndex: 0,
          paperTypeOverride: PaperType.vintageKraft,
          elements: [
            PageElement(
              id: _uuid.v4(),
              type: ElementType.text,
              x: 200,
              y: 80,
              width: 380,
              height: 60,
              textContent: 'Morning Gratitude',
              fontFamily: 'Playfair Display',
              fontSize: 28,
              textColor: 0xFF283618,
              isBold: true,
              zIndex: 1,
            ),
            PageElement(
              id: _uuid.v4(),
              type: ElementType.template,
              templateType: 'gratitude_log',
              x: 140,
              y: 160,
              width: 520,
              height: 400,
              zIndex: 2,
              extraData: {
                'item1': 'Warm morning sunlight through the window',
                'item2': 'Fresh aroma of hand-ground coffee',
                'item3': 'Time to create and write uninterrupted',
              },
            ),
            PageElement(
              id: _uuid.v4(),
              type: ElementType.sticker,
              x: 480,
              y: 560,
              width: 140,
              height: 140,
              assetKey: 'sticker_eucalyptus',
              zIndex: 3,
            ),
          ],
        ),
      ],
    );

    // 3. Idea Canvas & Sketchbook
    final journal3 = Journal(
      id: _uuid.v4(),
      title: 'Ideas & Brainstorming',
      coverTexture: CoverTexture.darkLuxury,
      coverColorValue: 0xFF1E2229, // Charcoal Midnight
      accentColorValue: 0xFFC0C0C0, // Polished silver
      ribbonColorValue: 0xFF90A4AE,
      defaultPaper: PaperType.darkDots,
      pages: [
        JournalPage(
          id: _uuid.v4(),
          pageIndex: 0,
          paperTypeOverride: PaperType.darkDots,
          elements: [
            PageElement(
              id: _uuid.v4(),
              type: ElementType.text,
              x: 180,
              y: 90,
              width: 400,
              height: 60,
              textContent: 'Brain Dump & New Visions',
              fontFamily: 'Outfit',
              fontSize: 24,
              textColor: 0xFFECEFF1,
              isBold: true,
              zIndex: 1,
            ),
            PageElement(
              id: _uuid.v4(),
              type: ElementType.stickyNote,
              x: 180,
              y: 180,
              width: 250,
              height: 220,
              assetKey: 'note_mint_green',
              textContent: '💡 App Launch Checklist:\n\n• Zero Login/Signup\n• Free Unlocked Studio\n• Realistic Bookshelf\n• Export to PNG/PDF',
              fontFamily: 'Caveat',
              fontSize: 18,
              textColor: 0xFF1B3B2B,
              rotation: 0.03,
              zIndex: 2,
            ),
          ],
        ),
      ],
    );

    return [journal1, journal2, journal3];
  }
}
