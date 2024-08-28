import SwiftUI
import SwiftData

@main
struct GCTestApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var gamepad = GamepadManager()
    
    var body: some Scene {
        Window("Visualizer", id: "visualizer") {
            ContentView().environmentObject(gamepad)
        }
        
        MenuBarExtra {
            MenuBarView().environmentObject(gamepad)
        } label: {
            Image(systemName: "gamecontroller\(gamepad.vendorName != nil ? ".fill" : "")")
        }
    }
}
