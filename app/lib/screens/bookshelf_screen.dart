import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_models.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import 'anime_intro_screen.dart';
import 'journal_canvas_screen.dart';

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  static const Uuid _uuid = Uuid();

  List<Journal> _journals = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() => _isLoading = true);
    final list = await StorageService.loadJournals();
    setState(() {
      _journals = list;
      _isLoading = false;
    });
  }

  Future<void> _saveJournals() async {
    await StorageService.saveJournals(_journals);
  }

  void _openJournal(Journal journal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JournalCanvasScreen(
          journal: journal,
          allJournals: _journals,
        ),
      ),
    ).then((_) {
      setState(() {});
      _saveJournals();
    });
  }

  void _createNewJournalDialog() {
    final titleController = TextEditingController(text: 'My New Journal');
    CoverTexture selectedTexture = CoverTexture.leather;
    int coverColor = 0xFF5D4037;
    PaperType selectedPaper = PaperType.dotGrid;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Create New Journal',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Journal Title', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Travel Memoir, 2026 Goals...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text('Cover Texture Style', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CoverTexture.values.map((t) {
                      final isSel = selectedTexture == t;
                      return ChoiceChip(
                        label: Text(t.name.toUpperCase()),
                        selected: isSel,
                        selectedColor: const Color(0xFFB5838D),
                        labelStyle: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : const Color(0xFF2C3E50),
                        ),
                        onSelected: (_) {
                          setDialogState(() {
                            selectedTexture = t;
                            if (t == CoverTexture.leather) coverColor = 0xFF4A3525;
                            if (t == CoverTexture.botanical) coverColor = 0xFF2D4B39;
                            if (t == CoverTexture.floral) coverColor = 0xFF9E4770;
                            if (t == CoverTexture.darkLuxury) coverColor = 0xFF1E2229;
                            if (t == CoverTexture.pastelMarble) coverColor = 0xFFD8B4E2;
                            if (t == CoverTexture.minimalCharcoal) coverColor = 0xFF2B2D42;
                            if (t == CoverTexture.linen) coverColor = 0xFFC9ADA7;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  Text('Default Paper Style', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [PaperType.dotGrid, PaperType.lined, PaperType.squareGrid, PaperType.vintageKraft, PaperType.darkDots].map((p) {
                      final isSel = selectedPaper == p;
                      return ChoiceChip(
                        label: Text(p.name),
                        selected: isSel,
                        selectedColor: const Color(0xFF2A9D8F),
                        labelStyle: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : const Color(0xFF2C3E50),
                        ),
                        onSelected: (_) => setDialogState(() => selectedPaper = p),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A9D8F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final title = titleController.text.trim().isEmpty ? 'Untitled Journal' : titleController.text.trim();
                final newJournal = Journal(
                  id: _uuid.v4(),
                  title: title,
                  coverTexture: selectedTexture,
                  coverColorValue: coverColor,
                  defaultPaper: selectedPaper,
                  pages: [
                    JournalPage(
                      id: _uuid.v4(),
                      pageIndex: 0,
                      paperTypeOverride: selectedPaper,
                    ),
                  ],
                );
                setState(() {
                  _journals.insert(0, newJournal);
                });
                _saveJournals();
                Navigator.of(ctx).pop();
                _openJournal(newJournal);
              },
              child: const Text('Create Journal'),
            ),
          ],
        ),
      ),
    );
  }

  void _duplicateJournal(Journal journal) {
    final duplicated = Journal(
      id: _uuid.v4(),
      title: '${journal.title} (Copy)',
      coverTexture: journal.coverTexture,
      coverColorValue: journal.coverColorValue,
      accentColorValue: journal.accentColorValue,
      ribbonColorValue: journal.ribbonColorValue,
      defaultPaper: journal.defaultPaper,
      pages: journal.pages.map((p) {
        return JournalPage(
          id: _uuid.v4(),
          pageIndex: p.pageIndex,
          paperTypeOverride: p.paperTypeOverride,
          isBookmarked: p.isBookmarked,
          strokes: p.strokes.map((s) => s.copyWith(id: _uuid.v4())).toList(),
          elements: p.elements.map((e) => e.clone(_uuid.v4())).toList(),
        );
      }).toList(),
    );

    setState(() {
      _journals.add(duplicated);
    });
    _saveJournals();
  }

  void _deleteJournal(Journal journal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Journal?'),
        content: Text('Are you sure you want to delete "${journal.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _journals.remove(journal);
              });
              _saveJournals();
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _journals.where((j) {
      if (_searchQuery.isEmpty) return true;
      return j.title.toLowerCase().contains(_searchQuery);
    }).toList();

    final isNarrow = MediaQuery.of(context).size.width < 600;
    final hPadding = isNarrow ? 16.0 : 40.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5EE), // Studio warm neutral
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Studio Header App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 6,
                              children: [
                                Text(
                                  'Harsh Studio',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2A9D8F), Color(0xFF52B788)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'FREE & UNLOCKED',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tactile Digital Journaling, Planning & Art. All templates, washi, and stickers unlocked.',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: const Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Watch Anime Intro',
                            child: IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFE2B867).withValues(alpha: 0.18),
                                foregroundColor: const Color(0xFF9E6D17),
                                padding: const EdgeInsets.all(14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.movie_creation_outlined, size: 22),
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (ctx, anim, secAnim) => const AnimeIntroScreen(),
                                    transitionsBuilder: (ctx, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C3E50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 3,
                            ),
                            icon: const Icon(Icons.add, size: 20),
                            label: Text(
                              'New Journal',
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _createNewJournalDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search bar
                  Container(
                    height: 44,
                    width: 380,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2DDD3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      style: GoogleFonts.outfit(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search journals, notebooks...',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFFADB5BD)),
                        prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF6C757D)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Bookshelf Shelves & Notebooks Grid
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F))),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No journals found. Tap "New Journal" to begin!',
                  style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPadding, 8, hPadding, 60),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  crossAxisSpacing: 28,
                  mainAxisSpacing: 36,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final journal = filtered[index];
                    return _buildNotebookCard(journal);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
        ),
    );
  }

  Widget _buildNotebookCard(Journal journal) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openJournal(journal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D Physical Notebook Cover
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(8),
                  right: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(4, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Cover Texture Background
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(8),
                        right: Radius.circular(16),
                      ),
                      child: _buildCoverTexture(journal),
                    ),
                  ),

                  // Spine Binding shadow on left
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Spine Stitches Line
                  Positioned(
                    left: 20,
                    top: 10,
                    bottom: 10,
                    child: CustomPaint(
                      size: const Size(2, double.infinity),
                      painter: _StitchPainter(),
                    ),
                  ),

                  // Embossed Foil Title Badge in center
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: journal.accentColor,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            journal.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 1.5,
                            width: 32,
                            color: journal.accentColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${journal.pages.length} PAGES',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Ribbon bookmark hanging from bottom
                  Positioned(
                    bottom: -6,
                    right: 32,
                    child: Container(
                      width: 18,
                      height: 38,
                      decoration: BoxDecoration(
                        color: journal.ribbonColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Context menu at top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18, color: Colors.white),
                        padding: EdgeInsets.zero,
                        onSelected: (val) {
                          if (val == 'dup') _duplicateJournal(journal);
                          if (val == 'pdf') ExportService.exportJournalToPdf(context, journal);
                          if (val == 'del') _deleteJournal(journal);
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'dup', child: Text('Duplicate Journal')),
                          const PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
                          const PopupMenuItem(
                            value: 'del',
                            child: Text('Delete Journal', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Notebook label on shelf
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  journal.title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${journal.pages.length} pages',
                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF7F8C8D)),
              ),
            ],
          ),
          // Wooden Shelf beam underneath
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8D6E63), Color(0xFF6D4C41), Color(0xFF5D4037)],
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverTexture(Journal journal) {
    final color = journal.coverColor;

    switch (journal.coverTexture) {
      case CoverTexture.leather:
        return Container(
          color: color,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.9),
                  Colors.black.withValues(alpha: 0.35),
                ],
                radius: 1.2,
              ),
            ),
          ),
        );
      case CoverTexture.botanical:
        return Container(
          color: color,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.eco, size: 140, color: Colors.white.withValues(alpha: 0.08)),
              ),
              Positioned(
                left: -10,
                top: -10,
                child: Icon(Icons.spa, size: 110, color: Colors.white.withValues(alpha: 0.06)),
              ),
            ],
          ),
        );
      case CoverTexture.floral:
        return Container(
          color: color,
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: 20,
                child: Icon(Icons.local_florist, size: 120, color: Colors.white.withValues(alpha: 0.1)),
              ),
            ],
          ),
        );
      case CoverTexture.darkLuxury:
        return Container(
          color: const Color(0xFF1E2229),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFC0C0C0).withValues(alpha: 0.2), width: 6),
            ),
          ),
        );
      case CoverTexture.pastelMarble:
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD6E0), Color(0xFFC8B6FF), Color(0xFFB8C0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      case CoverTexture.minimalCharcoal:
        return Container(color: const Color(0xFF2B2D42));
      case CoverTexture.linen:
        return Container(color: const Color(0xFFB7B7A4));
    }
  }
}

class _StitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stitchPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.7)
      ..strokeWidth = 1.2;

    for (double y = 4; y < size.height - 4; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 4), stitchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
