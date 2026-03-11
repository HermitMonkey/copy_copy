class ClipModel {
  final String text;
  final DateTime timestamp;
  bool isSynced;

  ClipModel({
    required this.text,
    required this.timestamp,
    this.isSynced = false,
  });
}
