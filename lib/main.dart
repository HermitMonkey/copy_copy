import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NEW IMPORT
import 'firebase_options.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:system_tray/system_tray.dart';

import 'services/clipboard_classifier.dart';
import 'services/clipboard_enricher.dart';
import 'models/clipboard_item.dart';
import 'phoenix_board.dart';
import 'system_tray_manager.dart';

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  final List<ClipboardItem> _clipboardHistory = [];
  ThemeMode _themeMode = ThemeMode.system;

  // --- NEW: Dynamic Tray Limit State ---
  int _trayLimit = 15;

  @override
  void initState() {
    super.initState();
    _trayManager.init(onOpenDashboard: () => _appWindow.show(), history: []);
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();

    _loadSettingsAndHistory(); // Loads user preferences first!
    Future.delayed(const Duration(milliseconds: 500), () => _appWindow.hide());
  }

  // --- NEW: Preference Loader ---
  Future<void> _loadSettingsAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _trayLimit = prefs.getInt('trayLimit') ?? 15; // Default to 15 if not set
    });
    _loadHistoryFromDisk();
  }

  // --- NEW: Preference Saver ---
  Future<void> _updateTrayLimit(int newLimit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trayLimit', newLimit);
    setState(() {
      _trayLimit = newLimit;
    });
    _loadHistoryFromDisk(); // Instantly update the tray when settings change
  }

  Future<void> _loadHistoryFromDisk() async {
    final items = await isar.clipboardItems
        .where()
        .sortByTimestampDesc()
        .findAll();

    setState(() {
      _clipboardHistory.clear();
      _clipboardHistory.addAll(items);
    });

    // USES THE DYNAMIC LIMIT HERE
    final trayItems = items.take(_trayLimit).map((e) {
      String displayText = e.title ?? e.content;
      displayText = displayText.replaceAll('\n', ' ').trim();
      if (displayText.length > 40) {
        displayText = '${displayText.substring(0, 40)}...';
      }
      return displayText;
    }).toList();

    _trayManager.updateMenu(trayItems);
  }

  void _setTheme(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  void onClipboardChanged() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final String? content = clipboardData?.text;

    if (content != null && content.isNotEmpty) {
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

      _loadHistoryFromDisk();

      final newlySavedItem = await isar.clipboardItems
          .where()
          .contentEqualTo(content)
          .findFirst();
      if (newlySavedItem != null &&
          newlySavedItem.contentType == 'url' &&
          !newlySavedItem.isSensitive) {
        ClipboardEnricher.enrichItem(isar, newlySavedItem.id).then((_) {
          _loadHistoryFromDisk();
        });
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
        onHide: () => _appWindow.hide(),
        currentThemeMode: _themeMode,
        onThemeChanged: _setTheme,
        // --- NEW: Pass state to Dashboard ---
        currentTrayLimit: _trayLimit,
        onTrayLimitChanged: _updateTrayLimit,
      ),
    );
  }
}
