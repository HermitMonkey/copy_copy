import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'models/clipboard_item.dart';
import 'models/smart_folder.dart'; // 🛠 NEW
import 'services/audio_service.dart';
import 'widgets/sidebar_feed.dart';
import 'widgets/global_dashboard.dart';
import 'widgets/magazine_inspector.dart';
import 'widgets/settings_modal.dart';

class PhoenixBoard extends StatefulWidget {
  final Function(int) onDeleteSingleItem; // 🛠 Add this
  final List<ClipboardItem> history;
  final List<SmartFolder> smartFolders; // 🛠 NEW
  final VoidCallback onHide;
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final int currentTrayLimit;
  final Function(int) onTrayLimitChanged;
  final Function(BuildContext) onNuclearReset;
  final Function(BuildContext) onExportJson;

  final Function(SmartFolder) onCreateFolder; // 🛠 NEW
  final Function(int) onDeleteFolder; // 🛠 NEW

  final Function(String, String) onSaveNote;

  const PhoenixBoard({
    super.key,
    required this.onDeleteSingleItem,
    required this.history,
    required this.smartFolders,
    required this.onHide,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.currentTrayLimit,
    required this.onTrayLimitChanged,
    required this.onNuclearReset,
    required this.onExportJson,
    required this.onCreateFolder,
    required this.onDeleteFolder,
    required this.onSaveNote,
  });

  @override
  State<PhoenixBoard> createState() => _PhoenixBoardState();
}

class _PhoenixBoardState extends State<PhoenixBoard> {
  ClipboardItem? _selectedItem;
  bool _isPinned = false;
  String _searchQuery = '';
  String? _activeCategory;

  void _selectItemAndInspect(ClipboardItem item) =>
      setState(() => _selectedItem = item);

  void _backToDashboard() => setState(() {
    _selectedItem = null;
    _searchQuery = '';
  });

  void _togglePin() async {
    setState(() => _isPinned = !_isPinned);
    await windowManager.setAlwaysOnTop(_isPinned);
  }

  void _handleDeleteSingleItem(int id) {
    // If we are inspecting the item we just deleted, close the inspector
    if (_selectedItem?.id == id) {
      setState(() => _selectedItem = null);
    }
    widget.onDeleteSingleItem(id);
  }

  // 🧠 THE NEW DYNAMIC FILTER ENGINE
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
        // Handle the built-in "Vault Notes" category separately
        if (_activeCategory == 'Vault Notes') {
          if (item.contentType != 'note') return false;
        } else {
          // Find the active Smart Folder object
          final folder = widget.smartFolders
              .where((f) => f.name == _activeCategory)
              .firstOrNull;
          if (folder == null) return false;

          final content = item.content.toLowerCase();
          final title = item.title?.toLowerCase() ?? '';
          final text = item.articleText?.toLowerCase() ?? '';

          bool matches = false;
          // Check if the item contains ANY of the trigger keywords
          for (var kw in folder.keywords) {
            if (kw.isEmpty) continue;
            if (content.contains(kw) ||
                title.contains(kw) ||
                text.contains(kw)) {
              matches = true;
              break;
            }
          }
          if (!matches) return false;
        }
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
        onNuclearReset: () => widget.onNuclearReset(context),
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
            onDeleteItem: _handleDeleteSingleItem,
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() {
              _searchQuery = val;
              _selectedItem = null;
            }),
            activeCategory: _activeCategory,
            onClearCategory: () => setState(() => _activeCategory = null),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedItem == null
                  ? GlobalDashboard(
                      history: widget.history,
                      smartFolders: widget.smartFolders, // 🛠 Passed down
                      isDark: isDark,
                      onCategorySelected: (category) {
                        setState(() {
                          _activeCategory = category;
                          _selectedItem = null;
                        });
                      },
                      onCreateFolder: widget.onCreateFolder, // 🛠 Passed down
                      onDeleteFolder: widget.onDeleteFolder, // 🛠 Passed down
                      onSaveNote: widget.onSaveNote, // 🛠 Add this!
                    )
                  : MagazineInspector(
                      item: _selectedItem!,
                      isDark: isDark,
                      onBack: _backToDashboard,
                      onDelete: () => _handleDeleteSingleItem(
                        _selectedItem!.id,
                      ), // 🛠 Pass it down
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
