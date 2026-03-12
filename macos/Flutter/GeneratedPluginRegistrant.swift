//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import clipboard_watcher
import cloud_firestore
import firebase_core
import isar_flutter_libs
import shared_preferences_foundation
import system_tray
import url_launcher_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  ClipboardWatcherPlugin.register(with: registry.registrar(forPlugin: "ClipboardWatcherPlugin"))
  FLTFirebaseFirestorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseFirestorePlugin"))
  FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
  IsarFlutterLibsPlugin.register(with: registry.registrar(forPlugin: "IsarFlutterLibsPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SystemTrayPlugin.register(with: registry.registrar(forPlugin: "SystemTrayPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
}
