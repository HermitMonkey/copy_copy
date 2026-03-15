import 'package:flutter/material.dart';
import '../models/clipboard_item.dart';
import '../services/audio_service.dart';
import '../services/license_service.dart';

class SidebarFeed extends StatelessWidget {
  final bool isDark;
  final List<ClipboardItem> history;
  final ClipboardItem? selectedItem;
  final bool isPinned;
  final VoidCallback onTogglePin;
  final Function(ClipboardItem) onItemSelected;
  final VoidCallback onShowSettings;
  final VoidCallback onHide;

  // Search and Routing State
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String? activeCategory;
  final VoidCallback onClearCategory;

  // 🛠 NEW: Delete callback
  final Function(int) onDeleteItem;

  const SidebarFeed({
    super.key,
    required this.isDark,
    required this.history,
    required this.selectedItem,
    required this.isPinned,
    required this.onTogglePin,
    required this.onItemSelected,
    required this.onShowSettings,
    required this.onHide,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.activeCategory,
    required this.onClearCategory,
    required this.onDeleteItem, // 🛠 Added to constructor!
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161618) : Colors.white,
        border: Border(
          right: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
            child: Row(
              children: [
                const Icon(
                  Icons.layers_outlined,
                  color: Colors.deepPurpleAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  "copy_copy",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                ),
              ],
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Search clips...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ACTIVE FOLDER CHIP
          if (activeCategory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: InputChip(
                label: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    activeCategory!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: onClearCategory,
                backgroundColor: Colors.deepPurpleAccent.withOpacity(0.2),
                labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: Text(
              "RAW FEED",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.5,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final bool isSelected = selectedItem?.id == item.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  // 🛠 FIX: Wrapped the ListTile in the Dismissible widget!
                  child: Dismissible(
                    key: ValueKey(item.id),
                    direction:
                        DismissDirection.endToStart, // Swipe right to left
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) {
                      AudioService.playThwack();
                      onDeleteItem(item.id);
                    },
                    child: ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: item.faviconUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                item.faviconUrl!,
                                width: 18,
                                height: 18,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.link, size: 18),
                              ),
                            )
                          : Icon(
                              _iconForType(item.contentType),
                              size: 18,
                              color: _colorForType(item.contentType),
                            ),
                      title: Text(
                        item.title ?? "Copied Content",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        item.timestamp.toString().substring(11, 16),
                        style: const TextStyle(fontSize: 10),
                      ),
                      onTap: () => onItemSelected(item),
                    ),
                  ),
                );
              },
            ),
          ),

          // Free-tier progress indicator
          if (!LicenseService.isPro)
            _FreeTierBar(isDark: isDark, count: history.length),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  onPressed: onShowSettings,
                  tooltip: "Settings",
                ),
                IconButton(
                  icon: Icon(
                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 20,
                    color: isPinned ? Colors.deepPurpleAccent : null,
                  ),
                  onPressed: onTogglePin,
                  tooltip: isPinned ? "Unpin Window" : "Pin to Foreground",
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_fullscreen_outlined, size: 20),
                  onPressed: onHide,
                  tooltip: "Hide Workspace",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Maps content types to intuitive icons.
IconData _iconForType(String? type) {
  switch (type) {
    case 'url':
      return Icons.link_rounded;
    case 'code':
      return Icons.code_rounded;
    case 'note':
      return Icons.edit_note_rounded;
    default:
      return Icons.content_paste_rounded;
  }
}

// Maps content types to accent colours.
Color _colorForType(String? type) {
  switch (type) {
    case 'url':
      return Colors.blueAccent;
    case 'code':
      return Colors.greenAccent;
    case 'note':
      return Colors.orangeAccent;
    default:
      return Colors.deepPurpleAccent;
  }
}

/// A slim progress bar that appears at the bottom of the sidebar when the user
/// is on the free tier, nudging them towards a Pro upgrade.
class _FreeTierBar extends StatelessWidget {
  final bool isDark;
  final int count;

  const _FreeTierBar({required this.isDark, required this.count});

  @override
  Widget build(BuildContext context) {
    final limit = LicenseService.freeHistoryLimit;
    final fraction = (count / limit).clamp(0.0, 1.0);
    final isNearLimit = fraction >= 0.8;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 4,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              color: isNearLimit ? Colors.orangeAccent : Colors.deepPurpleAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isNearLimit
                ? '$count / $limit items — upgrade for unlimited ✨'
                : '$count / $limit items (free)',
            style: TextStyle(
              fontSize: 10,
              color: isNearLimit
                  ? Colors.orangeAccent
                  : (isDark ? Colors.white30 : Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}
