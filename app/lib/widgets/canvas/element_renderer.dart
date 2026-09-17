import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/journal_models.dart';
import '../assets/asset_data.dart';

class ElementRenderer extends StatefulWidget {
  final PageElement element;
  final bool isSelected;
  final VoidCallback? onSelect;
  final Function(PageElement)? onUpdate;

  const ElementRenderer({
    super.key,
    required this.element,
    this.isSelected = false,
    this.onSelect,
    this.onUpdate,
  });

  @override
  State<ElementRenderer> createState() => _ElementRendererState();
}

class _ElementRendererState extends State<ElementRenderer> {
  @override
  Widget build(BuildContext context) {
    final el = widget.element;

    Widget content;
    switch (el.type) {
      case ElementType.text:
        content = _buildTextWidget(el);
        break;
      case ElementType.sticker:
        content = _buildStickerWidget(el);
        break;
      case ElementType.washi:
        content = _buildWashiWidget(el);
        break;
      case ElementType.stickyNote:
        content = _buildStickyNoteWidget(el);
        break;
      case ElementType.polaroid:
        content = _buildPolaroidWidget(el);
        break;
      case ElementType.template:
        content = _buildTemplateWidget(el);
        break;
      case ElementType.image:
        content = _buildImagePlaceholder(el);
        break;
    }

    return Transform.rotate(
      angle: el.rotation,
      child: Transform.scale(
        scale: el.scale,
        child: SizedBox(
          width: el.width,
          height: el.height,
          child: Opacity(
            opacity: el.opacity.clamp(0.1, 1.0),
            child: content,
          ),
        ),
      ),
    );
  }

  TextStyle _resolveTextStyle(String? fontFamily, double? fontSize, Color color, bool isBold, bool isItalic) {
    final size = fontSize ?? 18.0;
    final weight = isBold ? FontWeight.bold : FontWeight.normal;
    final style = isItalic ? FontStyle.italic : FontStyle.normal;

    switch (fontFamily) {
      case 'Caveat':
        return GoogleFonts.caveat(fontSize: size, color: color, fontWeight: weight, fontStyle: style);
      case 'Kalam':
        return GoogleFonts.kalam(fontSize: size, color: color, fontWeight: weight, fontStyle: style);
      case 'Dancing Script':
        return GoogleFonts.dancingScript(fontSize: size, color: color, fontWeight: weight, fontStyle: style);
      case 'Patrick Hand':
        return GoogleFonts.patrickHand(fontSize: size, color: color, fontWeight: weight, fontStyle: style);
      case 'Playfair Display':
        return GoogleFonts.playfairDisplay(fontSize: size, color: color, fontWeight: weight, fontStyle: style);
      case 'Outfit':
        return GoogleFonts.outfit(fontSize: size, color: color, fontWeight: weight, fontStyle: style);
      default:
        return GoogleFonts.caveat(fontSize: size, color: color, fontWeight: weight, fontStyle: style);
    }
  }

