import 'dart:convert';
import 'package:flutter/material.dart';

enum PaperType {
  blank,
  dotGrid,
  lined,
  squareGrid,
  darkDots,
  vintageKraft,
  watercolor,
}

enum CoverTexture {
  leather,
  linen,
  botanical,
  floral,
  darkLuxury,
  pastelMarble,
  minimalCharcoal,
}

enum StrokeToolType {
  pen,
  fountainPen,
  ballpoint,
  pencil,
  highlighter,
  eraser,
}

enum ElementType {
  text,
  sticker,
  washi,
  template,
  stickyNote,
  polaroid,
  image,
}

class StrokePoint {
  final double x;
  final double y;
  final double pressure;

  StrokePoint({
    required this.x,
    required this.y,
    this.pressure = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'pressure': pressure,
      };

  factory StrokePoint.fromJson(Map<String, dynamic> json) => StrokePoint(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        pressure: (json['pressure'] as num?)?.toDouble() ?? 1.0,
      );

  Offset toOffset() => Offset(x, y);
}

class DrawnStroke {
  final String id;
  final StrokeToolType toolType;
  final int colorValue;
  final double strokeWidth;
  final double opacity;
  final List<StrokePoint> points;
  final bool isGeometric;
  final String? geometricShape; // 'line', 'rectangle', 'circle', 'triangle', 'arrow'

  DrawnStroke({
    required this.id,
    required this.toolType,
    required this.colorValue,
    required this.strokeWidth,
    required this.opacity,
    required this.points,
    this.isGeometric = false,
    this.geometricShape,
  });

  Color get color => Color(colorValue).withValues(alpha: opacity);

  Map<String, dynamic> toJson() => {
        'id': id,
        'toolType': toolType.name,
        'colorValue': colorValue,
        'strokeWidth': strokeWidth,
        'opacity': opacity,
        'points': points.map((p) => p.toJson()).toList(),
        'isGeometric': isGeometric,
        'geometricShape': geometricShape,
      };

  factory DrawnStroke.fromJson(Map<String, dynamic> json) => DrawnStroke(
        id: json['id'] as String,
        toolType: StrokeToolType.values.firstWhere(
          (e) => e.name == json['toolType'],
          orElse: () => StrokeToolType.pen,
        ),
        colorValue: json['colorValue'] as int? ?? 0xFF2C3E50,
        strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 3.0,
        opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
        points: (json['points'] as List<dynamic>?)
                ?.map((p) => StrokePoint.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        isGeometric: json['isGeometric'] as bool? ?? false,
        geometricShape: json['geometricShape'] as String?,
      );

  DrawnStroke copyWith({
    String? id,
    StrokeToolType? toolType,
    int? colorValue,
    double? strokeWidth,
    double? opacity,
    List<StrokePoint>? points,
    bool? isGeometric,
    String? geometricShape,
  }) {
    return DrawnStroke(
      id: id ?? this.id,
      toolType: toolType ?? this.toolType,
      colorValue: colorValue ?? this.colorValue,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      points: points ?? this.points,
      isGeometric: isGeometric ?? this.isGeometric,
      geometricShape: geometricShape ?? this.geometricShape,
    );
  }
}

class PageElement {
  final String id;
  final ElementType type;
  double x;
  double y;
  double width;
  double height;
  double rotation; // radians
  double scale;
  int zIndex;
  bool isLocked;
  double opacity;

  // Text specific
  String? textContent;
  String? fontFamily;
  double? fontSize;
  int? textColor;
  int? backgroundColor;
  TextAlign? textAlign;
  bool isBold;
  bool isItalic;

  // Sticker / Washi / Asset specific
  String? assetKey;
  String? category;
  int? tintColor;

  // Template / StickyNote / Polaroid
  String? templateType;
  Map<String, dynamic>? extraData;

  PageElement({
    required this.id,
    required this.type,
    this.x = 100,
    this.y = 100,
    this.width = 200,
    this.height = 150,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.zIndex = 0,
    this.isLocked = false,
    this.opacity = 1.0,
    this.textContent,
    this.fontFamily,
    this.fontSize,
    this.textColor,
    this.backgroundColor,
    this.textAlign,
    this.isBold = false,
    this.isItalic = false,
    this.assetKey,
    this.category,
    this.tintColor,
    this.templateType,
    this.extraData,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'rotation': rotation,
        'scale': scale,
        'zIndex': zIndex,
        'isLocked': isLocked,
        'opacity': opacity,
        'textContent': textContent,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'textColor': textColor,
        'backgroundColor': backgroundColor,
        'textAlign': textAlign?.name,
        'isBold': isBold,
        'isItalic': isItalic,
        'assetKey': assetKey,
        'category': category,
        'tintColor': tintColor,
        'templateType': templateType,
        'extraData': extraData != null ? jsonEncode(extraData) : null,
      };

  factory PageElement.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedExtra;
    if (json['extraData'] != null) {
      try {
        if (json['extraData'] is Map) {
          parsedExtra = Map<String, dynamic>.from(json['extraData']);
        } else {
          parsedExtra = Map<String, dynamic>.from(jsonDecode(json['extraData']));
        }
      } catch (_) {}
    }

    return PageElement(
      id: json['id'] as String,
      type: ElementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ElementType.text,
      ),
      x: (json['x'] as num?)?.toDouble() ?? 100.0,
      y: (json['y'] as num?)?.toDouble() ?? 100.0,
      width: (json['width'] as num?)?.toDouble() ?? 200.0,
      height: (json['height'] as num?)?.toDouble() ?? 150.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      zIndex: json['zIndex'] as int? ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      textContent: json['textContent'] as String?,
      fontFamily: json['fontFamily'] as String?,
      fontSize: (json['fontSize'] as num?)?.toDouble(),
      textColor: json['textColor'] as int?,
      backgroundColor: json['backgroundColor'] as int?,
      textAlign: json['textAlign'] != null
          ? TextAlign.values.firstWhere(
              (e) => e.name == json['textAlign'],
              orElse: () => TextAlign.left,
            )
          : null,
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      assetKey: json['assetKey'] as String?,
      category: json['category'] as String?,
      tintColor: json['tintColor'] as int?,
      templateType: json['templateType'] as String?,
      extraData: parsedExtra,
    );
  }

