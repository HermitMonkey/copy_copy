import 'package:isar/isar.dart';

part 'smart_folder.g.dart';

@collection
class SmartFolder {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name;

  late int colorValue; // Store Flutter Color value as an integer
  late int iconCodePoint; // Store Material Icon code point

  List<String> keywords = []; // The rules that pull items into this folder

  @Index()
  late int sortOrder; // Allows the user to re-arrange folders later
}
