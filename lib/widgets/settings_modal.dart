import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import '../services/firestore_sync_service.dart';
import '../services/audio_service.dart';
import '../services/license_service.dart';

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
  bool _isPro = LicenseService.isPro;
  final _licenseController = TextEditingController();

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

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

  Future<void> _activatePro() async {
    try {
      await LicenseService.activate(_licenseController.text);
      setState(() => _isPro = true);
      _licenseController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pro activated! Enjoy unlimited history.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on LicenseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _deactivatePro() async {
    await LicenseService.deactivate();
    setState(() => _isPro = false);
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

          // --- COPY COPY PRO ---
          const Text(
            "COPY COPY PRO",
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
                  ? Colors.deepPurpleAccent.withOpacity(0.08)
                  : Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.deepPurpleAccent.withOpacity(0.3),
              ),
            ),
            child: _isPro ? _buildProActiveRow(isDark) : _buildUpgradeRow(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            _isPro
                ? 'Unlimited history (up to ${LicenseService.proHistoryLimit} items). Thank you! 🙏'
                : 'Free tier: up to ${LicenseService.freeHistoryLimit} items. Upgrade for unlimited history & cloud sync.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
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

  Widget _buildProActiveRow(bool isDark) {
    return Row(
      children: [
        const Icon(Icons.verified_rounded, color: Colors.deepPurpleAccent),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pro License Active',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (LicenseService.activeLicenseKey != null)
                Text(
                  LicenseService.activeLicenseKey!,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Courier',
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: _deactivatePro,
          child: const Text(
            'Deactivate',
            style: TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeRow(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lock_open_rounded, color: Colors.deepPurpleAccent),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Enter your license key to unlock Pro',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _licenseController,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'CCPRO-XXXX-XXXX-XXXX',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black26,
                    fontFamily: 'Courier',
                    letterSpacing: 1.5,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _activatePro(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _activatePro,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('Activate'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Get a license key → ${LicenseService.storeUrl}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.deepPurpleAccent,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
