import '../models/clipboard_item.dart';

/// Service for filtering, searching and computing statistics on clipboard items
class ClipboardFilterService {
  /// Filter clipboard history by search query and optional category
  static List<ClipboardItem> filterHistory({
    required List<ClipboardItem> items,
    required String searchQuery,
    String? activeCategory,
  }) {
    return items.where((item) {
      // Apply text search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final textMatches =
            item.content.toLowerCase().contains(query) ||
            (item.title?.toLowerCase().contains(query) ?? false) ||
            (item.articleText?.toLowerCase().contains(query) ?? false);
        if (!textMatches) return false;
      }

      // Apply category filter
      if (activeCategory != null) {
        // This will be checked via the CategoryService
        // For now, we return true to let the caller handle it
        // But we can import CategoryService if needed
        return true;
      }

      return true;
    }).toList();
  }

  /// Compute content type statistics
  static ContentStats computeStats(List<ClipboardItem> items) {
    final total = items.length;
    final linksCount = items.where((i) => i.contentType == 'url').length;
    final codeCount = items.where((i) => i.contentType == 'code').length;
    final textCount = total - linksCount - codeCount;

    return ContentStats(
      total: total,
      linksCount: linksCount,
      codeCount: codeCount,
      textCount: textCount,
      linkPercentage: _calculatePercentage(linksCount, total),
      codePercentage: _calculatePercentage(codeCount, total),
      textPercentage: _calculatePercentage(textCount, total),
    );
  }

  static String _calculatePercentage(int count, int total) {
    if (total == 0) return "0.0";
    return ((count / total) * 100).toStringAsFixed(1);
  }
}

/// Statistics about clipboard content types
class ContentStats {
  final int total;
  final int linksCount;
  final int codeCount;
  final int textCount;
  final String linkPercentage;
  final String codePercentage;
  final String textPercentage;

  ContentStats({
    required this.total,
    required this.linksCount,
    required this.codeCount,
    required this.textCount,
    required this.linkPercentage,
    required this.codePercentage,
    required this.textPercentage,
  });
}
