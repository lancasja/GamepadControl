import SwiftUI

struct MenuBarView: View {
    @AppStorage("showWindow") var showWindow = false
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @EnvironmentObject var gamepad: GamepadManager
    
    var body: some View {
        Text(gamepad.vendorName ?? "No gamepad connected")
        
        Divider()
        
        Button(showWindow ? "Close visualizer" : "Open visualizer") {
            if showWindow {
                dismissWindow(id: "visualizer")
            } else {
                openWindow(id: "visualizer")
            }
            
            showWindow.toggle()
        }
        
        Divider()
        
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
}
