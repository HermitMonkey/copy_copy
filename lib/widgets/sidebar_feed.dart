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
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          Expanded(child: _buildVaultList()),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildVaultList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                    item.contentType == 'url' ? Icons.link : Icons.notes,
                    size: 18,
                    color: Colors.deepPurpleAccent,
                  ),
            title: Text(
              item.title ?? "Copied Content",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            onPressed: onShowSettings,
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
          ),
        ],
      ),
    );
  }
}
