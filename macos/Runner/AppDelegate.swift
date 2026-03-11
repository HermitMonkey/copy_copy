import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  
  // 1. Our custom logic: Keep app alive in tray when window is closed
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  // 2. Apple's required security logic (what the blue terminal text was asking for)
  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}