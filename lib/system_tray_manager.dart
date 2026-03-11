import 'package:flutter/services.dart';
import 'package:system_tray/system_tray.dart';

class SystemTrayManager {
  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();
  late Function onOpenDashboard;

  Future<void> init({
    required Function onOpenDashboard,
    required List<String> history,
  }) async {
    this.onOpenDashboard = onOpenDashboard;
    await _systemTray.initSystemTray(
      title: "Copy-Copy",
      iconPath: 'assets/app_icon.png',
    );
    await updateMenu(history);

    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) _systemTray.popUpContextMenu();
    });
  }

  Future<void> updateMenu(List<String> history) async {
    List<MenuItemBase> items = [
      MenuItemLabel(
        label: 'Open Phoenix Board',
        onClicked: (i) => onOpenDashboard(),
      ),
      MenuSeparator(),
    ];

    for (var clip in history) {
      String display = clip.length > 30
          ? "${clip.substring(0, 27).replaceAll('\n', ' ')}..."
          : clip.replaceAll('\n', ' ');
      items.add(
        MenuItemLabel(
          label: display,
          onClicked: (i) async {
            await Clipboard.setData(ClipboardData(text: clip));
          },
        ),
      );
    }

    items.addAll([
      MenuSeparator(),
      MenuItemLabel(label: 'Exit Copy-Copy', onClicked: (i) => exitApp()),
    ]);

    await _menu.buildFrom(items);
    await _systemTray.setContextMenu(_menu);
  }

  void exitApp() => SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}
