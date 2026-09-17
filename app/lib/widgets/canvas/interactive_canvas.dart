import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/journal_models.dart';
import 'paper_painter.dart';
import 'canvas_painter.dart';
import 'element_renderer.dart';

class InteractiveCanvas extends StatefulWidget {
  final JournalPage page;
  final JournalPage? secondPage; // for double page spread mode
  final bool isDoubleSpread;
  final PaperType paperType;
  final StrokeToolType currentTool;
  final Color currentColor;
  final double currentStrokeWidth;
  final double currentOpacity;
  final bool isSmartShapeEnabled;
  final bool isSnapToGrid;
  final Function(DrawnStroke) onStrokeCompleted;
  final Function(List<DrawnStroke>) onStrokesUpdated;
  final Function(List<PageElement>) onElementsUpdated;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const InteractiveCanvas({
    super.key,
    required this.page,
    this.secondPage,
    this.isDoubleSpread = false,
    required this.paperType,
    required this.currentTool,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.currentOpacity,
    this.isSmartShapeEnabled = false,
    this.isSnapToGrid = false,
    required this.onStrokeCompleted,
    required this.onStrokesUpdated,
    required this.onElementsUpdated,
    this.onUndo,
    this.onRedo,
  });

  @override
  State<InteractiveCanvas> createState() => _InteractiveCanvasState();
}

class _InteractiveCanvasState extends State<InteractiveCanvas> {
  final TransformationController _transformController = TransformationController();
  static const Uuid _uuid = Uuid();

  // Active in-progress stroke
  DrawnStroke? _activeStroke;
  PageElement? _selectedElement;

  // Element transform tracking
  Offset? _dragStartOffset;
  Offset? _elementInitialPos;
  double? _initialElementWidth;
  double? _initialElementHeight;
  double? _initialRotation;

  // Page standard dimensions (A5 / iPad aspect ratio)
  static const double pageWidth = 800.0;
  static const double pageHeight = 1050.0;

  bool get _isDrawingTool =>
      widget.currentTool == StrokeToolType.pen ||
      widget.currentTool == StrokeToolType.fountainPen ||
      widget.currentTool == StrokeToolType.ballpoint ||
      widget.currentTool == StrokeToolType.pencil ||
      widget.currentTool == StrokeToolType.highlighter ||
      widget.currentTool == StrokeToolType.eraser;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _onDrawingPanStart(DragStartDetails details) {
    if (!_isDrawingTool) return;

    final localPos = details.localPosition;

    if (widget.currentTool == StrokeToolType.eraser) {
      _eraseAtPoint(localPos);
      return;
    }

    setState(() {
      _activeStroke = DrawnStroke(
        id: _uuid.v4(),
        toolType: widget.currentTool,
        colorValue: widget.currentColor.toARGB32(),
        strokeWidth: widget.currentStrokeWidth,
        opacity: widget.currentOpacity,
        points: [StrokePoint(x: localPos.dx, y: localPos.dy)],
      );
    });
  }

  void _onDrawingPanUpdate(DragUpdateDetails details) {
    if (!_isDrawingTool) return;

    final localPos = details.localPosition;

    if (widget.currentTool == StrokeToolType.eraser) {
      _eraseAtPoint(localPos);
      return;
    }

    if (_activeStroke != null) {
      setState(() {
        _activeStroke!.points.add(StrokePoint(x: localPos.dx, y: localPos.dy));
      });
    }
  }

  void _onDrawingPanEnd(DragEndDetails details) {
    if (_activeStroke != null && _activeStroke!.points.isNotEmpty) {
      DrawnStroke finalStroke = _activeStroke!;

      if (widget.isSmartShapeEnabled) {
        final recognizedShape = ShapeRecognizer.detectShape(finalStroke.points);
        if (recognizedShape != null) {
          finalStroke = finalStroke.copyWith(
            isGeometric: true,
            geometricShape: recognizedShape,
          );
        }
      }

      widget.onStrokeCompleted(finalStroke);
      setState(() {
        _activeStroke = null;
      });
    }
  }

