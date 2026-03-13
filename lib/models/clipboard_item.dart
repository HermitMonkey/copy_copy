import 'package:isar/isar.dart';

part 'clipboard_item.g.dart';

@collection
class ClipboardItem {
  Id id = Isar.autoIncrement;

  @Index() // 👈 ADD THIS LINE
  late String content;

  @Index()
  late DateTime timestamp;

  String? title;
  String? faviconUrl;
  String? articleText;
  String? contentType;
  String? heroImageUrl;

  bool isSensitive = false;
}
