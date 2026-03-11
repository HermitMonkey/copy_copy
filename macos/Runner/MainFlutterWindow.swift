import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    self.isReleasedWhenClosed = false
    
    // Hard limit on window size to prevent UI overflow
    self.minSize = NSSize(width: 700, height: 500)

    super.awakeFromNib()
  }
  
  // Intercept the red 'X' button
  override func close() {
    self.orderOut(nil)
    // When hidden, remove from Dock and CMD+Tab
    NSApp.setActivationPolicy(.accessory)
  }

  // Intercept when the window is shown again (from the tray menu)
  override func makeKeyAndOrderFront(_ sender: Any?) {
    super.makeKeyAndOrderFront(sender)
    // When visible, show in Dock and CMD+Tab
    NSApp.setActivationPolicy(.regular)
  }
}