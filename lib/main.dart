import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'services/app_initialization_service.dart';
import 'services/clipboard_classifier.dart';
import 'services/clipboard_enricher.dart';
import 'services/firestore_sync_service.dart';
import 'services/audio_service.dart';
import 'services/license_service.dart';
import 'models/clipboard_item.dart';
import 'models/smart_folder.dart';
import 'phoenix_board.dart';
import 'system_tray_manager.dart';

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializationService.initializeWindowManager();
  await AppInitializationService.initializeFirebaseAndSecurity();
  await AppInitializationService.initializeLaunchAtStartup();
  isar = await AppInitializationService.initializeIsarDatabase();
  await LicenseService.initialize();

  // 🛠 NEW: Seed the database with a Welcome Note if it's totally empty!
  final count = await isar.clipboardItems.count();
  if (count == 0) {
    await isar.writeTxn(() async {
      final welcomeNote = ClipboardItem()
        ..title = "Welcome to VaultCopy 🚀"
        ..content = "Your privacy-first, intelligent clipboard vault is ready."
        ..articleText = """
Welcome to your new privacy-first, intelligent clipboard workspace!

HOW TO USE YOUR VAULT

• Press CMD+Shift+V anywhere on your Mac to summon this dashboard instantly.
• Copy any text, link, or image, and it will be securely vaulted here in the background.
• Use the 'Jot down a thought...' bar above to write manual notes exactly like this one.
• Create 'Smart Collections' using trigger keywords to automatically organize your chaotic clipboard history.

PRIVACY FIRST

Everything you see here is stored locally on your Mac using an encrypted Isar database. No unwanted cloud scraping, no privacy leaks. You have complete control over your data.

Happy copying!
"""
        ..contentType = 'note'
        ..timestamp = DateTime.now()
        ..isSensitive = false;

      await isar.clipboardItems.put(welcomeNote);
    });
  }

  runApp(const CopyCopyApp());
}

class CopyCopyApp extends StatefulWidget {
  const CopyCopyApp({super.key});
  @override
  State<CopyCopyApp> createState() => _CopyCopyAppState();
}

