import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/clipboard_item.dart';

class GlobalDashboard extends StatelessWidget {
  final List<ClipboardItem> history;
  final bool isDark;

  const GlobalDashboard({
    super.key,
    required this.history,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // --- 🧠 NON-AI INTELLIGENCE ENGINE ---
    final int total = history.length;

    // 1. Composition Counts
    final int linksCount = history.where((i) => i.contentType == 'url').length;
    final int codeCount = history.where((i) => i.contentType == 'code').length;
    final int textCount = total - linksCount - codeCount;

    // 2. Percentages (Safeguarded against divide-by-zero)
    final String linkPct = total == 0
        ? "0.0"
        : ((linksCount / total) * 100).toStringAsFixed(1);
    final String codePct = total == 0
        ? "0.0"
        : ((codeCount / total) * 100).toStringAsFixed(1);
    final String textPct = total == 0
        ? "0.0"
        : ((textCount / total) * 100).toStringAsFixed(1);

    // 3. Smart Folder Heuristics
    final int medicalCount = history.where((i) {
      final str = i.content.toLowerCase();
      return str.contains('pubmed') ||
          str.contains('nih.gov') ||
          str.contains('clinicaltrials');
    }).length;

    final int engCount = history.where((i) {
      final str = i.content.toLowerCase();
      return i.contentType == 'code' ||
          str.contains('github.com') ||
          str.contains('stackoverflow');
    }).length;

    final int travelCount = history.where((i) {
      final str = i.content.toLowerCase();
      return str.contains('airbnb.com') ||
          str.contains('booking.com') ||
          str.contains('flight') ||
          str.contains('itinerary');
    }).length;
    // -------------------------------------

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

          // GITHUB-STYLE ACTIVITY CARD
          _buildGitHubStyleActivityCard(
            total,
            linksCount,
            codeCount,
            textCount,
            linkPct,
            codePct,
            textPct,
          ),

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

          // FOLDERS GRID
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.4,
            children: [
              _buildFolderCard(
                "Medical Research",
                "$medicalCount items",
                Icons.science_outlined,
                Colors.blue,
              ),
              _buildFolderCard(
                "Engineering",
                "$engCount items",
                Icons.terminal_outlined,
                Colors.green,
              ),
              _buildFolderCard(
                "Travel",
                "$travelCount items",
                Icons.explore_outlined,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubStyleActivityCard(
    int total,
    int links,
    int code,
    int text,
    String linkPct,
    String codePct,
    String textPct,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Clipboard Composition",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              Text(
                "$total Total Clips",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // DYNAMIC PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (links > 0)
                  Expanded(
                    flex: links,
                    child: Container(
                      height: 12,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                if (code > 0)
                  Expanded(
                    flex: code,
                    child: Container(height: 12, color: Colors.green),
                  ),
                if (text > 0)
                  Expanded(
                    flex: text,
                    child: Container(height: 12, color: Colors.orange),
                  ),
                // Fallback empty bar if database is completely clear
                if (total == 0)
                  Expanded(
                    child: Container(
                      height: 12,
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // DYNAMIC LEGEND
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _buildLegendItem(
                "Captured Links",
                "$linkPct%",
                Colors.deepPurpleAccent,
              ),
              _buildLegendItem("Code Snippets", "$codePct%", Colors.green),
              _buildLegendItem("Plain Text", "$textPct%", Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String val, Color col) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: col, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        Text(
          val,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white54 : Colors.black54,
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
  ) {
    Widget iconWidget = icon is FaIconData
        ? FaIcon(icon, color: color, size: 22)
        : Icon(icon, color: color, size: 22);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: iconWidget,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}
