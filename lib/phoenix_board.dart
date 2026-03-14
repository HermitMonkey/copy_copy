import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'models/clipboard_item.dart';
import 'services/category_service.dart';
import 'services/audio_service.dart';
import 'widgets/sidebar_feed.dart';
import 'widgets/global_dashboard.dart';
import 'widgets/magazine_inspector.dart';
import 'widgets/settings_modal.dart';

class PhoenixBoard extends StatefulWidget {
  final List<ClipboardItem> history;
  final VoidCallback onHide;
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final int currentTrayLimit;
  final Function(int) onTrayLimitChanged;
  final Function(BuildContext) onNuclearReset; // 🛠 Updated to take Context
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
    setState(() => _selectedItem = item); // 🛠 Muted standard nav
  }

  void _backToDashboard() {
    setState(() {
      _selectedItem = null;
      _searchQuery = '';
    }); // 🛠 Muted standard nav
  }

  void _togglePin() async {
    setState(() => _isPinned = !_isPinned);
    await windowManager.setAlwaysOnTop(_isPinned); // 🛠 Muted standard nav
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
    AudioService.playClick(); // Keep sound for opening settings
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SettingsModal(
        currentThemeMode: widget.currentThemeMode,
        onThemeChanged: widget.onThemeChanged,
        currentTrayLimit: widget.currentTrayLimit,
        onTrayLimitChanged: widget.onTrayLimitChanged,
        onNuclearReset: () =>
            widget.onNuclearReset(context), // Pass context here!
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
