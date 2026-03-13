import 'package:flutter/material.dart';
import '../models/clipboard_item.dart';
import '../services/category_service.dart';
import '../services/clipboard_filter_service.dart';

class GlobalDashboard extends StatelessWidget {
  final List<ClipboardItem> history;
  final bool isDark;
  final Function(String) onCategorySelected;

  const GlobalDashboard({
    super.key,
    required this.history,
    required this.isDark,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Use the filter service to compute all statistics at once
    final stats = ClipboardFilterService.computeStats(history);

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
          _buildGitHubStyleActivityCard(stats),
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
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.4,
            // Build folder cards from category definitions instead of hardcoding
            children: CategoryService.allCategories
                .map(
                  (category) => _buildFolderCard(
                    category: category,
                    itemCount: CategoryService.countItemsInCategory(
                      history,
                      category.id,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGitHubStyleActivityCard(ContentStats stats) {
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
                "${stats.total} Total Clips",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (stats.linksCount > 0)
                  Expanded(
                    flex: stats.linksCount,
                    child: Container(
                      height: 12,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                if (stats.codeCount > 0)
                  Expanded(
                    flex: stats.codeCount,
                    child: Container(height: 12, color: Colors.green),
                  ),
                if (stats.textCount > 0)
                  Expanded(
                    flex: stats.textCount,
                    child: Container(height: 12, color: Colors.orange),
                  ),
                if (stats.total == 0)
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
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _buildLegendItem(
                "Captured Links",
                "${stats.linkPercentage}%",
                Colors.deepPurpleAccent,
              ),
              _buildLegendItem(
                "Code Snippets",
                "${stats.codePercentage}%",
                Colors.green,
              ),
              _buildLegendItem(
                "Plain Text",
                "${stats.textPercentage}%",
                Colors.orange,
              ),
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

  Widget _buildFolderCard({
    required CategoryDefinition category,
    required int itemCount,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onCategorySelected(category.id),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$itemCount items",
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
