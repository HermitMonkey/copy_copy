import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import '../services/firestore_sync_service.dart';
import '../services/audio_service.dart';

class SettingsModal extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final int currentTrayLimit;
  final Function(int) onTrayLimitChanged;
  final VoidCallback onNuclearReset;
  final VoidCallback onExportJson;

  const SettingsModal({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.currentTrayLimit,
    required this.onTrayLimitChanged,
    required this.onNuclearReset,
    required this.onExportJson,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  bool _isLaunchAtLoginEnabled = false;
  bool _soundsEnabled = !AudioService.isMuted;

  @override
  void initState() {
    super.initState();
    _checkStartupStatus();
  }

  Future<void> _checkStartupStatus() async {
    bool isEnabled = await launchAtStartup.isEnabled();
    setState(() => _isLaunchAtLoginEnabled = isEnabled);
  }

  Future<void> _toggleLaunchAtLogin(bool value) async {
    // Optimistically update the UI so it doesn't bounce annoyingly in Dev Mode
    setState(() => _isLaunchAtLoginEnabled = value);
    try {
      if (value) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
    } catch (e) {
      // Fails silently in debug mode, but visual state is preserved for testing
    }
  }

  void _toggleSounds(bool value) {
    setState(() => _soundsEnabled = value);
    AudioService.toggleMute(!value);
    if (value) AudioService.playClick();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;
    final queueSize = FirestoreSyncService.pendingSyncCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Phoenix Command Center",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 32),

          // --- PREFERENCES ---
          const Text(
            "SYSTEM PREFERENCES",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text(
              "Launch at Login",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Start Phoenix silently in the background",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            value: _isLaunchAtLoginEnabled,
            onChanged: (val) {
              AudioService.playClick();
              _toggleLaunchAtLogin(val);
            },
            activeColor: Colors.deepPurpleAccent,
            contentPadding: EdgeInsets.zero,
          ),

          // 🛠 NEW: Mute Toggle
          SwitchListTile(
            title: const Text(
              "UI Sounds & Alerts",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Play audio for background saves and major actions",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            value: _soundsEnabled,
            onChanged: _toggleSounds,
            activeColor: Colors.deepPurpleAccent,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),

          SegmentedButton<ThemeMode>(
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
            selected: {widget.currentThemeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              AudioService.playClick();
              widget.onThemeChanged(newSelection.first);
            },
          ),
          const SizedBox(height: 32),

          const Text(
            "SYSTEM TRAY LIMIT",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 8, label: Text("8 Items")),
              ButtonSegment(value: 15, label: Text("15 Items")),
              ButtonSegment(value: 55, label: Text("55 Items")),
            ],
            selected: {
              {8, 15, 55}.contains(widget.currentTrayLimit)
                  ? widget.currentTrayLimit
                  : 15,
            },
            onSelectionChanged: (Set<int> newSelection) {
              AudioService.playClick();
              widget.onTrayLimitChanged(newSelection.first);
            },
          ),
          const Divider(height: 48),

          // --- DATA & CLOUD ---
          const Text(
            "DATA & CLOUD",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  currentUser != null ? Icons.cloud_done : Icons.cloud_off,
                  color: currentUser != null ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser != null
                            ? "E2EE Cloud Active"
                            : "Offline Mode",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        queueSize > 0
                            ? "$queueSize items waiting in queue"
                            : "All encrypted items synced",
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AudioService.playClick();
                    widget.onExportJson();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text("Export JSON"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    AudioService.playThwack();
                    widget.onNuclearReset();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text("Nuclear Reset"),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
