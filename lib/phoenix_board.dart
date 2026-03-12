import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/clipboard_item.dart'; // <--- CRITICAL IMPORT

class PhoenixBoard extends StatelessWidget {
  final List<ClipboardItem> history;
  final VoidCallback onHide;
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;

  const PhoenixBoard({
    super.key,
    required this.history,
    required this.onHide,
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildToolBar(context),
                      const SizedBox(height: 32),
                      Text(
                        "AI INSIGHTS",
                        style: TextStyle(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInsightGrid(isDark),
                    ],
                  ),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              Container(
                width: constraints.maxWidth > 600 ? 280 : 180,
                color: isDark ? Colors.black26 : const Color(0xFFF9F9FB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        "RAW PASTES",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: isDark
                              ? Colors.deepPurple[200]
                              : Colors.blueGrey,
                        ),
                      ),
                    ),
                    Expanded(child: _buildVaultList(isDark)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Phoenix Board",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => print("🚀 Triggering Gemini..."),
          icon: const Icon(Icons.auto_awesome, size: 14),
          label: const Text("Run AI", style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 20),
          onPressed: () => _showSettings(context),
        ),
        IconButton(icon: const Icon(Icons.close, size: 20), onPressed: onHide),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Appearance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text("Light"),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.settings_display),
                    label: Text("System"),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text("Dark"),
                  ),
                ],
                selected: {currentThemeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  onThemeChanged(newSelection.first);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightGrid(bool isDark) {
    final categories = [
      "War News",
      "Interesting Hotels",
      "Food & Dining",
      "Clothing",
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.4,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey[200]!,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categories[index],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Spacer(),
            Text(
              "Analysis pending...",
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: history.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
      itemBuilder: (context, index) {
        final item = history[index];
        final String timeStr =
            "${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}";

        return ListTile(
          dense: true,
          leading: Text(
            "${index + 1}",
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          title: Text(
            item.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          subtitle: Text(
            timeStr,
            style: const TextStyle(fontSize: 9, color: Colors.blueGrey),
          ),
          onTap: () async =>
              await Clipboard.setData(ClipboardData(text: item.content)),
        );
      },
    );
  }
}