  void _eraseAtPoint(Offset point) {
    final strokeRadius = widget.currentStrokeWidth * 1.5;
    final updatedStrokes = List<DrawnStroke>.from(widget.page.strokes);
    bool changed = false;

    updatedStrokes.removeWhere((stroke) {
      for (final p in stroke.points) {
        if ((Offset(p.x, p.y) - point).distance <= strokeRadius) {
          changed = true;
          return true;
        }
      }
      return false;
    });

    if (changed) {
      widget.onStrokesUpdated(updatedStrokes);
    }
  }

  void _selectElement(PageElement element) {
    setState(() {
      _selectedElement = element;
    });
  }

  void _deselectAll() {
    if (_selectedElement != null) {
      setState(() {
        _selectedElement = null;
      });
    }
  }

  void _bringToFront(PageElement element) {
    final list = List<PageElement>.from(widget.page.elements);
    list.remove(element);
    list.add(element);
    for (int i = 0; i < list.length; i++) {
      list[i].zIndex = i;
    }
    widget.onElementsUpdated(list);
    setState(() {});
  }

  void _sendToBack(PageElement element) {
    final list = List<PageElement>.from(widget.page.elements);
    list.remove(element);
    list.insert(0, element);
    for (int i = 0; i < list.length; i++) {
      list[i].zIndex = i;
    }
    widget.onElementsUpdated(list);
    setState(() {});
  }

  void _duplicateElement(PageElement element) {
    final clone = element.clone(_uuid.v4());
    final list = List<PageElement>.from(widget.page.elements)..add(clone);
    widget.onElementsUpdated(list);
    setState(() {
      _selectedElement = clone;
    });
  }