  PageElement clone(String newId) {
    return PageElement(
      id: newId,
      type: type,
      x: x + 20,
      y: y + 20,
      width: width,
      height: height,
      rotation: rotation,
      scale: scale,
      zIndex: zIndex + 1,
      isLocked: isLocked,
      opacity: opacity,
      textContent: textContent,
      fontFamily: fontFamily,
      fontSize: fontSize,
      textColor: textColor,
      backgroundColor: backgroundColor,
      textAlign: textAlign,
      isBold: isBold,
      isItalic: isItalic,
      assetKey: assetKey,
      category: category,
      tintColor: tintColor,
      templateType: templateType,
      extraData: extraData != null ? Map<String, dynamic>.from(extraData!) : null,
    );
  }
}

class JournalPage {
  final String id;
  int pageIndex;
  PaperType? paperTypeOverride;
  bool isBookmarked;
  List<DrawnStroke> strokes;
  List<PageElement> elements;

  JournalPage({
    required this.id,
    required this.pageIndex,
    this.paperTypeOverride,
    this.isBookmarked = false,
    List<DrawnStroke>? strokes,
    List<PageElement>? elements,
  })  : strokes = strokes ?? [],
        elements = elements ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'pageIndex': pageIndex,
        'paperTypeOverride': paperTypeOverride?.name,
        'isBookmarked': isBookmarked,
        'strokes': strokes.map((s) => s.toJson()).toList(),
        'elements': elements.map((e) => e.toJson()).toList(),
      };

  factory JournalPage.fromJson(Map<String, dynamic> json) => JournalPage(
        id: json['id'] as String,
        pageIndex: json['pageIndex'] as int? ?? 0,
        paperTypeOverride: json['paperTypeOverride'] != null
            ? PaperType.values.firstWhere(
                (e) => e.name == json['paperTypeOverride'],
                orElse: () => PaperType.dotGrid,
              )
            : null,
        isBookmarked: json['isBookmarked'] as bool? ?? false,
        strokes: (json['strokes'] as List<dynamic>?)
                ?.map((s) => DrawnStroke.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        elements: (json['elements'] as List<dynamic>?)
                ?.map((e) => PageElement.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class Journal {
  final String id;
  String title;
  CoverTexture coverTexture;
  int coverColorValue;
  int accentColorValue;
  int ribbonColorValue;
  PaperType defaultPaper;
  DateTime createdAt;
  DateTime updatedAt;
  List<JournalPage> pages;

  Journal({
    required this.id,
    required this.title,
    this.coverTexture = CoverTexture.leather,
    this.coverColorValue = 0xFF5D4037, // warm saddle brown
    this.accentColorValue = 0xFFD4AF37, // embossed metallic gold
    this.ribbonColorValue = 0xFF8D6E63,
    this.defaultPaper = PaperType.dotGrid,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<JournalPage>? pages,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        pages = pages ?? [];

  Color get coverColor => Color(coverColorValue);
  Color get accentColor => Color(accentColorValue);
  Color get ribbonColor => Color(ribbonColorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverTexture': coverTexture.name,
        'coverColorValue': coverColorValue,
        'accentColorValue': accentColorValue,
        'ribbonColorValue': ribbonColorValue,
        'defaultPaper': defaultPaper.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'pages': pages.map((p) => p.toJson()).toList(),
      };

  factory Journal.fromJson(Map<String, dynamic> json) => Journal(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Untitled Journal',
        coverTexture: CoverTexture.values.firstWhere(
          (e) => e.name == json['coverTexture'],
          orElse: () => CoverTexture.leather,
        ),
        coverColorValue: json['coverColorValue'] as int? ?? 0xFF5D4037,
        accentColorValue: json['accentColorValue'] as int? ?? 0xFFD4AF37,
        ribbonColorValue: json['ribbonColorValue'] as int? ?? 0xFF8D6E63,
        defaultPaper: PaperType.values.firstWhere(
          (e) => e.name == json['defaultPaper'],
          orElse: () => PaperType.dotGrid,
        ),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        pages: (json['pages'] as List<dynamic>?)
                ?.map((p) => JournalPage.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
