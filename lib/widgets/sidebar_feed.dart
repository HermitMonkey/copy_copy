import 'package:flutter/material.dart';
import '../models/clipboard_item.dart';

class SidebarFeed extends StatelessWidget {
  final bool isDark;
  final List<ClipboardItem> history;
  final ClipboardItem? selectedItem;
  final bool isPinned;
  final VoidCallback onTogglePin;
  final Function(ClipboardItem) onItemSelected;
  final VoidCallback onShowSettings;
  final VoidCallback onHide;

  // 🛠 NEW: Search and Routing State
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final String? activeCategory;
  final VoidCallback onClearCategory;

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

          // 🛠 NEW: SEARCH BAR
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

          // 🛠 NEW: ACTIVE FOLDER CHIP
          // 🛠 FIX: ACTIVE FOLDER CHIP (No more police lines!)
          if (activeCategory != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: InputChip(
                label: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 160,
                  ), // Leaves room for the 'x'
                  child: Text(
                    activeCategory!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Truncates long names
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
                            item.contentType == 'url'
                                ? Icons.link
                                : Icons.notes,
                            size: 18,
                            color: Colors.deepPurpleAccent,
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
                );
              },
            ),
          ),

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
