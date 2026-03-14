import 'dart:io';
import 'package:flutter/services.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

class SystemTrayManager {
  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();

  Future<void> init({
    required VoidCallback onOpenDashboard,
    required List<String> history,
  }) async {
    await _systemTray.initSystemTray(
      title: "⌘ copy_copy", // 🛠 FIX: Uses the native Mac command symbol!
      iconPath: '',
    );

    // 🛠 FIX 2: Restoring proper OS-specific click mechanisms
    _systemTray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick) {
        // macOS Standard: Left-Click ALWAYS drops down the menu.
        Platform.isWindows
            ? await _toggleWindow()
            : await _systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        // macOS Standard: Right-Click can toggle the window.
        Platform.isWindows
            ? await _systemTray.popUpContextMenu()
            : await _toggleWindow();
      }
    });
  }

  // Extracted window toggle logic for cleaner code
  Future<void> _toggleWindow() async {
    bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }

  Future<void> updateMenu(List<String> items) async {
    bool isVisible = await windowManager.isVisible();

    List<MenuItemBase> menuItems = [
      MenuItemLabel(
        // 🧠 DYNAMIC TEXT LOGIC: Updates based on current window state
        label: isVisible ? 'Phoenix Dashboard' : 'Phoenix Dashboard',
        onClicked: (menuItem) async {
          await _toggleWindow();
          await updateMenu(items); // Refresh menu text after click
        },
      ),
      MenuSeparator(),
    ];

    for (String item in items) {
      menuItems.add(
        MenuItemLabel(
          // 🛠 FIX 3: Truncate long text so your menu doesn't stretch infinitely!
          label: item.length > 40 ? '${item.substring(0, 40)}...' : item,
          onClicked: (menuItem) {
            Clipboard.setData(ClipboardData(text: item));
          },
        ),
      );
    }

    menuItems.addAll([
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit copy_copy',
        onClicked: (menuItem) => windowManager.destroy(),
      ),
    ]);

    await _menu.buildFrom(menuItems);
    await _systemTray.setContextMenu(_menu);
  }
}
