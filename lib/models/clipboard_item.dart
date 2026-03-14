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

  List<String>? contextualImages;
  String? generatedSummary;

  // 🛠 NEW: Stores both direct PDF links and embedded PDF links
  List<String>? attachedPdfs;
}
