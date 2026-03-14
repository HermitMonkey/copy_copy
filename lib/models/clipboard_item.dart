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

  bool isSensitive = false;

  // 🛠 NEW: Added these back after the reset!
  List<String>? contextualImages;
  String? generatedSummary;
}
