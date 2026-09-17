import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_models.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import '../widgets/canvas/interactive_canvas.dart';
import '../widgets/studio/studio_toolbar.dart';
import '../widgets/assets/asset_library_drawer.dart';
import 'page_manager_modal.dart';

class JournalCanvasScreen extends StatefulWidget {
  final Journal journal;
  final List<Journal> allJournals;
  final int initialPageIndex;

  const JournalCanvasScreen({
    super.key,
    required this.journal,
    required this.allJournals,
    this.initialPageIndex = 0,
  });

  @override
  State<JournalCanvasScreen> createState() => _JournalCanvasScreenState();
}

class _JournalCanvasScreenState extends State<JournalCanvasScreen> {
  static const Uuid _uuid = Uuid();

  late int _currentPageIndex;
  bool _isDoubleSpread = false;
  bool _isAssetDrawerOpen = false;

  // Active Tool state
  StrokeToolType _activeTool = StrokeToolType.pen;
  Color _activeColor = const Color(0xFF2B2D42);
  double _activeStrokeWidth = 3.5;
  double _activeOpacity = 1.0;
  bool _isSmartShapeEnabled = false;
  bool _isSnapToGrid = false;
  late PaperType _currentPaper;

  // Undo / Redo history stacks for strokes
  final List<List<DrawnStroke>> _undoStack = [];
  final List<List<DrawnStroke>> _redoStack = [];

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPageIndex.clamp(0, widget.journal.pages.length - 1);
    _currentPaper = widget.journal.pages[_currentPageIndex].paperTypeOverride ?? widget.journal.defaultPaper;
  }

  JournalPage get _currentPage => widget.journal.pages[_currentPageIndex];

  JournalPage? get _secondPage {
    if (!_isDoubleSpread) return null;
    if (_currentPageIndex + 1 < widget.journal.pages.length) {
      return widget.journal.pages[_currentPageIndex + 1];
    }
    return null;
  }

  void _saveChanges() {
    widget.journal.updatedAt = DateTime.now();
    StorageService.saveJournals(widget.allJournals);
  }

  void _onStrokeCompleted(DrawnStroke stroke) {
    setState(() {
      _undoStack.add(List<DrawnStroke>.from(_currentPage.strokes));
      _redoStack.clear();
      _currentPage.strokes.add(stroke);
    });
    _saveChanges();
  }

  void _onStrokesUpdated(List<DrawnStroke> newStrokes) {
    setState(() {
      _undoStack.add(List<DrawnStroke>.from(_currentPage.strokes));
      _redoStack.clear();
      _currentPage.strokes = newStrokes;
    });
    _saveChanges();
  }

  void _onElementsUpdated(List<PageElement> newElements) {
    setState(() {
      _currentPage.elements = newElements;
    });
    _saveChanges();
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      setState(() {
        _redoStack.add(List<DrawnStroke>.from(_currentPage.strokes));
        _currentPage.strokes = _undoStack.removeLast();
      });
      _saveChanges();
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _undoStack.add(List<DrawnStroke>.from(_currentPage.strokes));
        _currentPage.strokes = _redoStack.removeLast();
      });
      _saveChanges();
    }
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
        _currentPaper = _currentPage.paperTypeOverride ?? widget.journal.defaultPaper;
        _undoStack.clear();
        _redoStack.clear();
      });
    }
  }

  void _goToNextPage() {
    if (_currentPageIndex < widget.journal.pages.length - 1) {
      setState(() {
        _currentPageIndex++;
        _currentPaper = _currentPage.paperTypeOverride ?? widget.journal.defaultPaper;
        _undoStack.clear();
        _redoStack.clear();
      });
    } else {
      // Add a new page seamlessly!
      final newPage = JournalPage(
        id: _uuid.v4(),
        pageIndex: widget.journal.pages.length,
        paperTypeOverride: widget.journal.defaultPaper,
      );
      setState(() {
        widget.journal.pages.add(newPage);
        _currentPageIndex = widget.journal.pages.length - 1;
        _currentPaper = widget.journal.defaultPaper;
        _undoStack.clear();
        _redoStack.clear();
      });
      _saveChanges();
    }
  }

  void _toggleBookmark() {
    setState(() {
      _currentPage.isBookmarked = !_currentPage.isBookmarked;
    });
    _saveChanges();
  }

  void _showAddTextModal() {
    final textController = TextEditingController();
    String selectedFont = 'Caveat';
    double selectedSize = 24.0;
    Color textColor = _activeColor;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Insert Dynamic Text Block', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 3,
                  autofocus: true,
                  style: GoogleFonts.getFont(selectedFont, fontSize: selectedSize, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts, affirmation, or header...',
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Handwriting & Modern Fonts:', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: ['Caveat', 'Kalam', 'Dancing Script', 'Patrick Hand', 'Playfair Display', 'Outfit'].map((f) {
                    final isSel = selectedFont == f;
                    return ChoiceChip(
                      label: Text(f, style: GoogleFonts.getFont(f, fontSize: 13)),
                      selected: isSel,
                      selectedColor: const Color(0xFFB5838D),
                      labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87),
                      onSelected: (_) => setDialogState(() => selectedFont = f),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Size: ${selectedSize.round()}pt', style: GoogleFonts.outfit(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: selectedSize,
                        min: 14.0,
                        max: 48.0,
                        activeColor: const Color(0xFFB5838D),
                        onChanged: (val) => setDialogState(() => selectedSize = val),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A9D8F), foregroundColor: Colors.white),
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  final element = PageElement(
                    id: _uuid.v4(),
                    type: ElementType.text,
                    x: 200,
                    y: 200,
                    width: 320,
                    height: 80,
                    textContent: text,
                    fontFamily: selectedFont,
                    fontSize: selectedSize,
                    textColor: textColor.toARGB32(),
                  );
                  setState(() {
                    _currentPage.elements.add(element);
                  });
                  _saveChanges();
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Add to Canvas'),
            ),
          ],
        ),
      ),
    );
  }

  void _openPageManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.88,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: PageManagerModal(
            journal: widget.journal,
            currentPageIndex: _currentPageIndex,
            onSelectPage: (idx) {
              setState(() {
                _currentPageIndex = idx;
                _currentPaper = _currentPage.paperTypeOverride ?? widget.journal.defaultPaper;
                _undoStack.clear();
                _redoStack.clear();
              });
            },
            onJournalUpdated: (updatedJournal) {
              setState(() {
                _saveChanges();
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0ECE1), // studio desk wooden warmth
      body: Stack(
        children: [
          // 1. Studio Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 56,
            child: _buildTopBar(),
          ),

          // 2. Interactive Canvas
          Positioned(
            top: 56,
            left: 0,
            right: 0,
            bottom: 50,
            child: InteractiveCanvas(
              page: _currentPage,
              secondPage: _secondPage,
              isDoubleSpread: _isDoubleSpread,
              paperType: _currentPaper,
              currentTool: _activeTool,
              currentColor: _activeColor,
              currentStrokeWidth: _activeStrokeWidth,
              currentOpacity: _activeOpacity,
              isSmartShapeEnabled: _isSmartShapeEnabled,
              isSnapToGrid: _isSnapToGrid,
              onStrokeCompleted: _onStrokeCompleted,
              onStrokesUpdated: _onStrokesUpdated,
              onElementsUpdated: _onElementsUpdated,
              onUndo: _undo,
              onRedo: _redo,
            ),
          ),

          // 3. Bottom Page Flipper Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 50,
            child: _buildBottomPageBar(),
          ),

          // 4. Floating Studio Toolbar (docked near bottom)
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Center(
              child: StudioToolbar(
                activeTool: _activeTool,
                activeColor: _activeColor,
                activeStrokeWidth: _activeStrokeWidth,
                activeOpacity: _activeOpacity,
                isSmartShapeEnabled: _isSmartShapeEnabled,
                isSnapToGrid: _isSnapToGrid,
                currentPaper: _currentPaper,
                onSelectTool: (tool) => setState(() => _activeTool = tool),
                onSelectColor: (c) => setState(() => _activeColor = c),
                onSelectStrokeWidth: (w) => setState(() => _activeStrokeWidth = w),
                onSelectOpacity: (o) => setState(() => _activeOpacity = o),
                onToggleSmartShape: (s) => setState(() => _isSmartShapeEnabled = s),
                onToggleSnapToGrid: (g) => setState(() => _isSnapToGrid = g),
                onSelectPaper: (p) {
                  setState(() {
                    _currentPaper = p;
                    _currentPage.paperTypeOverride = p;
                  });
                  _saveChanges();
                },
                onAddText: _showAddTextModal,
                onOpenAssetLibrary: () => setState(() => _isAssetDrawerOpen = true),
                onOpenPageManager: _openPageManager,
                onUndo: _undoStack.isNotEmpty ? _undo : null,
                onRedo: _redoStack.isNotEmpty ? _redo : null,
                onExport: () => ExportService.showExportDialog(context, widget.journal, _currentPageIndex),
              ),
            ),
          ),

          // 5. Sliding Studio Asset Library Drawer
          if (_isAssetDrawerOpen)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: AssetLibraryDrawer(
                onAddElement: (element) {
                  setState(() {
                    _currentPage.elements.add(element);
                  });
                  _saveChanges();
                },
                onClose: () => setState(() => _isAssetDrawerOpen = false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        border: const Border(bottom: BorderSide(color: Color(0xFFE5DFD5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button to Bookshelf & Journal Title
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF2C3E50)),
                tooltip: 'Return to Bookshelf',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Text(
                widget.journal.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A9D8F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '100% UNLOCKED',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2A9D8F),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          // Right: Double spread toggle & Bookmark
          Row(
            children: [
              // Double page spread mode toggle
              IconButton(
                icon: Icon(
                  _isDoubleSpread ? Icons.auto_stories : Icons.menu_book_outlined,
                  size: 20,
                  color: _isDoubleSpread ? const Color(0xFFB5838D) : const Color(0xFF6C757D),
                ),
                tooltip: _isDoubleSpread ? 'Single Page View' : 'Two-Page Spread View',
                onPressed: () {
                  setState(() {
                    _isDoubleSpread = !_isDoubleSpread;
                  });
                },
              ),
              // Bookmark
              IconButton(
                icon: Icon(
                  _currentPage.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _currentPage.isBookmarked ? const Color(0xFFE07A5F) : const Color(0xFF6C757D),
                  size: 22,
                ),
                tooltip: _currentPage.isBookmarked ? 'Bookmarked' : 'Add Bookmark',
                onPressed: _toggleBookmark,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.grid_view, size: 20, color: Color(0xFF2C3E50)),
                tooltip: 'Bird\'s-Eye Page Manager',
                onPressed: _openPageManager,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPageBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        border: Border(top: BorderSide(color: Color(0xFFE5DFD5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          TextButton.icon(
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Previous'),
            style: TextButton.styleFrom(
              foregroundColor: _currentPageIndex > 0 ? const Color(0xFF2C3E50) : const Color(0xFFADB5BD),
            ),
            onPressed: _currentPageIndex > 0 ? _goToPreviousPage : null,
          ),

          // Page counter & jump indicator
          GestureDetector(
            onTap: _openPageManager,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E5DC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Page ${_currentPageIndex + 1} of ${widget.journal.pages.length}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ),
          ),

          // Next button
          TextButton.icon(
            icon: const Text('Next'),
            label: const Icon(Icons.arrow_forward, size: 16),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2C3E50),
            ),
            onPressed: _goToNextPage,
          ),
        ],
      ),
    );
  }
}
