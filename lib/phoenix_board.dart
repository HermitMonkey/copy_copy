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
  bool _isInspecting = false;

  void _selectItemAndInspect(ClipboardItem item) {
    setState(() {
      _selectedItem = item;
      _isInspecting = true;
    });
  }

  void _backToDashboard() {
    setState(() {
      _isInspecting = false;
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

            // --- THEME SETTINGS ---
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
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  widget.onThemeChanged(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 32),

            // --- TRAY MENU SETTINGS ---
            const Text(
              "System Tray Menu",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 8, label: Text("8 Items")),
                  ButtonSegment(value: 55, label: Text("55 Items")),
                  ButtonSegment(value: 144, label: Text("144 Items")),
                ],
                // SAFETY NET: Default to 8 if the saved value isn't an exact match
                selected: {
                  {8, 55, 144}.contains(widget.currentTrayLimit)
                      ? widget.currentTrayLimit
                      : 8,
                },
                onSelectionChanged: (Set<int> newSelection) {
                  widget.onTrayLimitChanged(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blueGrey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "The system tray only displays your most recent clips for quick pasting. Open this Phoenix Board to view, search, and analyze your entire history.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareTo(String platform, ClipboardItem item) async {
    String titleStr = item.title != null ? "${item.title}\n\n" : "";
    String rawText = "Check out this research: \n$titleStr${item.content}";
    String encodedText = Uri.encodeComponent(rawText);
    String encodedUrl = Uri.encodeComponent(item.content);

    Uri? uri;
    switch (platform) {
      case 'whatsapp':
        uri = Uri.parse("whatsapp://send?text=$encodedText");
        break;
      case 'telegram':
        uri = Uri.parse(
          "https://t.me/share/url?url=$encodedUrl&text=${Uri.encodeComponent("Check out this research: $titleStr")}",
        );
        break;
      case 'x':
        uri = Uri.parse("https://twitter.com/intent/tweet?text=$encodedText");
        break;
      case 'email':
        uri = Uri.parse("mailto:?subject=Research Clip&body=$encodedText");
        break;
    }

    if (uri != null) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("Could not launch $platform.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutQuart,
              switchOutCurve: Curves.easeInQuart,
              layoutBuilder:
                  (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.98,
                      end: 1.0,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _isInspecting
                  ? _buildContextualInspector(context, isDark)
                  : _buildGlobalDashboard(context, isDark),
            ),
          ),

          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark ? Colors.white10 : Colors.black12,
          ),

          Container(
            width: MediaQuery.of(context).size.width > 800 ? 280 : 200,
            color: isDark ? Colors.black26 : const Color(0xFFF9F9FB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    "RAW PASTES",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: isDark ? Colors.deepPurple[200] : Colors.blueGrey,
                    ),
                  ),
                ),
                Expanded(child: _buildVaultList(isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalDashboard(BuildContext context, bool isDark) {
    final categories = [
      "War News",
      "Interesting Hotels",
      "Food & Dining",
      "Clothing",
    ];
    return SingleChildScrollView(
      key: const ValueKey("dashboard"),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolBar(context),
          const SizedBox(height: 32),
          Text(
            "AI INSIGHTS",
            style: TextStyle(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey[200]!,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categories[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Analysis pending...",
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextualInspector(BuildContext context, bool isDark) {
    if (_selectedItem == null) return const SizedBox.shrink();
    final item = _selectedItem!;

    Widget contentLayout;
    if (item.content.contains('pubmed.ncbi.nlm.nih.gov')) {
      contentLayout = _buildPubMedLayout(item, isDark);
    } else if (item.content.contains('youtube.com') ||
        item.content.contains('youtu.be')) {
      contentLayout = _buildYouTubeLayout(item, isDark);
    } else {
      contentLayout = _buildStandardLayout(item, isDark);
    }

    return Column(
      key: const ValueKey("inspector"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _backToDashboard,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text("Dashboard"),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: "Copy to Clipboard",
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: item.content)),
              ),
              if (item.contentType == 'url')
                IconButton(
                  tooltip: "Open in Browser",
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  onPressed: () => _openInBrowser(item.content),
                ),
              PopupMenuButton<String>(
                tooltip: "Share Research",
                icon: const Icon(
                  Icons.ios_share,
                  size: 18,
                  color: Colors.blueAccent,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark ? const Color(0xFF2A2A2E) : Colors.white,
                elevation: 8,
                onSelected: (value) => _shareTo(value, item),
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem(
                    value: 'whatsapp',
                    child: ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Color(0xFF25D366),
                        size: 20,
                      ),
                      title: Text('WhatsApp', style: TextStyle(fontSize: 14)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'telegram',
                    child: ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.telegram,
                        color: Color(0xFF0088cc),
                        size: 20,
                      ),
                      title: Text('Telegram', style: TextStyle(fontSize: 14)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'x',
                    child: ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.xTwitter,
                        color: isDark ? Colors.white : Colors.black,
                        size: 20,
                      ),
                      title: const Text(
                        'X (Twitter)',
                        style: TextStyle(fontSize: 14),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'email',
                    child: ListTile(
                      leading: FaIcon(
                        FontAwesomeIcons.solidEnvelope,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      title: Text('Email', style: TextStyle(fontSize: 14)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.contentType == 'url' ? Icons.link : Icons.notes,
                    size: 24,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title ?? "Inspector",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.blue[300]),
              ),
              const SizedBox(height: 24),
              contentLayout,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPubMedLayout(ClipboardItem item, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf, size: 16),
          label: const Text("Find PDF"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            foregroundColor: Colors.white,
          ),
          onPressed: () => _openInBrowser(item.content),
        ),
        const SizedBox(height: 24),
        const Text(
          "ABSTRACT / SCRAPED DATA",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.articleText ?? "No abstract scraped. Wait for background task.",
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildYouTubeLayout(ClipboardItem item, bool isDark) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final videoId = regExp.firstMatch(item.content)?.group(1);

    if (videoId == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _openInBrowser(item.content),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardLayout(ClipboardItem item, bool isDark) {
    return Text(
      item.articleText ?? item.content,
      style: const TextStyle(fontSize: 14, height: 1.6),
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Phoenix Board",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => print("🚀 Triggering AI..."),
          icon: const Icon(Icons.auto_awesome, size: 14),
          label: const Text("Run AI", style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 20),
          onPressed: () => _showSettings(context),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: widget.onHide,
        ),
      ],
    );
  }

  Widget _buildVaultList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: widget.history.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
      itemBuilder: (context, index) {
        final item = widget.history[index];
        final String timeStr =
            "${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}";

        return ListTile(
          dense: true,
          selected: _selectedItem?.id == item.id && _isInspecting,
          selectedTileColor: isDark ? Colors.white10 : Colors.black12,
          leading: item.contentType == 'url'
              ? (item.faviconUrl != null
                    ? Image.network(
                        item.faviconUrl!,
                        width: 16,
                        height: 16,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.link,
                          size: 16,
                          color: Colors.blue,
                        ),
                      )
                    : const Icon(Icons.link, size: 16, color: Colors.blue))
              : (item.contentType == 'code'
                    ? const Icon(Icons.code, size: 16, color: Colors.green)
                    : const Icon(Icons.notes, size: 16, color: Colors.grey)),
          title: Text(
            item.title ?? item.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          subtitle: Text(
            timeStr,
            style: const TextStyle(fontSize: 9, color: Colors.blueGrey),
          ),
          trailing: item.articleText != null
              ? const Icon(
                  Icons.article_outlined,
                  size: 14,
                  color: Colors.deepPurple,
                )
              : null,
          onTap: () => _selectItemAndInspect(item),
        );
      },
    );
  }
}