  Widget _buildTextWidget(PageElement el) {
    final textColor = el.textColor != null ? Color(el.textColor!) : const Color(0xFF2B2D42);
    final bgColor = el.backgroundColor != null ? Color(el.backgroundColor!) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        el.textContent ?? 'Tap to edit text...',
        style: _resolveTextStyle(
          el.fontFamily,
          el.fontSize,
          textColor,
          el.isBold,
          el.isItalic,
        ),
        textAlign: el.textAlign ?? TextAlign.left,
      ),
    );
  }

  Widget _buildStickerWidget(PageElement el) {
    final tint = el.tintColor != null ? Color(el.tintColor!) : null;
    return CustomPaint(
      size: Size(el.width, el.height),
      painter: StickerPainter(
        stickerId: el.assetKey ?? 'sticker_monstera',
        tint: tint,
      ),
    );
  }

  Widget _buildWashiWidget(PageElement el) {
    return CustomPaint(
      size: Size(el.width, el.height),
      painter: WashiTapePainter(
        washiId: el.assetKey ?? 'washi_pastel_floral',
      ),
    );
  }

  Widget _buildStickyNoteWidget(PageElement el) {
    Color noteBg = const Color(0xFFFFF3B0); // Butter Yellow
    if (el.assetKey == 'note_blush_pink') noteBg = const Color(0xFFFFD6E0);
    if (el.assetKey == 'note_mint_green') noteBg = const Color(0xFFD8F3DC);
    if (el.assetKey == 'note_lavender') noteBg = const Color(0xFFE8D7F1);
    if (el.assetKey == 'note_sky_blue') noteBg = const Color(0xFFCFE8FF);
    if (el.assetKey == 'note_vintage_kraft') noteBg = const Color(0xFFE9D8A6);

    return Container(
      decoration: BoxDecoration(
        color: noteBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(4, 6),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              el.textContent ?? 'Sticky Note Note...',
              style: _resolveTextStyle(
                el.fontFamily ?? 'Caveat',
                el.fontSize ?? 19,
                const Color(0xFF2F3E46),
                el.isBold,
                el.isItalic,
              ),
            ),
          ),
          // Folded corner triangle at bottom right
          Positioned(
            bottom: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: _FoldedCornerPainter(baseColor: noteBg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolaroidWidget(PageElement el) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(2, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Photo square
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFEB),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: el.assetKey != null
                    ? SizedBox(
                        width: 80,
                        height: 80,
                        child: CustomPaint(
                          painter: StickerPainter(stickerId: el.assetKey!),
                        ),
                      )
                    : const Icon(Icons.photo_outlined, size: 48, color: Color(0xFFADB5BD)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Handwritten caption
          Text(
            el.textContent ?? 'Memories & Moments',
            style: GoogleFonts.caveat(
              fontSize: el.fontSize ?? 17,
              color: const Color(0xFF4A4E69),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(PageElement el) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCED4DA)),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 48, color: Color(0xFF6C757D)),
      ),
    );
  }

  Widget _buildTemplateWidget(PageElement el) {
    final type = el.templateType ?? 'daily_planner';
    switch (type) {
      case 'daily_planner':
        return _buildDailyPlanner(el);
      case 'habit_tracker':
        return _buildHabitTracker(el);
      case 'mood_tracker':
        return _buildMoodTracker(el);
      case 'gratitude_log':
        return _buildGratitudeLog(el);
      case 'weekly_spread':
        return _buildWeeklySpread(el);
      case 'reading_log':
        return _buildReadingLog(el);
      default:
        return _buildDailyPlanner(el);
    }
  }

  // --- TEMPLATE 1: DAILY PLANNER ---
  Widget _buildDailyPlanner(PageElement el) {
    final extra = el.extraData ?? {};
    int waterCups = (extra['waterCups'] as int?) ?? 3;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D8A6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAILY FOCUS & FLOW',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: const Color(0xFF582F0E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDA15E).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  DateTime.now().toString().substring(0, 10),
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF582F0E)),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFDDA15E)),

          // Top 3 Priorities
          Text(
            'TOP 3 PRIORITIES',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF7F4F24)),
          ),
          const SizedBox(height: 6),
          _priorityRow('1', extra['priority1'] as String? ?? 'Set key intention for today'),
          _priorityRow('2', extra['priority2'] as String? ?? 'Complete deep creative focus session'),
          _priorityRow('3', extra['priority3'] as String? ?? 'Mindful evening reflection'),
          const SizedBox(height: 14),

          // Water Tracker
          Row(
            children: [
              Text(
                'WATER TRACKER:',
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF457B9D)),
              ),
              const SizedBox(width: 8),
              ...List.generate(8, (index) {
                final filled = index < waterCups;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      el.extraData ??= {};
                      el.extraData!['waterCups'] = filled ? index : index + 1;
                    });
                    widget.onUpdate?.call(el);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      filled ? Icons.water_drop : Icons.water_drop_outlined,
                      size: 19,
                      color: filled ? const Color(0xFF2A9D8F) : const Color(0xFFADB5BD),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 14),

          // Daily Checklist & Schedule
          Text(
            'SCHEDULE & ACTIONS',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF7F4F24)),
          ),
          const SizedBox(height: 6),
          _checklistRow('09:00 AM', 'Morning journal & espresso', true),
          _checklistRow('11:00 AM', 'Creative drawing & spread design', true),
          _checklistRow('02:00 PM', 'Organize bullet tasks', false),
          _checklistRow('05:00 PM', 'Walk in nature & unwind', false),
        ],
      ),
    );
  }

  Widget _priorityRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFDDA15E),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.caveat(fontSize: 16, color: const Color(0xFF2F3E46)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistRow(String time, String task, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            time,
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6C757D)),
          ),
          const SizedBox(width: 8),
          Icon(
            checked ? Icons.check_box_outlined : Icons.check_box_outline_blank,
            size: 17,
            color: checked ? const Color(0xFF2A9D8F) : const Color(0xFFADB5BD),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              task,
              style: GoogleFonts.caveat(
                fontSize: 15,
                color: checked ? const Color(0xFF6C757D) : const Color(0xFF2F3E46),
                decoration: checked ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- TEMPLATE 2: HABIT TRACKER ---
  Widget _buildHabitTracker(PageElement el) {
    final extra = el.extraData ?? {};
    final habits = (extra['habits'] as List<dynamic>?) ?? [
      {'name': 'Read 20 pages', 'completed': [true, true, true, false, true, true, false]},
      {'name': 'Meditate 10 min', 'completed': [true, true, false, true, true, true, true]},
      {'name': 'Drink 2L Water', 'completed': [true, true, true, true, false, true, true]},
      {'name': 'Creative sketch', 'completed': [false, true, true, true, true, false, true]},
    ];

    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB7E4C7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY HABIT MATRIX',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                  color: const Color(0xFF1B4332),
                ),
              ),
              const Icon(Icons.spa_outlined, color: Color(0xFF2D6A4F), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          // Day Header
          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              ...days.map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF52796F)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 14, color: Color(0xFFD8F3DC)),
          // Habit Rows
          ...habits.asMap().values.map((hMap) {
            final h = hMap as Map<String, dynamic>;
            final name = h['name'] as String? ?? 'Habit';
            final comp = (h['completed'] as List<dynamic>?) ?? List.filled(7, false);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      name,
                      style: GoogleFonts.caveat(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF2D3142)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...List.generate(7, (dIndex) {
                    final isDone = comp.length > dIndex && comp[dIndex] == true;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            final newComp = List<bool>.from(comp);
                            newComp[dIndex] = !isDone;
                            h['completed'] = newComp;
                            el.extraData ??= {};
                            el.extraData!['habits'] = habits;
                          });
                          widget.onUpdate?.call(el);
                        },
                        child: Center(
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isDone ? const Color(0xFF52B788) : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDone ? const Color(0xFF2D6A4F) : const Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                            child: isDone
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- TEMPLATE 3: MOOD TRACKER ---
  Widget _buildMoodTracker(PageElement el) {
    final extra = el.extraData ?? {};
    final currentMood = extra['currentMood'] as String? ?? 'Ecstatic';

    final moods = [
      {'name': 'Ecstatic', 'color': const Color(0xFFFFB703), 'icon': Icons.sentiment_very_satisfied},
      {'name': 'Calm', 'color': const Color(0xFF90E0EF), 'icon': Icons.sentiment_satisfied},
      {'name': 'Neutral', 'color': const Color(0xFFD8E2DC), 'icon': Icons.sentiment_neutral},
      {'name': 'Stressed', 'color': const Color(0xFFE5989B), 'icon': Icons.sentiment_dissatisfied},
      {'name': 'Tired', 'color': const Color(0xFFCDB4DB), 'icon': Icons.bedtime_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC6FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DAILY MOOD SPECTRUM',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                  color: const Color(0xFF7209B7),
                ),
              ),
              const Icon(Icons.auto_awesome, color: Color(0xFFB5179E), size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moods.map((m) {
              final isSelected = m['name'] == currentMood;
              final color = m['color'] as Color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    el.extraData ??= {};
                    el.extraData!['currentMood'] = m['name'];
                  });
                  widget.onUpdate?.call(el);
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? color : color.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                        border: Border.all(
                          color: isSelected ? Colors.black87 : Colors.transparent,
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                        m['icon'] as IconData,
                        size: 24,
                        color: isSelected ? Colors.white : const Color(0xFF4A4E69),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      m['name'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: const Color(0xFF4A4E69),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- TEMPLATE 4: GRATITUDE LOG ---
  Widget _buildGratitudeLog(PageElement el) {
    final extra = el.extraData ?? {};
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE2E4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Color(0xFFE07A5F), size: 18),
              const SizedBox(width: 8),
              Text(
                '3 THINGS I\'M GRATEFUL FOR',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFF3D405B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _gratitudeItem('1.', extra['item1'] as String? ?? 'Quiet morning moments with tea'),
          _gratitudeItem('2.', extra['item2'] as String? ?? 'The creative freedom to make art'),
          _gratitudeItem('3.', extra['item3'] as String? ?? 'Support from good people in my life'),
        ],
      ),
    );
  }

  Widget _gratitudeItem(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(num, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFE07A5F))),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE0E1DD), width: 1.0)),
              ),
              child: Text(
                text,
                style: GoogleFonts.caveat(fontSize: 17, color: const Color(0xFF2F3E46)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TEMPLATE 5: WEEKLY SPREAD ---
  Widget _buildWeeklySpread(PageElement el) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Weekend'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0F4DE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY OVERVIEW',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: const Color(0xFF2D6A4F)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: days.length,
              itemBuilder: (context, i) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDEE2E6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(days[i], style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF495057))),
                      const SizedBox(height: 4),
                      Text('• Focus point...', style: GoogleFonts.caveat(fontSize: 14, color: const Color(0xFF6C757D))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- TEMPLATE 6: READING LOG ---
  Widget _buildReadingLog(PageElement el) {
    final bookSpines = [
      {'title': 'Deep Work', 'color': const Color(0xFFE76F51)},
      {'title': 'Atomic Habits', 'color': const Color(0xFF2A9D8F)},
      {'title': 'The Artist\'s Way', 'color': const Color(0xFFE9C46A)},
      {'title': 'Steal Like an Artist', 'color': const Color(0xFF264653)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCED4DA), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'READING SHELF & BOOK LOG',
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: const Color(0xFF343A40)),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...bookSpines.map((b) {
                  return Container(
                    width: 38,
                    height: (120 + (math.Random().nextInt(30))).toDouble(),
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: b['color'] as Color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(2, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          b['title'] as String,
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63), // wooden shelf bar
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoldedCornerPainter extends CustomPainter {
  final Color baseColor;

  _FoldedCornerPainter({required this.baseColor});

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final foldPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final foldPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(foldPath, shadowPaint);
    canvas.drawPath(foldPath, foldPaint);
  }

  @override
  bool shouldRepaint(covariant _FoldedCornerPainter oldDelegate) => oldDelegate.baseColor != baseColor;
}
