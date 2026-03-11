import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:system_tray/system_tray.dart';
import 'phoenix_board.dart';
import 'system_tray_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  final List<String> _clipboardHistory = [];

  // 3-POINT THEME STATE: Defaulting to System
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _trayManager.init(
      onOpenDashboard: () => _appWindow.show(),
      history: _clipboardHistory,
    );
    clipboardWatcher.addListener(this);
    clipboardWatcher.start();
    Future.delayed(const Duration(milliseconds: 500), () => _appWindow.hide());
  }

  // Updates the theme based on your 3-point selection
  void _setTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  void onClipboardChanged() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final String? content = clipboardData?.text;

    if (content != null && content.isNotEmpty) {
      setState(() {
        int existingIndex = _clipboardHistory.indexOf(content);
        if (existingIndex != -1 && existingIndex < 21) {
          _clipboardHistory.removeAt(existingIndex);
        }
        _clipboardHistory.insert(0, content);
        if (_clipboardHistory.length > 50) _clipboardHistory.removeLast();
      });
      _trayManager.updateMenu(_clipboardHistory);
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
        currentThemeMode: _themeMode, // Passing the full enum
        onThemeChanged: _setTheme,
      ),
    );
  }
}
