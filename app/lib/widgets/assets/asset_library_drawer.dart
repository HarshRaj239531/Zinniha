import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../models/journal_models.dart';
import 'asset_data.dart';

class AssetLibraryDrawer extends StatefulWidget {
  final Function(PageElement) onAddElement;
  final VoidCallback onClose;

  const AssetLibraryDrawer({
    super.key,
    required this.onAddElement,
    required this.onClose,
  });

  @override
  State<AssetLibraryDrawer> createState() => _AssetLibraryDrawerState();
}

class _AssetLibraryDrawerState extends State<AssetLibraryDrawer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Uuid _uuid = const Uuid();
  String _searchQuery = '';
  String _selectedStickerFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addSticker(AssetMetadata item) {
    final element = PageElement(
      id: _uuid.v4(),
      type: ElementType.sticker,
      x: 250,
      y: 250,
      width: item.category == 'planner' ? 140 : 120,
      height: item.category == 'planner' ? 50 : 120,
      assetKey: item.id,
      category: item.category,
    );
    widget.onAddElement(element);
    _showAddedSnackbar(item.title);
  }

  void _addWashi(AssetMetadata item) {
    final element = PageElement(
      id: _uuid.v4(),
      type: ElementType.washi,
      x: 200,
      y: 150,
      width: 320,
      height: 44,
      assetKey: item.id,
      rotation: -0.02,
    );
    widget.onAddElement(element);
    _showAddedSnackbar(item.title);
  }

  void _addStickyNote(AssetMetadata item) {
    final element = PageElement(
      id: _uuid.v4(),
      type: ElementType.stickyNote,
      x: 220,
      y: 220,
      width: 240,
      height: 220,
      assetKey: item.id,
      textContent: 'Double tap to edit this note...',
      fontFamily: 'Caveat',
      fontSize: 19,
      rotation: -0.04,
    );
    widget.onAddElement(element);
    _showAddedSnackbar(item.title);
  }

  void _addPolaroid() {
    final element = PageElement(
      id: _uuid.v4(),
      type: ElementType.polaroid,
      x: 220,
      y: 200,
      width: 220,
      height: 260,
      assetKey: 'sticker_cherry_blossom',
      textContent: 'Cherished Moment ✨',
      fontFamily: 'Caveat',
      fontSize: 16,
      rotation: 0.04,
    );
    widget.onAddElement(element);
    _showAddedSnackbar('Polaroid Frame');
  }

  void _addTemplate(AssetMetadata item) {
    double w = 560;
    double h = 420;
    if (item.id == 'daily_planner') {
      h = 620;
    } else if (item.id == 'habit_tracker') {
      h = 360;
    } else if (item.id == 'mood_tracker') {
      h = 240;
    } else if (item.id == 'gratitude_log') {
      h = 360;
    } else if (item.id == 'weekly_spread') {
      h = 480;
    } else if (item.id == 'reading_log') {
      h = 320;
    }

    final element = PageElement(
      id: _uuid.v4(),
      type: ElementType.template,
      templateType: item.id,
      x: 120,
      y: 100,
      width: w,
      height: h,
    );
    widget.onAddElement(element);
    _showAddedSnackbar(item.title);
  }

  void _showAddedSnackbar(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$name" to canvas'),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2B3A42),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
        border: const Border(
          left: BorderSide(color: Color(0xFFE2DED6), width: 1.0),
        ),
      ),
      child: Column(
        children: [
          // Studio Drawer Header
          _buildHeader(),

          // Search Bar
          _buildSearchBar(),

          // Tabs: Templates, Stickers, Washi, Notes
          Container(
            color: const Color(0xFFF0ECE4),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: const Color(0xFF2C3E50),
              unselectedLabelColor: const Color(0xFF7F8C8D),
              indicatorColor: const Color(0xFFB5838D),
              indicatorWeight: 3.0,
              labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Templates'),
                Tab(text: 'Stickers'),
                Tab(text: 'Washi Tapes'),
                Tab(text: 'Notes & Frames'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemplatesTab(),
                _buildStickersTab(),
                _buildWashiTab(),
                _buildNotesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2DED6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFB5838D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFB5838D), size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zinnia Studio Library',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2B2D42),
                    ),
                  ),
                  Text(
                    'All Assets Unlocked & Free',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: const Color(0xFF2A9D8F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF495057)),
            onPressed: widget.onClose,
            tooltip: 'Close Studio Library',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDDD8CE)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim().toLowerCase();
            });
          },
          style: GoogleFonts.outfit(fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Search templates, stickers, washi...',
            hintStyle: TextStyle(fontSize: 12, color: Color(0xFFADB5BD)),
            prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF6C757D)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 9),
          ),
        ),
      ),
    );
  }

  // --- TEMPLATES TAB ---
  Widget _buildTemplatesTab() {
    final filtered = AssetLibrary.templates.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.title.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2DED6)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _addTemplate(item),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.previewColor.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon ?? Icons.dashboard_customize, color: const Color(0xFF4A4E69), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2B2D42)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Pre-designed interactive spread',
                          style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF8D99AE)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.add_circle_outline, color: Color(0xFFB5838D), size: 22),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- STICKERS TAB ---
  Widget _buildStickersTab() {
    final filters = ['all', 'botanical', 'planner', 'lifestyle'];

    final filtered = AssetLibrary.stickers.where((s) {
      if (_selectedStickerFilter != 'all' && s.category != _selectedStickerFilter) return false;
      if (_searchQuery.isNotEmpty && !s.title.toLowerCase().contains(_searchQuery)) return false;
      return true;
    }).toList();

    return Column(
      children: [
        // Category Pills
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: filters.map((f) {
              final isSel = _selectedStickerFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(f.toUpperCase()),
                  selected: isSel,
                  selectedColor: const Color(0xFFB5838D),
                  labelStyle: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSel ? Colors.white : const Color(0xFF4A4E69),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedStickerFilter = f;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Sticker Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final item = filtered[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _addSticker(item),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2DED6)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CustomPaint(
                          painter: StickerPainter(stickerId: item.id),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF495057)),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- WASHI TAB ---
  Widget _buildWashiTab() {
    final filtered = AssetLibrary.washiTapes.where((w) {
      if (_searchQuery.isEmpty) return true;
      return w.title.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFE2DED6)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _addWashi(item),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2B2D42)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: CustomPaint(
                      painter: WashiTapePainter(washiId: item.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- NOTES & FRAMES TAB ---
  Widget _buildNotesTab() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Polaroid Frame Section
        Text(
          'PHOTO FRAMES',
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFF6C757D)),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFFE2DED6)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _addPolaroid,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFCED4DA)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(color: const Color(0xFFE9ECEF)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Polaroid Photo Card', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text('Add memories, photos & handwritten captions', style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF8D99AE))),
                      ],
                    ),
                  ),
                  const Icon(Icons.add_circle_outline, color: Color(0xFFB5838D)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Sticky Notes Section
        Text(
          'STICKY NOTES',
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFF6C757D)),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: AssetLibrary.stickyNotes.length,
          itemBuilder: (context, index) {
            final item = AssetLibrary.stickyNotes[index];
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _addStickyNote(item),
              child: Container(
                decoration: BoxDecoration(
                  color: item.previewColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Note...',
                      style: GoogleFonts.caveat(fontSize: 14, color: const Color(0xFF2F3E46)),
                    ),
                    Text(
                      item.title,
                      style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF495057)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
