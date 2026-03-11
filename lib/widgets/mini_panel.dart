import 'package:flutter/material.dart';
import '../models/clip_model.dart'; // Ensure this path is correct

class MiniPanel extends StatelessWidget {
  final List<ClipModel> clips;
  final Function(String) onSelect;
  final VoidCallback onOpenDashboard;

  const MiniPanel({
    super.key,
    required this.clips,
    required this.onSelect,
    required this.onOpenDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // Added Material wrapper for proper rendering
      child: Container(
        width: 280,
        height: 400, // Fixed height for the slim dropdown
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.deepPurple.shade50,
              leading: const Icon(Icons.dashboard, color: Colors.deepPurple),
              title: const Text(
                "Open Dashboard",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: onOpenDashboard,
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: clips.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    title: Text(
                      clips[index].text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSelect(clips[index].text),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
