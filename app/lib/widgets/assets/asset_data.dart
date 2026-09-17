import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssetMetadata {
  final String id;
  final String title;
  final String category; // 'botanical', 'planner', 'lifestyle', 'washi', 'notes', 'templates'
  final Color previewColor;
  final IconData? icon;

  const AssetMetadata({
    required this.id,
    required this.title,
    required this.category,
    required this.previewColor,
    this.icon,
  });
}

class AssetLibrary {
  static const List<AssetMetadata> stickers = [
    // Botanicals
    AssetMetadata(id: 'sticker_monstera', title: 'Monstera Leaf', category: 'botanical', previewColor: Color(0xFF2D6A4F), icon: Icons.eco),
    AssetMetadata(id: 'sticker_eucalyptus', title: 'Eucalyptus Sprig', category: 'botanical', previewColor: Color(0xFF52796F), icon: Icons.spa),
    AssetMetadata(id: 'sticker_wildflower', title: 'Wildflower Bloom', category: 'botanical', previewColor: Color(0xFFE07A5F), icon: Icons.local_florist),
    AssetMetadata(id: 'sticker_cherry_blossom', title: 'Sakura Blossom', category: 'botanical', previewColor: Color(0xFFF4ACB7), icon: Icons.filter_vintage),
    AssetMetadata(id: 'sticker_fern', title: 'Lush Fern', category: 'botanical', previewColor: Color(0xFF40916C), icon: Icons.grass),
    AssetMetadata(id: 'sticker_succulent', title: 'Pastel Succulent', category: 'botanical', previewColor: Color(0xFF74C69D), icon: Icons.nature),

    // Planner Badges
    AssetMetadata(id: 'sticker_badge_today', title: 'TODAY', category: 'planner', previewColor: Color(0xFFE76F51), icon: Icons.today),
    AssetMetadata(id: 'sticker_badge_priority', title: 'PRIORITY', category: 'planner', previewColor: Color(0xFFD62828), icon: Icons.flag),
    AssetMetadata(id: 'sticker_badge_todo', title: 'TO-DO', category: 'planner', previewColor: Color(0xFF2A9D8F), icon: Icons.check_circle_outline),
    AssetMetadata(id: 'sticker_badge_dont_forget', title: 'DON\'T FORGET', category: 'planner', previewColor: Color(0xFFF4A261), icon: Icons.notification_important_outlined),
    AssetMetadata(id: 'sticker_badge_goals', title: 'GOALS', category: 'planner', previewColor: Color(0xFF457B9D), icon: Icons.stars),
    AssetMetadata(id: 'sticker_badge_selfcare', title: 'SELF CARE', category: 'planner', previewColor: Color(0xFFB56576), icon: Icons.favorite_outline),

    // Lifestyle & Doodles
    AssetMetadata(id: 'sticker_coffee_cup', title: 'Cozy Coffee', category: 'lifestyle', previewColor: Color(0xFF8D6E63), icon: Icons.coffee),
    AssetMetadata(id: 'sticker_tea_cup', title: 'Herbal Tea', category: 'lifestyle', previewColor: Color(0xFF6B705C), icon: Icons.emoji_food_beverage),
    AssetMetadata(id: 'sticker_sparkles', title: 'Magic Sparkles', category: 'lifestyle', previewColor: Color(0xFFE9C46A), icon: Icons.auto_awesome),
    AssetMetadata(id: 'sticker_sun', title: 'Golden Sun', category: 'lifestyle', previewColor: Color(0xFFF39C12), icon: Icons.wb_sunny_outlined),
    AssetMetadata(id: 'sticker_rain_cloud', title: 'Gentle Rain', category: 'lifestyle', previewColor: Color(0xFF5DADE2), icon: Icons.water_drop_outlined),
    AssetMetadata(id: 'sticker_wax_seal', title: 'Royal Wax Seal', category: 'lifestyle', previewColor: Color(0xFF9D0208), icon: Icons.military_tech),
  ];

