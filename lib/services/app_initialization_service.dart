import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';
import 'package:window_manager/window_manager.dart';
import '../firebase_options.dart';
import '../models/clipboard_item.dart';
import 'encryption_service.dart';
import 'firestore_sync_service.dart';

/// Service to initialize all application components in order
class AppInitializationService {
  /// Initialize the window manager with standard options
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

  /// Initialize Firebase and security services
  static Future<void> initializeFirebaseAndSecurity() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await EncryptionService.init();
    await FirestoreSyncService.authenticate();
  }

  /// Initialize the local Isar database
  static Future<Isar> initializeIsarDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([ClipboardItemSchema], directory: dir.path);
  }
}
