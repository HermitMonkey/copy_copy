import 'package:flutter/material.dart';
import '../models/clipboard_item.dart';

/// Manages category definitions and category-related logic
class CategoryService {
  // Define all categories in one place for easy maintenance
  static const String medical = 'Medical Research';
  static const String engineering = 'Engineering';
  static const String travel = 'Travel';

  static const List<CategoryDefinition> allCategories = [
    CategoryDefinition(
      id: medical,
      label: medical,
      icon: Icons.science_outlined,
      color: Color(0xFF2196F3),
    ),
    CategoryDefinition(
      id: engineering,
      label: engineering,
      icon: Icons.terminal_outlined,
      color: Color(0xFF4CAF50),
    ),
    CategoryDefinition(
      id: travel,
      label: travel,
      icon: Icons.explore_outlined,
      color: Color(0xFFFF9800),
    ),
  ];

  /// Check if a clipboard item matches a specific category
  static bool itemMatchesCategory(ClipboardItem item, String categoryId) {
    final content = item.content.toLowerCase();

    switch (categoryId) {
      case medical:
        return content.contains('pubmed') ||
            content.contains('nih.gov') ||
            content.contains('clinicaltrials');

      case engineering:
        return item.contentType == 'code' ||
            content.contains('github.com') ||
            content.contains('stackoverflow');

      case travel:
        return content.contains('airbnb.com') ||
            content.contains('booking.com') ||
            content.contains('flight');

      default:
        return false;
    }
  }

  /// Count items in a specific category
  static int countItemsInCategory(
    List<ClipboardItem> items,
    String categoryId,
  ) {
    return items.where((item) => itemMatchesCategory(item, categoryId)).length;
  }

  /// Get category definition by ID
  static CategoryDefinition? getCategoryById(String id) {
    try {
      return allCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
}

/// Immutable category definition model
class CategoryDefinition {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const CategoryDefinition({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}