  static const List<AssetMetadata> washiTapes = [
    AssetMetadata(id: 'washi_pastel_floral', title: 'Pastel Floral Washi', category: 'washi', previewColor: Color(0xFFFAD2E1)),
    AssetMetadata(id: 'washi_minimal_grid', title: 'Architect Grid Washi', category: 'washi', previewColor: Color(0xFFE9ECEF)),
    AssetMetadata(id: 'washi_polka_dot', title: 'Blush Polka Dot', category: 'washi', previewColor: Color(0xFFF8EDEB)),
    AssetMetadata(id: 'washi_kraft_paper', title: 'Vintage Kraft Tape', category: 'washi', previewColor: Color(0xFFDDB892)),
    AssetMetadata(id: 'washi_gold_marble', title: 'Gold Foil Marble', category: 'washi', previewColor: Color(0xFFE2D4A8)),
    AssetMetadata(id: 'washi_sage_botanical', title: 'Sage Leaves Washi', category: 'washi', previewColor: Color(0xFFCCD5AE)),
  ];

  static const List<AssetMetadata> stickyNotes = [
    AssetMetadata(id: 'note_butter_yellow', title: 'Butter Yellow', category: 'notes', previewColor: Color(0xFFFFF3B0)),
    AssetMetadata(id: 'note_blush_pink', title: 'Blush Rose', category: 'notes', previewColor: Color(0xFFFFD6E0)),
    AssetMetadata(id: 'note_mint_green', title: 'Fresh Mint', category: 'notes', previewColor: Color(0xFFD8F3DC)),
    AssetMetadata(id: 'note_lavender', title: 'Soft Lavender', category: 'notes', previewColor: Color(0xFFE8D7F1)),
    AssetMetadata(id: 'note_sky_blue', title: 'Sky Pastel', category: 'notes', previewColor: Color(0xFFCFE8FF)),
    AssetMetadata(id: 'note_vintage_kraft', title: 'Recycled Kraft', category: 'notes', previewColor: Color(0xFFE9D8A6)),
  ];

  static const List<AssetMetadata> templates = [
    AssetMetadata(id: 'daily_planner', title: 'Daily Focus & Schedule', category: 'templates', previewColor: Color(0xFFE9D8A6), icon: Icons.view_day_outlined),
    AssetMetadata(id: 'habit_tracker', title: 'Weekly Habit Matrix', category: 'templates', previewColor: Color(0xFFB7E4C7), icon: Icons.fact_check_outlined),
    AssetMetadata(id: 'mood_tracker', title: 'Mood Mandala & Spectrum', category: 'templates', previewColor: Color(0xFFFFC6FF), icon: Icons.sentiment_satisfied_alt),
    AssetMetadata(id: 'gratitude_log', title: 'Gratitude & Mindset', category: 'templates', previewColor: Color(0xFFFDE2E4), icon: Icons.favorite_border),
    AssetMetadata(id: 'weekly_spread', title: '7-Day Weekly Spread', category: 'templates', previewColor: Color(0xFFD0F4DE), icon: Icons.view_week_outlined),
    AssetMetadata(id: 'reading_log', title: 'Illustrated Book Log', category: 'templates', previewColor: Color(0xFFE2E2E2), icon: Icons.menu_book),
  ];
}

/// Vector Painter for aesthetic stickers
class StickerPainter extends CustomPainter {
  final String stickerId;
  final Color? tint;

