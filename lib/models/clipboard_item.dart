import 'package:isar/isar.dart';

part 'clipboard_item.g.dart';

@collection
class ClipboardItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String content;

  @Index()
  late DateTime timestamp;

  String? title;
  String? faviconUrl;
  String? articleText;
  String? contentType;
  String? heroImageUrl;
  List<String>? contextualImages;

  bool isSensitive = false;

  // 🛠 NEW: Tracks if this item has been shared externally
  @Index()
  bool isShared = false;
}
