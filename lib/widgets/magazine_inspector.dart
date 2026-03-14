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

                        // 🛠 NEW: RENDER PDF ATTACHMENTS
                        if (item.attachedPdfs != null &&
                            item.attachedPdfs!.isNotEmpty) ...[
                          Text(
                            "ATTACHMENTS",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...item.attachedPdfs!.map(
                            (pdf) => _buildPdfCard(pdf, isDark),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // 🛠 RESTORED: CONTEXTUAL IMAGE GALLERY

                        // 🛠 RESTORED: CONTEXTUAL IMAGE GALLERY
                        if (item.contextualImages != null &&
                            item.contextualImages!.isNotEmpty) ...[
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: item.contextualImages!.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      item.contextualImages![index],
                                      height: 200,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        const Divider(thickness: 0.5),
                        const SizedBox(height: 40),

                        // 🛠 RESTORED: THE TL;DR BOX
                        if (item.generatedSummary != null &&
                            item.generatedSummary!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(bottom: 40),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.deepPurpleAccent.withOpacity(0.1)
                                  : Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.deepPurpleAccent.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.deepPurpleAccent,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Quick Summary",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurpleAccent,
                                        fontSize: 14,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  item.generatedSummary!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.85)
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Main Article Body
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

  Widget _buildPdfCard(String pdfUrl, bool isDark) {
    final uri = Uri.tryParse(pdfUrl);
    final filename = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : "Document.pdf";
    final domain = uri?.host ?? "External Source";

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9FB),
      child: InkWell(
        onTap: () => _openInBrowser(pdfUrl),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Uri.decodeComponent(
                        filename,
                      ), // Clean up %20 in filenames
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      domain.toUpperCase(),
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.open_in_new_rounded,
                color: isDark ? Colors.white30 : Colors.black38,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
