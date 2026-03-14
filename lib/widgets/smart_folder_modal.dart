import 'package:flutter/material.dart';
import '../models/smart_folder.dart';
import '../services/audio_service.dart';

class SmartFolderModal extends StatefulWidget {
  final Function(SmartFolder) onSave;

  const SmartFolderModal({super.key, required this.onSave});

  @override
  State<SmartFolderModal> createState() => _SmartFolderModalState();
}

class _SmartFolderModalState extends State<SmartFolderModal> {
  final _nameController = TextEditingController();
  final _keywordsController = TextEditingController();

  Color _selectedColor = Colors.blueAccent;
  IconData _selectedIcon = Icons.folder_special_rounded;

  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.tealAccent,
  ];

  final List<IconData> _icons = [
    Icons.folder_special_rounded,
    Icons.article_rounded,
    Icons.medical_information_rounded,
    Icons.code_rounded,
    Icons.flight_takeoff_rounded,
    Icons.receipt_long_rounded,
  ];

  void _save() {
    final name = _nameController.text.trim();
    final keywords = _keywordsController.text
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    // 🛠 FIX: Added explicit error feedback!
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a collection name.",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (keywords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter at least one trigger keyword.",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final folder = SmartFolder()
      ..name = name
      ..keywords = keywords
      ..colorValue = _selectedColor.value
      ..iconCodePoint = _selectedIcon.codePoint
      ..sortOrder = DateTime.now().millisecondsSinceEpoch;

    widget.onSave(folder);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 48.0,
        left: 32,
        right: 32,
        top: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create Smart Collection",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            autofocus: true, // 🛠 UX Polish: Instantly focus the text field
            decoration: InputDecoration(
              labelText: "Collection Name",
              hintText: "e.g., Project Phoenix",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _keywordsController,
            decoration: InputDecoration(
              labelText: "Trigger Keywords (comma separated)",
              hintText: "e.g., flutter, dart, isolate",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "COLOR",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: _colors
                .map(
                  (color) => GestureDetector(
                    onTap: () {
                      AudioService.playClick();
                      setState(() => _selectedColor = color);
                    },
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 18,
                      child: _selectedColor == color
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          const Text(
            "ICON",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: _icons
                .map(
                  (icon) => GestureDetector(
                    onTap: () {
                      AudioService.playClick();
                      setState(() => _selectedIcon = icon);
                    },
                    child: CircleAvatar(
                      backgroundColor: isDark ? Colors.white10 : Colors.black12,
                      radius: 18,
                      child: Icon(
                        icon,
                        color: _selectedIcon == icon
                            ? _selectedColor
                            : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                AudioService.playClick();
                _save();
              },
              style: FilledButton.styleFrom(
                backgroundColor: _selectedColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Create Collection",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
