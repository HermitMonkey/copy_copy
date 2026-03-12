import 'package:isar/isar.dart';

part 'clipboard_item.g.dart';

@collection
class ClipboardItem {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.hash)
  late String content;

  late DateTime timestamp;

  late bool isSensitive;
  late String contentType;

  String? title;
  String? faviconUrl;

  // --- NEW: THE SCRAPED ARTICLE TEXT ---
  @Index(type: IndexType.value) // Indexed so we can quickly search it later!
  String? articleText;
}
