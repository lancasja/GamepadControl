import SwiftUI
import GameController

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @AppStorage("showWindow") var showWindow = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Close main window on startup
        NSApp.windows.forEach { window in
            if (window.identifier?.rawValue == "visualizer") {
                // assign delegate to window for `windowWillClose`
                window.delegate = self
                window.close()
            }
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        print("Closing window")
        showWindow = false
    }
}