  void _deleteElement(PageElement element) {
    final list = List<PageElement>.from(widget.page.elements)..remove(element);
    widget.onElementsUpdated(list);
    setState(() {
      if (_selectedElement?.id == element.id) {
        _selectedElement = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double totalCanvasWidth = widget.isDoubleSpread ? (pageWidth * 2 + 20) : pageWidth;
    final double totalCanvasHeight = pageHeight;

    return GestureDetector(
      onTap: _deselectAll,
      child: Container(
        color: const Color(0xFFF3F0E6), // Studio desk warm cream/wood background
        child: LayoutBuilder(
          builder: (context, constraints) {
            return InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.15,
              maxScale: 10.0, // 1000% zoom capability!
              panEnabled: !_isDrawingTool,
              scaleEnabled: true,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(800),
              child: SizedBox(
                width: totalCanvasWidth,
                height: totalCanvasHeight,
                child: widget.isDoubleSpread
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSinglePageContainer(widget.page, isLeftSpread: true),
                          const SizedBox(width: 20),
                          if (widget.secondPage != null)
                            _buildSinglePageContainer(widget.secondPage!, isLeftSpread: false),
                        ],
                      )
                    : _buildSinglePageContainer(widget.page),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSinglePageContainer(JournalPage page, {bool isLeftSpread = false}) {
    return Container(
      width: pageWidth,
      height: pageHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.horizontal(
          left: isLeftSpread ? const Radius.circular(8) : Radius.zero,
          right: !isLeftSpread ? const Radius.circular(8) : Radius.zero,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // 1. Paper Background
            Positioned.fill(
              child: CustomPaint(
                painter: PaperPainter(
                  paperType: page.paperTypeOverride ?? widget.paperType,
                ),
              ),
            ),

            // 2. Elements Layer
            Positioned.fill(
              child: Stack(
                children: page.elements.map((el) => _buildPositionedElement(el)).toList(),
              ),
            ),

            // 3. Drawing Strokes Layer
            Positioned.fill(
              child: GestureDetector(
                behavior: _isDrawingTool ? HitTestBehavior.opaque : HitTestBehavior.translucent,
                onPanStart: _isDrawingTool ? _onDrawingPanStart : null,
                onPanUpdate: _isDrawingTool ? _onDrawingPanUpdate : null,
                onPanEnd: _isDrawingTool ? _onDrawingPanEnd : null,
                child: CustomPaint(
                  painter: CanvasPainter(
                    strokes: page.strokes,
                    activeStroke: _activeStroke,
                  ),
                ),
              ),
            ),

            // 4. Selected Element Bounding Box & Action Menu
            if (_selectedElement != null && !_isDrawingTool)
              _buildSelectionOverlay(_selectedElement!),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionedElement(PageElement element) {
    return Positioned(
      left: element.x,
      top: element.y,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_isDrawingTool) {
            _selectElement(element);
          }
        },
        child: ElementRenderer(
          element: element,
          isSelected: _selectedElement?.id == element.id,
          onSelect: () => _selectElement(element),
          onUpdate: (updated) {
            final list = List<PageElement>.from(widget.page.elements);
            final idx = list.indexWhere((e) => e.id == updated.id);
            if (idx != -1) {
              list[idx] = updated;
              widget.onElementsUpdated(list);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay(PageElement element) {
    final isLocked = element.isLocked;

    return Positioned(
      left: element.x - 10,
      top: element.y - 45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.flip_to_front, size: 16, color: Colors.white),
                  tooltip: 'Bring to Front',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => _bringToFront(element),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_to_back, size: 16, color: Colors.white),
                  tooltip: 'Send to Back',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => _sendToBack(element),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                  tooltip: 'Duplicate',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => _duplicateElement(element),
                ),
                IconButton(
                  icon: Icon(isLocked ? Icons.lock : Icons.lock_open, size: 16, color: isLocked ? Colors.amber : Colors.white),
                  tooltip: isLocked ? 'Unlock' : 'Lock',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () {
                    setState(() {
                      element.isLocked = !element.isLocked;
                    });
                    widget.onElementsUpdated(widget.page.elements);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFFF6B6B)),
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => _deleteElement(element),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Selection dashed border container with drag and resize handles
          GestureDetector(
            onPanStart: (details) {
              if (element.isLocked) return;
              _dragStartOffset = details.globalPosition;
              _elementInitialPos = Offset(element.x, element.y);
            },
            onPanUpdate: (details) {
              if (element.isLocked || _dragStartOffset == null || _elementInitialPos == null) return;
              final delta = details.globalPosition - _dragStartOffset!;
              double newX = _elementInitialPos!.dx + delta.dx;
              double newY = _elementInitialPos!.dy + delta.dy;

              if (widget.isSnapToGrid) {
                const grid = 26.0;
                newX = (newX / grid).round() * grid;
                newY = (newY / grid).round() * grid;
              }

              setState(() {
                element.x = newX;
                element.y = newY;
              });
            },
            onPanEnd: (details) {
              _dragStartOffset = null;
              _elementInitialPos = null;
              widget.onElementsUpdated(widget.page.elements);
            },
            child: Container(
              width: element.width + 20,
              height: element.height + 20,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2B70C9), width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  // Bottom right resize handle
                  if (!element.isLocked)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onPanStart: (details) {
                          _dragStartOffset = details.globalPosition;
                          _initialElementWidth = element.width;
                          _initialElementHeight = element.height;
                        },
                        onPanUpdate: (details) {
                          if (_dragStartOffset == null || _initialElementWidth == null || _initialElementHeight == null) return;
                          final delta = details.globalPosition - _dragStartOffset!;
                          setState(() {
                            element.width = math.max(60.0, _initialElementWidth! + delta.dx);
                            element.height = math.max(40.0, _initialElementHeight! + delta.dy);
                          });
                        },
                        onPanEnd: (details) {
                          _dragStartOffset = null;
                          _initialElementWidth = null;
                          _initialElementHeight = null;
                          widget.onElementsUpdated(widget.page.elements);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2B70C9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.crop_free, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  // Top right rotate handle
                  if (!element.isLocked)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onPanStart: (details) {
                          _dragStartOffset = details.globalPosition;
                          _initialRotation = element.rotation;
                        },
                        onPanUpdate: (details) {
                          if (_dragStartOffset == null || _initialRotation == null) return;
                          final delta = details.globalPosition - _dragStartOffset!;
                          setState(() {
                            element.rotation = _initialRotation! + (delta.dx / 100);
                          });
                        },
                        onPanEnd: (details) {
                          _dragStartOffset = null;
                          _initialRotation = null;
                          widget.onElementsUpdated(widget.page.elements);
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2B70C9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.refresh, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
