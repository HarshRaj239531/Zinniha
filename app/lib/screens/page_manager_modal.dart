import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_models.dart';
import '../widgets/canvas/paper_painter.dart';

class PageManagerModal extends StatefulWidget {
  final Journal journal;
  final int currentPageIndex;
  final Function(int) onSelectPage;
  final Function(Journal) onJournalUpdated;

  const PageManagerModal({
    super.key,
    required this.journal,
    required this.currentPageIndex,
    required this.onSelectPage,
    required this.onJournalUpdated,
  });

  @override
  State<PageManagerModal> createState() => _PageManagerModalState();
}

class _PageManagerModalState extends State<PageManagerModal> {
  static const Uuid _uuid = Uuid();

  void _addNewPage(PaperType paperType) {
    setState(() {
      final newPage = JournalPage(
        id: _uuid.v4(),
        pageIndex: widget.journal.pages.length,
        paperTypeOverride: paperType,
      );
      widget.journal.pages.add(newPage);
      widget.journal.updatedAt = DateTime.now();
    });
    widget.onJournalUpdated(widget.journal);
  }

  void _duplicatePage(int index) {
    if (index < 0 || index >= widget.journal.pages.length) return;
    final source = widget.journal.pages[index];
    final duplicated = JournalPage(
      id: _uuid.v4(),
      pageIndex: index + 1,
      paperTypeOverride: source.paperTypeOverride,
      isBookmarked: source.isBookmarked,
      strokes: source.strokes.map((s) => s.copyWith(id: _uuid.v4())).toList(),
      elements: source.elements.map((e) => e.clone(_uuid.v4())).toList(),
    );

    setState(() {
      widget.journal.pages.insert(index + 1, duplicated);
      for (int i = 0; i < widget.journal.pages.length; i++) {
        widget.journal.pages[i].pageIndex = i;
      }
      widget.journal.updatedAt = DateTime.now();
    });
    widget.onJournalUpdated(widget.journal);
  }

  void _deletePage(int index) {
    if (widget.journal.pages.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A journal must have at least one page.')),
      );
      return;
    }

    setState(() {
      widget.journal.pages.removeAt(index);
      for (int i = 0; i < widget.journal.pages.length; i++) {
        widget.journal.pages[i].pageIndex = i;
      }
      widget.journal.updatedAt = DateTime.now();
    });
    widget.onJournalUpdated(widget.journal);
  }

  void _toggleBookmark(int index) {
    setState(() {
      widget.journal.pages[index].isBookmarked = !widget.journal.pages[index].isBookmarked;
      widget.journal.updatedAt = DateTime.now();
    });
    widget.onJournalUpdated(widget.journal);
  }

  void _movePage(int fromIndex, int toIndex) {
    if (toIndex < 0 || toIndex >= widget.journal.pages.length) return;
    setState(() {
      final page = widget.journal.pages.removeAt(fromIndex);
      widget.journal.pages.insert(toIndex, page);
      for (int i = 0; i < widget.journal.pages.length; i++) {
        widget.journal.pages[i].pageIndex = i;
      }
      widget.journal.updatedAt = DateTime.now();
    });
    widget.onJournalUpdated(widget.journal);
  }

  void _showAddPageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Choose Paper Style', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PaperType.values.map((p) {
            String name = 'Dot Grid';
            switch (p) {
              case PaperType.dotGrid:
                name = 'Dot Grid (Bullet Journal)';
                break;
              case PaperType.lined:
                name = 'Lined Paper (Notes & Writing)';
                break;
              case PaperType.squareGrid:
                name = 'Square Graph Grid (Planning)';
                break;
              case PaperType.darkDots:
                name = 'Midnight Dark Dots';
                break;
              case PaperType.vintageKraft:
                name = 'Vintage Kraft Parchment';
                break;
              case PaperType.blank:
                name = 'Blank Cream Sketch';
                break;
              case PaperType.watercolor:
                name = 'Watercolor Art Paper';
                break;
            }
            return ListTile(
              title: Text(name, style: GoogleFonts.outfit(fontSize: 14)),
              onTap: () {
                Navigator.of(ctx).pop();
                _addNewPage(p);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F4EE),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.journal.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    'Bird\'s-Eye Page Overview • ${widget.journal.pages.length} Pages',
                    style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF7F8C8D)),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A9D8F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text('Add Page', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    onPressed: _showAddPageDialog,
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24, color: Color(0xFF2C3E50)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pages Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.72,
              ),
              itemCount: widget.journal.pages.length,
              itemBuilder: (context, index) {
                final page = widget.journal.pages[index];
                final isCurrent = index == widget.currentPageIndex;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    widget.onSelectPage(index);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent ? const Color(0xFF2A9D8F) : const Color(0xFFDDD8CE),
                        width: isCurrent ? 2.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isCurrent ? 0.12 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Paper miniature
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CustomPaint(
                              painter: PaperPainter(
                                paperType: page.paperTypeOverride ?? widget.journal.defaultPaper,
                              ),
                            ),
                          ),
                        ),

                        // Stats overlay at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Page ${index + 1}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                    color: isCurrent ? const Color(0xFF2A9D8F) : const Color(0xFF2C3E50),
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (page.elements.isNotEmpty)
                                      Text(
                                        '${page.elements.length} items',
                                        style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF6C757D)),
                                      ),
                                    const SizedBox(width: 4),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 16, color: Color(0xFF495057)),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onSelected: (val) {
                                        if (val == 'dup') _duplicatePage(index);
                                        if (val == 'del') _deletePage(index);
                                        if (val == 'left') _movePage(index, index - 1);
                                        if (val == 'right') _movePage(index, index + 1);
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(value: 'dup', child: Text('Duplicate')),
                                        if (index > 0)
                                          const PopupMenuItem(value: 'left', child: Text('Move Left')),
                                        if (index < widget.journal.pages.length - 1)
                                          const PopupMenuItem(value: 'right', child: Text('Move Right')),
                                        const PopupMenuItem(
                                          value: 'del',
                                          child: Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bookmark ribbon at top right
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _toggleBookmark(index),
                            child: Icon(
                              page.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: page.isBookmarked ? const Color(0xFFE07A5F) : const Color(0xFFADB5BD),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
