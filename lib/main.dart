import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'firebase_options.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:system_tray/system_tray.dart';

import 'models/clipboard_item.dart';
import 'phoenix_board.dart';
import 'system_tray_manager.dart';

// Global Isar instance
late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Initialize Isar Local Database
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([ClipboardItemSchema], directory: dir.path);

  runApp(const CopyCopyApp());
}

class CopyCopyApp extends StatefulWidget {
  const CopyCopyApp({super.key});
  @override
  State<CopyCopyApp> createState() => _CopyCopyAppState();
}

class _CopyCopyAppState extends State<CopyCopyApp> with ClipboardListener {
  final AppWindow _appWindow = AppWindow();
  final SystemTrayManager _trayManager = SystemTrayManager();

  // UI State now just mirrors the Database
  final List<ClipboardItem> _clipboardHistory = [];
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _trayManager.init(onOpenDashboard: () => _appWindow.show(), history: []);
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();

    _loadHistoryFromDisk(); // Fetch saved clips on boot
    Future.delayed(const Duration(milliseconds: 500), () => _appWindow.hide());
  }

  // Reads from Isar and updates the UI
  Future<void> _loadHistoryFromDisk() async {
    final items = await isar.clipboardItems
        .where()
        .sortByTimestampDesc()
        .findAll();
    setState(() {
      _clipboardHistory.clear();
      _clipboardHistory.addAll(items);
    });
    _trayManager.updateMenu(items.map((e) => e.content).toList());
  }

  void _setTheme(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  void onClipboardChanged() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final String? content = clipboardData?.text;

    if (content != null && content.isNotEmpty) {
      // 2. Write to the Database
      await isar.writeTxn(() async {
        // Check if we already have this clip (LRU Logic)
        final existingItem = await isar.clipboardItems
            .where()
            .contentEqualTo(content)
            .findFirst();

        if (existingItem != null) {
          // It's a duplicate! Just update the timestamp to pull it to the top
          existingItem.timestamp = DateTime.now();
          await isar.clipboardItems.put(existingItem);
        } else {
          // It's a brand new clip
          final newItem = ClipboardItem()
            ..content = content
            ..timestamp = DateTime.now();
          await isar.clipboardItems.put(newItem);
        }

        // 3. Keep the vault capped at 50 to save space
        final count = await isar.clipboardItems.count();
        if (count > 50) {
          final oldestItem = await isar.clipboardItems
              .where()
              .sortByTimestamp()
              .findFirst();
          if (oldestItem != null) {
            await isar.clipboardItems.delete(oldestItem.id);
          }
        }
      });

      // Update the UI with the fresh database data
      _loadHistoryFromDisk();
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
        onHide: () => _appWindow.hide(),
        currentThemeMode: _themeMode,
        onThemeChanged: _setTheme,
      ),
    );
  }
}
