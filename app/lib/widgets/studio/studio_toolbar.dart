import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/journal_models.dart';

class StudioToolbar extends StatefulWidget {
  final StrokeToolType activeTool;
  final Color activeColor;
  final double activeStrokeWidth;
  final double activeOpacity;
  final bool isSmartShapeEnabled;
  final bool isSnapToGrid;
  final PaperType currentPaper;
  final Function(StrokeToolType) onSelectTool;
  final Function(Color) onSelectColor;
  final Function(double) onSelectStrokeWidth;
  final Function(double) onSelectOpacity;
  final Function(bool) onToggleSmartShape;
  final Function(bool) onToggleSnapToGrid;
  final Function(PaperType) onSelectPaper;
  final VoidCallback onAddText;
  final VoidCallback onOpenAssetLibrary;
  final VoidCallback onOpenPageManager;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback onExport;

  const StudioToolbar({
    super.key,
    required this.activeTool,
    required this.activeColor,
    required this.activeStrokeWidth,
    required this.activeOpacity,
    required this.isSmartShapeEnabled,
    required this.isSnapToGrid,
    required this.currentPaper,
    required this.onSelectTool,
    required this.onSelectColor,
    required this.onSelectStrokeWidth,
    required this.onSelectOpacity,
    required this.onToggleSmartShape,
    required this.onToggleSnapToGrid,
    required this.onSelectPaper,
    required this.onAddText,
    required this.onOpenAssetLibrary,
    required this.onOpenPageManager,
    this.onUndo,
    this.onRedo,
    required this.onExport,
  });

  @override
  State<StudioToolbar> createState() => _StudioToolbarState();
}

class _StudioToolbarState extends State<StudioToolbar> {
  bool _isCollapsed = false;

  // Curated Zinnia aesthetic color palettes
  static const List<Color> _paletteRomance = [
    Color(0xFF2B2D42), // Charcoal ink
    Color(0xFFE07A5F), // Terracotta
    Color(0xFFF4ACB7), // Blush pink
    Color(0xFF81B29A), // Sage leaf
    Color(0xFFF2CC8F), // Warm sand
    Color(0xFF3D405B), // Deep slate
    Color(0xFF6B705C), // Olive
  ];

