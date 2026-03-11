import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clip_model.dart';

class CommandCentre extends StatefulWidget {
  final List<ClipModel> clips;
  const CommandCentre({super.key, required this.clips});

  @override
  State<CommandCentre> createState() => _CommandCentreState();
}

class _CommandCentreState extends State<CommandCentre> {
  String searchQuery = "";

  Future<void> _syncToCloud(String text) async {
    try {
      await FirebaseFirestore.instance.collection('history').add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Idea Vaulted! 🚀")));
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.clips
        .where((c) => c.text.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Phoenix Command Centre"),
        backgroundColor: Colors.deepPurple.shade50,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search your creative history...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              title: Text(
                filtered[index].text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.cloud_upload, color: Colors.deepPurple),
                onPressed: () => _syncToCloud(filtered[index].text),
              ),
              onTap: () =>
                  Clipboard.setData(ClipboardData(text: filtered[index].text)),
            ),
          );
        },
      ),
    );
  }
}
