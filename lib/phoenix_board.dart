import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'models/clipboard_item.dart';
import 'services/category_service.dart';

import 'widgets/sidebar_feed.dart';
import 'widgets/global_dashboard.dart';
import 'widgets/magazine_inspector.dart';

class PhoenixBoard extends StatefulWidget {
  final List<ClipboardItem> history;
  final VoidCallback onHide;
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final int currentTrayLimit;
  final Function(int) onTrayLimitChanged;

  const PhoenixBoard({
    super.key,
    required this.history,
    required this.onHide,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.currentTrayLimit,
    required this.onTrayLimitChanged,
  });

  @override
  State<PhoenixBoard> createState() => _PhoenixBoardState();
}

class _PhoenixBoardState extends State<PhoenixBoard> {
  ClipboardItem? _selectedItem;
  bool _isPinned = false;

  // 🛠 NEW: Routing and Search State
  String _searchQuery = '';
  String? _activeCategory;

  void _selectItemAndInspect(ClipboardItem item) =>
      setState(() => _selectedItem = item);

  void _backToDashboard() => setState(() {
    _selectedItem = null;
    _searchQuery = ''; // Clear search when returning
  });

  void _togglePin() async {
    setState(() => _isPinned = !_isPinned);
    await windowManager.setAlwaysOnTop(_isPinned);
  }

  // 🧠 THE FILTERING ENGINE (Zero Latency)
  List<ClipboardItem> get _filteredHistory {
    return widget.history.where((item) {
      // 1. Text Search Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final textMatches =
            item.content.toLowerCase().contains(query) ||
            (item.title?.toLowerCase().contains(query) ?? false) ||
            (item.articleText?.toLowerCase().contains(query) ?? false);
        if (!textMatches) return false;
      }

      // 2. Category Filter (using CategoryService to avoid hardcoding)
      if (_activeCategory != null) {
        if (!CategoryService.itemMatchesCategory(item, _activeCategory!)) {
          return false;
        }
      }
      return true; // Keep it if it passes all active filters
    }).toList();
  }

  void _showSettings(BuildContext context) {
    // ... (Keep your exact existing Settings Modal code here)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            const Text(
              "Appearance",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text("Light"),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.settings_display),
                    label: Text("System"),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text("Dark"),
                  ),
                ],
                selected: {widget.currentThemeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) =>
                    widget.onThemeChanged(newSelection.first),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "System Tray Menu",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 8, label: Text("8 Items")),
                  ButtonSegment(value: 15, label: Text("15 Items")),
                  ButtonSegment(value: 55, label: Text("55 Items")),
                ],
                selected: {
                  {8, 15, 55}.contains(widget.currentTrayLimit)
                      ? widget.currentTrayLimit
                      : 15,
                },
                onSelectionChanged: (Set<int> newSelection) =>
                    widget.onTrayLimitChanged(newSelection.first),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // We pass the filtered list down to the components
    final currentFeed = _filteredHistory;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F11)
          : const Color(0xFFF4F5F7),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. THE SIDEBAR
          SidebarFeed(
            isDark: isDark,
            history: currentFeed, // 🛠 Passes the filtered feed!
            selectedItem: _selectedItem,
            isPinned: _isPinned,
            onTogglePin: _togglePin,
            onItemSelected: _selectItemAndInspect,
            onShowSettings: () => _showSettings(context),
            onHide: () => windowManager.hide(),
            // 🛠 SEARCH & FILTER PROPS
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() {
              _searchQuery = val;
              _selectedItem = null; // Close inspector if they are searching
            }),
            activeCategory: _activeCategory,
            onClearCategory: () => setState(() => _activeCategory = null),
          ),

          // 2. THE MAIN STAGE
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedItem == null
                  ? GlobalDashboard(
                      history: widget
                          .history, // Dashboard analytics always reflect the FULL history
                      isDark: isDark,
                      onCategorySelected: (category) => setState(() {
                        _activeCategory = category;
                        _selectedItem = null;
                      }),
                    )
                  : MagazineInspector(
                      item: _selectedItem!,
                      isDark: isDark,
                      onBack: _backToDashboard,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
