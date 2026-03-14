import 'package:flutter/material.dart';
import '../models/clipboard_item.dart';
import '../models/smart_folder.dart';
import '../services/audio_service.dart';
import 'smart_folder_modal.dart';

class GlobalDashboard extends StatelessWidget {
  final List<ClipboardItem> history;
  final List<SmartFolder> smartFolders; // 🛠 NEW
  final bool isDark;
  final Function(String) onCategorySelected;
  final Function(SmartFolder) onCreateFolder; // 🛠 NEW
  final Function(int) onDeleteFolder; // 🛠 NEW

  const GlobalDashboard({
    super.key,
    required this.history,
    required this.smartFolders,
    required this.isDark,
    required this.onCategorySelected,
    required this.onCreateFolder,
    required this.onDeleteFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Workspace",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You have ${history.length} items securely vaulted in your local database.",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),

            const Text(
              "SMART COLLECTIONS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildCollectionsGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: smartFolders.length + 1, // +1 for the "Create New" button
      itemBuilder: (context, index) {
        if (index == smartFolders.length) {
          return _buildCreateFolderCard(context);
        }
        return _buildSmartFolderCard(smartFolders[index]);
      },
    );
  }

  Widget _buildSmartFolderCard(SmartFolder folder) {
    final color = Color(folder.colorValue);
    final icon = IconData(folder.iconCodePoint, fontFamily: 'MaterialIcons');

    // 🧠 Dynamically count how many items match this folder's rules!
    int count = 0;
    for (var item in history) {
      final content = item.content.toLowerCase();
      final title = item.title?.toLowerCase() ?? '';
      final text = item.articleText?.toLowerCase() ?? '';

      for (var kw in folder.keywords) {
        if (content.contains(kw) || title.contains(kw) || text.contains(kw)) {
          count++;
          break;
        }
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: InkWell(
        onTap: () => onCategorySelected(folder.name),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    folder.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$count items",
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
                onPressed: () {
                  AudioService.playThwack();
                  onDeleteFolder(folder.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateFolderCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
          style: BorderStyle.solid,
        ),
      ),
      color: isDark
          ? Colors.white.withOpacity(0.02)
          : Colors.black.withOpacity(0.02),
      child: InkWell(
        onTap: () {
          AudioService.playClick();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            // 🛠 FIX: Ensure we are using the 'modalContext' so it pops correctly!
            builder: (modalContext) => SmartFolderModal(
              onSave: (folder) {
                onCreateFolder(folder);
                Navigator.pop(modalContext); // Pops the modal!
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline,
                color: isDark ? Colors.white54 : Colors.black54,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                "New Collection",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