class _CopyCopyAppState extends State<CopyCopyApp>
    with ClipboardListener, WindowListener {
  final SystemTrayManager _trayManager = SystemTrayManager();
  final List<ClipboardItem> _clipboardHistory = [];
  final List<SmartFolder> _smartFolders = [];

  ThemeMode _themeMode = ThemeMode.system;
  int _trayLimit = 15;

  @override
  void initState() {
    super.initState();
    _trayManager.init(onOpenDashboard: () => _toggleDashboard(), history: []);
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
    windowManager.addListener(this);

    _loadSettingsAndHistory();
    _registerGlobalHotkey();
    Future.delayed(
      const Duration(milliseconds: 500),
      () => windowManager.hide(),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    clipboardWatcher.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowHide() => _syncTrayMenu();

  @override
  void onWindowShow() => _syncTrayMenu();

  Future<void> _registerGlobalHotkey() async {
    await hotKeyManager.unregisterAll();
    final hotKey = HotKey(
      key: PhysicalKeyboardKey.keyV,
      modifiers: [HotKeyModifier.meta, HotKeyModifier.shift],
      scope: HotKeyScope.system,
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (_) async => _toggleDashboard(),
    );
  }

  Future<void> _toggleDashboard() async {
    final isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }

  Future<void> _loadSettingsAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _trayLimit = prefs.getInt('trayLimit') ?? 15);
    _loadHistoryFromDisk();
  }

  Future<void> _updateTrayLimit(int newLimit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trayLimit', newLimit);
    setState(() => _trayLimit = newLimit);
    _loadHistoryFromDisk();
  }

  Future<void> _loadHistoryFromDisk() async {
    final items = await isar.clipboardItems
        .where()
        .sortByTimestampDesc()
        .findAll();
    final folders = await isar.smartFolders.where().sortBySortOrder().findAll();

    setState(() {
      _clipboardHistory.clear();
      _clipboardHistory.addAll(items);
      _smartFolders.clear();
      _smartFolders.addAll(folders);
    });
    _syncTrayMenu();
  }

  void _syncTrayMenu() {
    final trayItems = _clipboardHistory.take(_trayLimit).map((e) {
      String displayText = e.title ?? e.content;
      displayText = displayText.replaceAll('\n', ' ').trim();
      if (displayText.length > 40)
        displayText = '${displayText.substring(0, 40)}...';
      return displayText;
    }).toList();
    _trayManager.updateMenu(trayItems);
  }

  void _setTheme(ThemeMode mode) => setState(() => _themeMode = mode);

  Future<void> _createSmartFolder(SmartFolder folder) async {
    await isar.writeTxn(() async {
      await isar.smartFolders.put(folder);
    });
    _loadHistoryFromDisk();
  }

  Future<void> _deleteSmartFolder(int id) async {
    await isar.writeTxn(() async {
      await isar.smartFolders.delete(id);
    });
    _loadHistoryFromDisk();
  }

  Future<void> _deleteSingleItem(int id) async {
    await isar.writeTxn(() async {
      await isar.clipboardItems.delete(id);
    });
    _loadHistoryFromDisk();
  }

  Future<void> _nuclearReset(BuildContext context) async {
    await isar.writeTxn(() async {
      await isar.clipboardItems.clear();
    });
    _loadHistoryFromDisk();
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final dir = await getDownloadsDirectory();
      if (dir != null) {
        final file = File('${dir.path}/copy_copy_export.json');
        final data = _clipboardHistory
            .map(
              (e) => {
                'content': e.content,
                'title': e.title,
                'type': e.contentType,
                'timestamp': e.timestamp.toIso8601String(),
                'summary': e.generatedSummary,
                'links': e.attachedPdfs,
              },
            )
            .toList();

        await file.writeAsString(jsonEncode(data));
      }
    } catch (e) {
      debugPrint("Export failed: $e");
    }
  }

  // 🛠 NEW: Dedicated method for manual notes
  Future<void> _saveManualNote(String title, String content) async {
    AudioService.playCopied();

    await isar.writeTxn(() async {
      final newItem = ClipboardItem()
        ..content = content
        ..title = title.isNotEmpty ? title : "Quick Note"
        ..articleText =
            content // Save body here for beautiful rendering in Inspector
        ..timestamp = DateTime.now()
        ..isSensitive = false
        ..contentType = 'note'; // 🧠 Flagged specifically as a note!
      await isar.clipboardItems.put(newItem);
    });

    _loadHistoryFromDisk();

    // Sync to cloud just like a clipboard item
    final savedItem = await isar.clipboardItems
        .where()
        .sortByTimestampDesc()
        .findFirst();
    if (savedItem != null) {
      FirestoreSyncService.queueItemForSync(savedItem);
    }
  }

  @override
  void onClipboardChanged() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final String? content = clipboardData?.text;

    if (content != null && content.isNotEmpty) {
      AudioService.playCopied();
      final bool sensitiveFlag = ClipboardClassifier.isSensitive(content);
      final String typeFlag = ClipboardClassifier.determineContentType(content);

      await isar.writeTxn(() async {
        final existingItem = await isar.clipboardItems
            .where()
            .contentEqualTo(content)
            .findFirst();

        if (existingItem != null) {
          existingItem.timestamp = DateTime.now();
          await isar.clipboardItems.put(existingItem);
        } else {
          final newItem = ClipboardItem()
            ..content = content
            ..timestamp = DateTime.now()
            ..isSensitive = sensitiveFlag
            ..contentType = typeFlag;
          await isar.clipboardItems.put(newItem);
        }

        final count = await isar.clipboardItems.count();
        if (count > LicenseService.historyLimit) {
          final oldestItem = await isar.clipboardItems
              .where()
              .sortByTimestamp()
              .findFirst();
          if (oldestItem != null)
            await isar.clipboardItems.delete(oldestItem.id);
        }
      });

      _loadHistoryFromDisk();

      final newlySavedItem = await isar.clipboardItems
          .where()
          .contentEqualTo(content)
          .findFirst();
      if (newlySavedItem != null) {
        if (newlySavedItem.contentType == 'url' &&
            !newlySavedItem.isSensitive) {
          ClipboardEnricher.enrichItem(isar, newlySavedItem.id).then((_) async {
            _loadHistoryFromDisk();
            final enrichedItem = await isar.clipboardItems.get(
              newlySavedItem.id,
            );
            if (enrichedItem != null)
              FirestoreSyncService.queueItemForSync(enrichedItem);
          });
        } else {
          FirestoreSyncService.queueItemForSync(newlySavedItem);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: PhoenixBoard(
        history: _clipboardHistory,
        smartFolders: _smartFolders,
        onHide: () => windowManager.hide(),
        currentThemeMode: _themeMode,
        onThemeChanged: _setTheme,
        currentTrayLimit: _trayLimit,
        onTrayLimitChanged: _updateTrayLimit,
        onNuclearReset: _nuclearReset,
        onExportJson: _exportData,
        onCreateFolder: _createSmartFolder,
        onDeleteFolder: _deleteSmartFolder,
        onDeleteSingleItem: _deleteSingleItem,
        onSaveNote: _saveManualNote, // 🛠 NEW: Pass down the save method
      ),
    );
  }
}
