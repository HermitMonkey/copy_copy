import 'package:flutter/material.dart';
import '../models/clipboard_item.dart';
import '../models/smart_folder.dart';
import '../services/audio_service.dart';
import 'smart_folder_modal.dart';

class GlobalDashboard extends StatelessWidget {
  final List<ClipboardItem> history;
  final List<SmartFolder> smartFolders;
  final bool isDark;
  final Function(String) onCategorySelected;
  final Function(SmartFolder) onCreateFolder;
  final Function(int) onDeleteFolder;
  final Function(String, String) onSaveNote;

  const GlobalDashboard({
    super.key,
    required this.history,
    required this.smartFolders,
    required this.isDark,
    required this.onCategorySelected,
    required this.onCreateFolder,
    required this.onDeleteFolder,
    required this.onSaveNote,
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
            // THE HERO COMPOSER
            _HeroComposer(isDark: isDark, onSave: onSaveNote),
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
      itemCount:
          smartFolders.length +
          2, // 🛠 +2 accounts for Vault Notes AND Create Folder
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildVaultNotesCard();
        }
        if (index == smartFolders.length + 1) {
          return _buildCreateFolderCard(context);
        }
        return _buildSmartFolderCard(smartFolders[index - 1]);
      },
    );
  }

  // 🛠 THE MISSING PERMANENT VAULT NOTES CARD
  Widget _buildVaultNotesCard() {
    int count = history.where((item) => item.contentType == 'note').length;
    const color = Colors.orangeAccent;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white24 : Colors.black26,
          width: 1.5,
        ),
      ),
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: InkWell(
        onTap: () => onCategorySelected('Vault Notes'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
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
                child: const Icon(Icons.edit_document, color: color, size: 24),
              ),
              const Spacer(),
              const Text(
                "Vault Notes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      ),
    );
  }

  Widget _buildSmartFolderCard(SmartFolder folder) {
    final color = Color(folder.colorValue);
    final icon = IconData(folder.iconCodePoint, fontFamily: 'MaterialIcons');

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
            builder: (modalContext) => SmartFolderModal(
              onSave: (folder) {
                onCreateFolder(folder);
                Navigator.pop(modalContext);
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

// 🛠 THE BUG-FREE HERO COMPOSER
class _HeroComposer extends StatefulWidget {
  final bool isDark;
  final Function(String, String) onSave;

  const _HeroComposer({required this.isDark, required this.onSave});

  @override
  State<_HeroComposer> createState() => _HeroComposerState();
}

class _HeroComposerState extends State<_HeroComposer> {
  bool _isExpanded = false;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  void _submit() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (body.isEmpty) {
      _collapse();
      return;
    }

    widget.onSave(title, body);
    _collapse();
  }

  void _collapse() {
    setState(() => _isExpanded = false);
    _titleController.clear();
    _bodyController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // 🛠 FIX: AnimatedSize guarantees NO police ribbons during expansion!
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark ? Colors.white10 : Colors.black12,
          ),
          boxShadow: _isExpanded
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isExpanded)
              InkWell(
                onTap: () {
                  AudioService.playClick();
                  setState(() => _isExpanded = true);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.deepPurpleAccent,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Jot down a thought...",
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.isDark
                              ? Colors.white38
                              : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Title (Optional)",
                    hintStyle: TextStyle(
                      color: widget.isDark ? Colors.white24 : Colors.black26,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: TextField(
                  controller: _bodyController,
                  maxLines: null,
                  minLines: 4,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    fontFamily: 'Georgia',
                  ),
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(
                      color: widget.isDark ? Colors.white30 : Colors.black38,
                      fontFamily: 'Georgia',
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.02)
                      : Colors.black.withOpacity(0.02),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _collapse,
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: widget.isDark
                              ? Colors.white54
                              : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.lock_rounded, size: 16),
                      label: const Text(
                        "Vault Note",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
