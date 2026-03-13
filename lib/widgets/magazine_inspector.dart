import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/clipboard_item.dart';

class MagazineInspector extends StatelessWidget {
  final ClipboardItem item;
  final bool isDark;
  final VoidCallback onBack;

  const MagazineInspector({
    super.key,
    required this.item,
    required this.isDark,
    required this.onBack,
  });

  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF0F0F11) : Colors.white,
      child: Column(
        children: [
          _buildMinimalToolbar(),
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
                        _buildDetailedInfoBar(),
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
                        _buildSourceFooter(),
                        const SizedBox(height: 60),
                      ],
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

  Widget _buildMinimalToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: onBack,
            tooltip: "Back to Workspace",
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

  Widget _buildDetailedInfoBar() {
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

  Widget _buildSourceFooter() {
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
}
