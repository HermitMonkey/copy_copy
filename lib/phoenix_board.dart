import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/clipboard_item.dart';

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

  void _selectItemAndInspect(ClipboardItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  void _backToDashboard() {
    setState(() {
      _selectedItem = null;
    });
  }

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSettings(BuildContext context) {
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

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F11)
          : const Color(0xFFF4F5F7),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT SIDEBAR: The Navigation & History
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161618) : Colors.white,
              border: Border(
                right: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
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
                Expanded(child: _buildVaultList(isDark)),
                _buildSidebarFooter(isDark),
              ],
            ),
          ),

          // MAIN STAGE: Dashboard or Magazine Reader
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedItem == null
                  ? _buildGlobalDashboard(context, isDark)
                  : _buildContextualInspector(context, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter(bool isDark) {
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
            onPressed: () => _showSettings(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_fullscreen_outlined, size: 20),
            onPressed: widget.onHide,
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalDashboard(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey("dashboard"),
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Workspace",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildActivityCard(isDark),
          const SizedBox(height: 48),
          Text(
            "COLLECTIONS",
            style: TextStyle(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 3 : 2,
            shrinkWrap: true,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.6,
            children: [
              _buildFolderCard(
                "Medical Research",
                "12 items",
                Icons.science_outlined,
                Colors.blue,
                isDark,
              ),
              _buildFolderCard(
                "Engineering",
                "8 items",
                Icons.terminal_outlined,
                Colors.green,
                isDark,
              ),
              _buildFolderCard(
                "Travel",
                "3 items",
                Icons.explore_outlined,
                Colors.orange,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 12,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              Text(
                "${widget.history.length}\nClips",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(width: 64),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Clipboard Metrics",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 24),
                _buildStatLine(
                  "Captured Links",
                  "42%",
                  Colors.deepPurpleAccent,
                ),
                _buildStatLine("Code Snippets", "35%", Colors.green),
                _buildStatLine("Plain Text", "23%", Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatLine(String label, String val, Color col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: col, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildContextualInspector(BuildContext context, bool isDark) {
    final item = _selectedItem!;
    return Column(
      key: const ValueKey("inspector"),
      children: [
        _buildMinimalToolbar(item, isDark),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.heroImageUrl != null)
                  _buildHeroHeader(item.heroImageUrl!)
                else
                  const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title ?? "Copied Content",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          height: 1.1,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailedInfoBar(item, isDark),
                      const SizedBox(height: 32),
                      const Divider(thickness: 0.5),
                      const SizedBox(height: 40),
                      Text(
                        item.articleText ?? item.content,
                        style: TextStyle(
                          fontSize: 19,
                          height: 1.75,
                          fontFamily: 'Georgia',
                          color: isDark
                              ? Colors.white.withOpacity(0.85)
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 80),
                      _buildSourceFooter(item, isDark),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(String url) {
    return Container(
      height: 350,
      width: double.infinity,
      foregroundDecoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF0F0F11).withOpacity(1),
            const Color(0xFF0F0F11).withOpacity(0),
          ],
        ),
      ),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMinimalToolbar(ClipboardItem item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: _backToDashboard,
          ),
          const Spacer(),
          _buildSlimButton(
            Icons.copy_rounded,
            "Copy",
            () => Clipboard.setData(ClipboardData(text: item.content)),
          ),
          const SizedBox(width: 12),
          if (item.contentType == 'url')
            _buildSlimButton(
              Icons.open_in_new_rounded,
              "Source",
              () => _openInBrowser(item.content),
            ),
          const SizedBox(width: 12),
          _buildShareMenu(item, isDark),
        ],
      ),
    );
  }

  Widget _buildSlimButton(IconData icon, String label, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.deepPurpleAccent),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.deepPurpleAccent,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDetailedInfoBar(ClipboardItem item, bool isDark) {
    return Row(
      children: [
        if (item.faviconUrl != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(item.faviconUrl!, width: 20, height: 20),
            ),
          ),
        Text(
          (item.contentType ?? "TEXT").toUpperCase(),
          style: const TextStyle(
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.access_time,
          size: 14,
          color: isDark ? Colors.white30 : Colors.black38,
        ),
        const SizedBox(width: 6),
        Text(
          item.timestamp.toString().substring(0, 16),
          style: TextStyle(
            color: isDark ? Colors.white30 : Colors.black38,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceFooter(ClipboardItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "RAW SOURCE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            item.content,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareMenu(ClipboardItem item, bool isDark) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.share_outlined, size: 20),
      onSelected: (val) => print("Sharing to $val"),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'ws',
          child: ListTile(
            leading: Icon(Icons.message, color: Colors.green),
            title: Text("WhatsApp"),
          ),
        ),
        const PopupMenuItem(
          value: 'tg',
          child: ListTile(
            leading: Icon(Icons.telegram, color: Colors.blue),
            title: Text("Telegram"),
          ),
        ),
        const PopupMenuItem(
          value: 'x',
          child: ListTile(
            leading: Icon(Icons.close),
            title: Text("X (Twitter)"),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderCard(
    String title,
    String subtitle,
    dynamic icon,
    Color color,
    bool isDark,
  ) {
    Widget iconWidget = icon is FaIconData
        ? FaIcon(icon, color: color, size: 22)
        : Icon(icon, color: color, size: 22);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: iconWidget,
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      itemCount: widget.history.length,
      itemBuilder: (context, index) {
        final item = widget.history[index];
        final bool isSelected = _selectedItem?.id == item.id;
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
            onTap: () => _selectItemAndInspect(item),
          ),
        );
      },
    );
  }
}