  StickerPainter({required this.stickerId, this.tint});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    switch (stickerId) {
      case 'sticker_monstera':
        _drawMonstera(canvas, size);
        break;
      case 'sticker_eucalyptus':
        _drawEucalyptus(canvas, size);
        break;
      case 'sticker_wildflower':
        _drawWildflower(canvas, size);
        break;
      case 'sticker_cherry_blossom':
        _drawCherryBlossom(canvas, size);
        break;
      case 'sticker_coffee_cup':
        _drawCoffeeCup(canvas, size);
        break;
      case 'sticker_tea_cup':
        _drawTeaCup(canvas, size);
        break;
      case 'sticker_sparkles':
        _drawSparkles(canvas, size);
        break;
      case 'sticker_sun':
        _drawSun(canvas, size);
        break;
      case 'sticker_rain_cloud':
        _drawRainCloud(canvas, size);
        break;
      case 'sticker_wax_seal':
        _drawWaxSeal(canvas, size);
        break;
      case 'sticker_badge_today':
      case 'sticker_badge_priority':
      case 'sticker_badge_todo':
      case 'sticker_badge_dont_forget':
      case 'sticker_badge_goals':
      case 'sticker_badge_selfcare':
        _drawBadge(canvas, size, stickerId);
        break;
      default:
        final paint = Paint()..color = tint ?? const Color(0xFF74C69D);
        canvas.drawCircle(center, w * 0.35, paint);
    }
  }

  void _drawMonstera(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tint ?? const Color(0xFF2D6A4F)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.95);
    path.quadraticBezierTo(size.width * 0.52, size.height * 0.5, size.width * 0.5, size.height * 0.1);
    path.quadraticBezierTo(size.width * 0.85, size.height * 0.3, size.width * 0.8, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.65, size.height * 0.85, size.width * 0.5, size.height * 0.95);

    path.moveTo(size.width * 0.5, size.height * 0.95);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.7, size.width * 0.2, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.45, size.height * 0.1, size.width * 0.5, size.height * 0.1);

    canvas.drawPath(path, paint);

    // Monstera fenestrations (slits)
    final cutoutPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.35),
      Offset(size.width * 0.72, size.height * 0.32),
      cutoutPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.52),
      cutoutPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.38),
      Offset(size.width * 0.28, size.height * 0.36),
      cutoutPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.55),
      Offset(size.width * 0.25, size.height * 0.58),
      cutoutPaint,
    );
  }

  void _drawEucalyptus(Canvas canvas, Size size) {
    final stemPaint = Paint()
      ..color = const Color(0xFF405D4A)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = tint ?? const Color(0xFF789D88)
      ..style = PaintingStyle.fill;

    // Curved stem
    final stem = Path();
    stem.moveTo(size.width * 0.5, size.height * 0.95);
    stem.quadraticBezierTo(size.width * 0.45, size.height * 0.5, size.width * 0.52, size.height * 0.1);
    canvas.drawPath(stem, stemPaint);

    // Alternating circular leaves
    final leafData = [
      [0.45, 0.2, 14.0],
      [0.55, 0.3, 16.0],
      [0.42, 0.45, 20.0],
      [0.58, 0.55, 22.0],
      [0.40, 0.7, 24.0],
      [0.60, 0.78, 22.0],
    ];

    for (final leaf in leafData) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * leaf[0], size.height * leaf[1]),
          width: leaf[2] * 1.4,
          height: leaf[2],
        ),
        leafPaint,
      );
    }
  }

  void _drawWildflower(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petalPaint = Paint()
      ..color = tint ?? const Color(0xFFF28482)
      ..style = PaintingStyle.fill;

    final discPaint = Paint()
      ..color = const Color(0xFFF6BD60)
      ..style = PaintingStyle.fill;

    const petals = 8;
    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi) / petals;
      final offset = Offset(math.cos(angle) * (size.width * 0.25), math.sin(angle) * (size.height * 0.25));
      canvas.drawCircle(center + offset, size.width * 0.14, petalPaint);
    }
    canvas.drawCircle(center, size.width * 0.16, discPaint);
  }

  void _drawCherryBlossom(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petalPaint = Paint()
      ..color = tint ?? const Color(0xFFF4ACB7)
      ..style = PaintingStyle.fill;

    final centerDotPaint = Paint()
      ..color = const Color(0xFFD88392)
      ..style = PaintingStyle.fill;

    const petals = 5;
    for (int i = 0; i < petals; i++) {
      final angle = (i * 2 * math.pi) / petals - math.pi / 2;
      final path = Path();
      final p1 = center;
      final tip = center + Offset(math.cos(angle) * (size.width * 0.36), math.sin(angle) * (size.height * 0.36));
      final leftWing = center + Offset(math.cos(angle - 0.3) * (size.width * 0.26), math.sin(angle - 0.3) * (size.height * 0.26));
      final rightWing = center + Offset(math.cos(angle + 0.3) * (size.width * 0.26), math.sin(angle + 0.3) * (size.height * 0.26));

      path.moveTo(p1.dx, p1.dy);
      path.lineTo(leftWing.dx, leftWing.dy);
      path.quadraticBezierTo(tip.dx, tip.dy - 4, rightWing.dx, rightWing.dy);
      path.close();
      canvas.drawPath(path, petalPaint);
    }
    canvas.drawCircle(center, size.width * 0.08, centerDotPaint);
  }

  void _drawCoffeeCup(Canvas canvas, Size size) {
    final cupPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;
    final steamPaint = Paint()
      ..color = const Color(0xFFBCAAA4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final cupRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.45, size.width * 0.44, size.height * 0.4),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
    );
    canvas.drawRRect(cupRect, cupPaint);

    // Cup handle
    final handlePaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    final handlePath = Path();
    handlePath.moveTo(size.width * 0.72, size.height * 0.52);
    handlePath.arcToPoint(
      Offset(size.width * 0.72, size.height * 0.72),
      radius: const Radius.circular(12),
      clockwise: true,
    );
    canvas.drawPath(handlePath, handlePaint);

    // Saucer
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.22, size.height * 0.86, size.width * 0.56, size.height * 0.08),
        const Radius.circular(6),
      ),
      cupPaint,
    );

    // Steam spirals
    final steam1 = Path();
    steam1.moveTo(size.width * 0.42, size.height * 0.38);
    steam1.quadraticBezierTo(size.width * 0.40, size.height * 0.28, size.width * 0.45, size.height * 0.18);
    canvas.drawPath(steam1, steamPaint);

    final steam2 = Path();
    steam2.moveTo(size.width * 0.56, size.height * 0.38);
    steam2.quadraticBezierTo(size.width * 0.58, size.height * 0.28, size.width * 0.53, size.height * 0.18);
    canvas.drawPath(steam2, steamPaint);
  }

  void _drawTeaCup(Canvas canvas, Size size) {
    _drawCoffeeCup(canvas, size);
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tint ?? const Color(0xFFE9C46A)
      ..style = PaintingStyle.fill;

    void drawStar(Offset center, double radius) {
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = (i * math.pi) / 2;
        path.moveTo(center.dx, center.dy);
        final tip = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
        final side1 = center + Offset(math.cos(angle - 0.4) * (radius * 0.25), math.sin(angle - 0.4) * (radius * 0.25));
        final side2 = center + Offset(math.cos(angle + 0.4) * (radius * 0.25), math.sin(angle + 0.4) * (radius * 0.25));
        path.lineTo(side1.dx, side1.dy);
        path.lineTo(tip.dx, tip.dy);
        path.lineTo(side2.dx, side2.dy);
        path.close();
      }
      canvas.drawPath(path, paint);
    }

    drawStar(Offset(size.width * 0.5, size.height * 0.45), size.width * 0.38);
    drawStar(Offset(size.width * 0.25, size.height * 0.25), size.width * 0.18);
    drawStar(Offset(size.width * 0.78, size.height * 0.72), size.width * 0.22);
  }

  void _drawSun(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sunPaint = Paint()
      ..color = tint ?? const Color(0xFFF4A261)
      ..style = PaintingStyle.fill;
    final rayPaint = Paint()
      ..color = tint ?? const Color(0xFFF4A261)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, size.width * 0.24, sunPaint);

    const rays = 12;
    for (int i = 0; i < rays; i++) {
      final angle = (i * 2 * math.pi) / rays;
      final start = center + Offset(math.cos(angle) * (size.width * 0.3), math.sin(angle) * (size.width * 0.3));
      final end = center + Offset(math.cos(angle) * (size.width * 0.42), math.sin(angle) * (size.width * 0.42));
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawRainCloud(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = const Color(0xFFA8DADC)
      ..style = PaintingStyle.fill;
    final dropPaint = Paint()
      ..color = const Color(0xFF457B9D)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final cloudPath = Path();
    cloudPath.addOval(Rect.fromCircle(center: Offset(size.width * 0.4, size.height * 0.42), radius: size.width * 0.2));
    cloudPath.addOval(Rect.fromCircle(center: Offset(size.width * 0.6, size.height * 0.38), radius: size.width * 0.24));
    cloudPath.addOval(Rect.fromCircle(center: Offset(size.width * 0.75, size.height * 0.46), radius: size.width * 0.16));
    cloudPath.addRect(Rect.fromLTWH(size.width * 0.3, size.height * 0.44, size.width * 0.5, size.height * 0.16));

    canvas.drawPath(cloudPath, cloudPaint);

    // Raindrops
    final drops = [
      [0.35, 0.68, 0.32, 0.82],
      [0.50, 0.68, 0.47, 0.84],
      [0.65, 0.68, 0.62, 0.82],
    ];
    for (final d in drops) {
      canvas.drawLine(
        Offset(size.width * d[0], size.height * d[1]),
        Offset(size.width * d[2], size.height * d[3]),
        dropPaint,
      );
    }
  }

  void _drawWaxSeal(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sealPaint = Paint()
      ..color = const Color(0xFF9D0208)
      ..style = PaintingStyle.fill;
    final innerPaint = Paint()
      ..color = const Color(0xFFBA181B)
      ..style = PaintingStyle.fill;
    final goldFoil = Paint()
      ..color = const Color(0xFFFFD166)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Organic wavy seal border
    final path = Path();
    const lobes = 14;
    for (int i = 0; i <= lobes; i++) {
      final angle = (i * 2 * math.pi) / lobes;
      final r = size.width * 0.42 + (i.isEven ? 4 : -4);
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, sealPaint);
    canvas.drawCircle(center, size.width * 0.28, innerPaint);
    canvas.drawCircle(center, size.width * 0.25, goldFoil);
  }

  void _drawBadge(Canvas canvas, Size size, String badgeId) {
    Color badgeColor = const Color(0xFFE76F51);
    String label = 'TODAY';

    if (badgeId.contains('priority')) {
      badgeColor = const Color(0xFFD62828);
      label = 'PRIORITY';
    } else if (badgeId.contains('todo')) {
      badgeColor = const Color(0xFF2A9D8F);
      label = 'TO-DO';
    } else if (badgeId.contains('dont_forget')) {
      badgeColor = const Color(0xFFF4A261);
      label = 'DON\'T FORGET';
    } else if (badgeId.contains('goals')) {
      badgeColor = const Color(0xFF457B9D);
      label = 'GOALS';
    } else if (badgeId.contains('selfcare')) {
      badgeColor = const Color(0xFFB56576);
      label = 'SELF CARE';
    }

    final bgPaint = Paint()..color = badgeColor;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );
    canvas.drawRRect(rrect, bgPaint);

    final textSpan = TextSpan(
      text: label,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: size.height * 0.42,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout(maxWidth: size.width);
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant StickerPainter oldDelegate) =>
      oldDelegate.stickerId != stickerId || oldDelegate.tint != tint;
}