  static const List<Color> _paletteMidnight = [
    Color(0xFFFAF0CA), // Ivory
    Color(0xFF0D3B66), // Marine
    Color(0xFFEE964B), // Amber gold
    Color(0xFFF95738), // Crimson
    Color(0xFF90BE6D), // Meadow
    Color(0xFF577590), // Steel blue
    Color(0xFF43AA8B), // Emerald
  ];

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Choose Custom Color', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Midnight & Vibrant Swatches:', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _paletteMidnight.map((c) {
                  return GestureDetector(
                    onTap: () {
                      widget.onSelectColor(c);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ColorPicker(
                pickerColor: widget.activeColor,
                onColorChanged: widget.onSelectColor,
                enableAlpha: true,
                labelTypes: const [],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Done', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPaperPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF8F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Paper Texture',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: PaperType.values.map((p) {
                final isSel = widget.currentPaper == p;
                String label;
                switch (p) {
                  case PaperType.dotGrid:
                    label = 'Dot Grid';
                    break;
                  case PaperType.lined:
                    label = 'Lined Paper';
                    break;
                  case PaperType.squareGrid:
                    label = 'Graph Grid';
                    break;
                  case PaperType.darkDots:
                    label = 'Midnight Dots';
                    break;
                  case PaperType.vintageKraft:
                    label = 'Vintage Kraft';
                    break;
                  case PaperType.blank:
                    label = 'Blank Cream';
                    break;
                  case PaperType.watercolor:
                    label = 'Watercolor';
                    break;
                }
                return ChoiceChip(
                  label: Text(label),
                  selected: isSel,
                  selectedColor: const Color(0xFFB5838D),
                  labelStyle: GoogleFonts.outfit(
                    color: isSel ? Colors.white : const Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    widget.onSelectPaper(p);
                    Navigator.of(ctx).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showStrokeSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFAF8F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digital Stationery Settings',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2C3E50)),
              ),
              const SizedBox(height: 16),
              // Tool tip style
              Text('Pen Tip Style:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _tipChoice('Fountain Pen', StrokeToolType.fountainPen, setSheetState),
                  _tipChoice('Ballpoint Pen', StrokeToolType.ballpoint, setSheetState),
                  _tipChoice('Graphite Pencil', StrokeToolType.pencil, setSheetState),
                  _tipChoice('Highlighter', StrokeToolType.highlighter, setSheetState),
                  _tipChoice('Monoline Inking', StrokeToolType.pen, setSheetState),
                ],
              ),
              const SizedBox(height: 16),
              // Stroke Width
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Stroke Thickness: ${widget.activeStrokeWidth.toStringAsFixed(1)}px', style: GoogleFonts.outfit(fontSize: 13)),
                  Container(
                    width: widget.activeStrokeWidth * 1.5,
                    height: widget.activeStrokeWidth * 1.5,
                    decoration: BoxDecoration(color: widget.activeColor, shape: BoxShape.circle),
                  ),
                ],
              ),
              Slider(
                value: widget.activeStrokeWidth,
                min: 1.0,
                max: 30.0,
                activeColor: const Color(0xFFB5838D),
                onChanged: (val) {
                  setSheetState(() {});
                  widget.onSelectStrokeWidth(val);
                },
              ),
              const SizedBox(height: 8),
              // Opacity
              Text('Ink Opacity: ${(widget.activeOpacity * 100).round()}%', style: GoogleFonts.outfit(fontSize: 13)),
              Slider(
                value: widget.activeOpacity,
                min: 0.1,
                max: 1.0,
                activeColor: const Color(0xFFB5838D),
                onChanged: (val) {
                  setSheetState(() {});
                  widget.onSelectOpacity(val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipChoice(String title, StrokeToolType tool, StateSetter setSheetState) {
    final isSel = widget.activeTool == tool;
    return ChoiceChip(
      label: Text(title),
      selected: isSel,
      selectedColor: const Color(0xFFB5838D),
      labelStyle: GoogleFonts.outfit(
        color: isSel ? Colors.white : const Color(0xFF2C3E50),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        setSheetState(() {});
        widget.onSelectTool(tool);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCollapsed) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.palette_outlined, color: Colors.white),
          tooltip: 'Expand Studio Tools',
          onPressed: () => setState(() => _isCollapsed = false),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
          // 1. Hand / Select Tool
          _toolButton(
            icon: Icons.pan_tool_alt_outlined,
            tooltip: 'Hand / Select Items',
            isSelected: widget.activeTool != StrokeToolType.pen &&
                widget.activeTool != StrokeToolType.fountainPen &&
                widget.activeTool != StrokeToolType.ballpoint &&
                widget.activeTool != StrokeToolType.pencil &&
                widget.activeTool != StrokeToolType.highlighter &&
                widget.activeTool != StrokeToolType.eraser,
            onTap: () => widget.onSelectTool(StrokeToolType.pen), // Hand mode is managed when not drawing
          ),

          const SizedBox(width: 4),

          // 2. Pen Tool (Tap opens pen or popover)
          _toolButton(
            icon: Icons.edit_outlined,
            tooltip: 'Fountain & Ballpoint Inking',
            isSelected: widget.activeTool == StrokeToolType.fountainPen ||
                widget.activeTool == StrokeToolType.ballpoint ||
                widget.activeTool == StrokeToolType.pen,
            onTap: () => widget.onSelectTool(StrokeToolType.fountainPen),
            onLongPress: _showStrokeSettings,
          ),

          // 3. Pencil Tool
          _toolButton(
            icon: Icons.border_color_outlined,
            tooltip: 'Graphite Pencil',
            isSelected: widget.activeTool == StrokeToolType.pencil,
            onTap: () => widget.onSelectTool(StrokeToolType.pencil),
          ),

          // 4. Highlighter Tool
          _toolButton(
            icon: Icons.brush_outlined,
            tooltip: 'Translucent Highlighter',
            isSelected: widget.activeTool == StrokeToolType.highlighter,
            onTap: () => widget.onSelectTool(StrokeToolType.highlighter),
          ),

          // 5. Eraser Tool
          _toolButton(
            icon: Icons.auto_fix_normal_outlined,
            tooltip: 'Stroke Eraser',
            isSelected: widget.activeTool == StrokeToolType.eraser,
            onTap: () => widget.onSelectTool(StrokeToolType.eraser),
          ),

          // Stroke settings dial
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFFCBD5E1), size: 18),
            tooltip: 'Pen Thickness & Opacity',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: _showStrokeSettings,
          ),

          _divider(),

          // 6. Color Palette Dots
          ..._paletteRomance.take(5).map((c) {
            final isSel = widget.activeColor.toARGB32() == c.toARGB32();
            return GestureDetector(
              onTap: () => widget.onSelectColor(c),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSel ? Colors.white : Colors.transparent,
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 2),
                  ],
                ),
              ),
            );
          }),

          // Color Wheel Picker
          GestureDetector(
            onTap: _showColorPicker,
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red],
                ),
              ),
            ),
          ),

          _divider(),

          // 7. Smart Shapes toggle
          _toolButton(
            icon: Icons.interests_outlined,
            tooltip: widget.isSmartShapeEnabled ? 'Smart Shapes: ON' : 'Smart Shapes: OFF',
            isSelected: widget.isSmartShapeEnabled,
            onTap: () => widget.onToggleSmartShape(!widget.isSmartShapeEnabled),
          ),

          // 8. Grid Snap toggle
          _toolButton(
            icon: Icons.grid_on,
            tooltip: widget.isSnapToGrid ? 'Grid Snapping: ON' : 'Grid Snapping: OFF',
            isSelected: widget.isSnapToGrid,
            onTap: () => widget.onToggleSnapToGrid(!widget.isSnapToGrid),
          ),

          // 9. Add Text block
          _toolButton(
            icon: Icons.title,
            tooltip: 'Add Text Block',
            isSelected: false,
            onTap: widget.onAddText,
          ),

          // 10. Studio Asset Library Drawer trigger
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE07A5F), Color(0xFFB5838D)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text('Studio', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: widget.onOpenAssetLibrary,
            ),
          ),

          _divider(),

          // 11. Paper Texture Picker
          IconButton(
            icon: const Icon(Icons.note_alt_outlined, color: Colors.white, size: 20),
            tooltip: 'Change Paper Texture',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: _showPaperPicker,
          ),

          // 12. Page Manager (Bird's-Eye View)
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white, size: 20),
            tooltip: 'Page Overview Manager',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: widget.onOpenPageManager,
          ),

          // 13. Undo & Redo
          IconButton(
            icon: const Icon(Icons.undo, color: Color(0xFFCBD5E1), size: 18),
            tooltip: 'Undo',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            onPressed: widget.onUndo,
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Color(0xFFCBD5E1), size: 18),
            tooltip: 'Redo',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            onPressed: widget.onRedo,
          ),

          // 14. Export
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Color(0xFF74C69D), size: 20),
            tooltip: 'Export Journal Page (PNG / PDF)',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: widget.onExport,
          ),

          // Collapse button
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8), size: 18),
            tooltip: 'Minimize Toolbar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            onPressed: () => setState(() => _isCollapsed = true),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB5838D) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: IconButton(
          icon: Icon(icon, size: 20, color: isSelected ? Colors.white : const Color(0xFFCBD5E1)),
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 24,
      width: 1,
      color: const Color(0xFF475569),
    );
  }
}
