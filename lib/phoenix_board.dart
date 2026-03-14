import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'models/clipboard_item.dart';
import 'services/category_service.dart';
import 'services/audio_service.dart';

import 'widgets/sidebar_feed.dart';
import 'widgets/global_dashboard.dart';
import 'widgets/magazine_inspector.dart';
import 'widgets/settings_modal.dart'; // 🛠 NEW IMPORT

class PhoenixBoard extends StatefulWidget {
  final List<ClipboardItem> history;
  final VoidCallback onHide;
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final int currentTrayLimit;
  final Function(int) onTrayLimitChanged;

  // 🛠 NEW: Execution Callbacks
  final VoidCallback onNuclearReset;
  final Function(BuildContext) onExportJson;

  const PhoenixBoard({
    super.key,
    required this.history,
    required this.onHide,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.currentTrayLimit,
    required this.onTrayLimitChanged,
    required this.onNuclearReset,
    required this.onExportJson,
  });

  @override
  State<PhoenixBoard> createState() => _PhoenixBoardState();
}

class _PhoenixBoardState extends State<PhoenixBoard> {
  ClipboardItem? _selectedItem;
  bool _isPinned = false;
  String _searchQuery = '';
  String? _activeCategory;

  void _selectItemAndInspect(ClipboardItem item) {
    AudioService.playClick(); // 🎵 Audio Polish
    setState(() => _selectedItem = item);
  }

  void _backToDashboard() {
    AudioService.playClick(); // 🎵 Audio Polish
    setState(() {
      _selectedItem = null;
      _searchQuery = '';
    });
  }

  void _togglePin() async {
    AudioService.playClick(); // 🎵 Audio Polish
    setState(() => _isPinned = !_isPinned);
    await windowManager.setAlwaysOnTop(_isPinned);
  }

  List<ClipboardItem> get _filteredHistory {
    return widget.history.where((item) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final textMatches =
            item.content.toLowerCase().contains(query) ||
            (item.title?.toLowerCase().contains(query) ?? false) ||
            (item.articleText?.toLowerCase().contains(query) ?? false);
        if (!textMatches) return false;
      }
      if (_activeCategory != null) {
        if (!CategoryService.itemMatchesCategory(item, _activeCategory!))
          return false;
      }
      return true;
    }).toList();
  }

  void _showSettings(BuildContext context) {
    AudioService.playClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SettingsModal(
        currentThemeMode: widget.currentThemeMode,
        onThemeChanged: widget.onThemeChanged,
        currentTrayLimit: widget.currentTrayLimit,
        onTrayLimitChanged: widget.onTrayLimitChanged,
        onNuclearReset: widget.onNuclearReset,
        onExportJson: () => widget.onExportJson(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentFeed = _filteredHistory;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F11)
          : const Color(0xFFF4F5F7),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SidebarFeed(
            isDark: isDark,
            history: currentFeed,
            selectedItem: _selectedItem,
            isPinned: _isPinned,
            onTogglePin: _togglePin,
            onItemSelected: _selectItemAndInspect,
            onShowSettings: () => _showSettings(context),
            onHide: widget.onHide,
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() {
              _searchQuery = val;
              _selectedItem = null;
            }),
            activeCategory: _activeCategory,
            onClearCategory: () {
              AudioService.playClick();
              setState(() => _activeCategory = null);
            },
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedItem == null
                  ? GlobalDashboard(
                      history: widget.history,
                      isDark: isDark,
                      onCategorySelected: (category) {
                        AudioService.playClick(); // 🎵 Audio Polish
                        setState(() {
                          _activeCategory = category;
                          _selectedItem = null;
                        });
                      },
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