/// Vector Painter for Washi Tapes with realistic torn edges
class WashiTapePainter extends CustomPainter {
  final String washiId;

  WashiTapePainter({required this.washiId});

  @override
  void paint(Canvas canvas, Size size) {
    Color baseColor = const Color(0xFFFAD2E1);

    switch (washiId) {
      case 'washi_minimal_grid':
        baseColor = const Color(0xFFF1F3F5);
        break;
      case 'washi_polka_dot':
        baseColor = const Color(0xFFFFE5EC);
        break;
      case 'washi_kraft_paper':
        baseColor = const Color(0xFFE2C499);
        break;
      case 'washi_gold_marble':
        baseColor = const Color(0xFFE9D8A6);
        break;
      case 'washi_sage_botanical':
        baseColor = const Color(0xFFD8E2DC);
        break;
      default:
        baseColor = const Color(0xFFFAD2E1);
    }

    final path = Path();
    // Left torn zigzag edge
    path.moveTo(0, 0);
    const teeth = 8;
    final stepH = size.height / teeth;
    for (int i = 0; i < teeth; i++) {
      final y = (i + 0.5) * stepH;
      final nextY = (i + 1) * stepH;
      path.lineTo(i.isEven ? 5 : 0, y);
      path.lineTo(0, nextY);
    }

    // Bottom straight line to right
    path.lineTo(size.width, size.height);

    // Right torn zigzag edge
    for (int i = 0; i < teeth; i++) {
      final y = size.height - (i + 0.5) * stepH;
      final nextY = size.height - (i + 1) * stepH;
      path.lineTo(size.width - (i.isEven ? 5 : 0), y);
      path.lineTo(size.width, nextY);
    }

    // Top straight edge
    path.lineTo(0, 0);
    path.close();

    // Semi-translucent washi look
    final bgPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // Pattern overlays
    if (washiId == 'washi_minimal_grid') {
      final gridPaint = Paint()
        ..color = const Color(0xFFADB5BD).withValues(alpha: 0.5)
        ..strokeWidth = 1.0;
      for (double x = 15; x < size.width - 10; x += 16) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 8; y < size.height; y += 12) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    } else if (washiId == 'washi_polka_dot') {
      final dotPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;
      for (double x = 15; x < size.width - 15; x += 22) {
        for (double y = 10; y < size.height; y += 18) {
          canvas.drawCircle(Offset(x, y), 3.0, dotPaint);
        }
      }
    } else if (washiId == 'washi_pastel_floral') {
      final flowerPaint = Paint()
        ..color = const Color(0xFFE5989B).withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;
      final leafPaint = Paint()
        ..color = const Color(0xFFB5E48C).withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      for (double x = 25; x < size.width - 20; x += 36) {
        canvas.drawCircle(Offset(x, size.height / 2), 5.0, flowerPaint);
        canvas.drawCircle(Offset(x + 10, size.height / 2 - 4), 3.0, leafPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WashiTapePainter oldDelegate) => oldDelegate.washiId != washiId;
}
