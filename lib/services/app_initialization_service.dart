import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart'; // 🛠 NEW
import 'package:package_info_plus/package_info_plus.dart'; // 🛠 NEW

import '../firebase_options.dart';
import '../models/clipboard_item.dart';
import 'encryption_service.dart';
import 'firestore_sync_service.dart';
import 'audio_service.dart';
import '../models/smart_folder.dart'; // 🛠 NEW

class AppInitializationService {
  static Future<Isar> initializeIsarDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [
        ClipboardItemSchema,
        SmartFolderSchema,
      ], // 🛠 FIX: Added SmartFolderSchema
      directory: dir.path,
    );
  }

  static Future<void> initializeWindowManager() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1100, 750),
      center: true,
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  static Future<void> initializeFirebaseAndSecurity() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await EncryptionService.init();
    await FirestoreSyncService.authenticate();
    await AudioService.init();
  }

  // 🛠 NEW: Registers the app location for macOS Launch at Login
  static Future<void> initializeLaunchAtStartup() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
    );
  }
}
