//
//  GamepadControlApp.swift
//  GamepadControl
//
//  Created by Admin on 2/26/24.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @AppStorage("showWindow") var showWindow = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.windows.forEach { window in
            if (window.identifier?.rawValue == "visualizer") {
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

@main
struct GCTestApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @AppStorage("showWindow") var showWindow = false
    
    var body: some Scene {
        Window("Visualizer", id: "visualizer") {
            ContentView()
        }
        
        MenuBarExtra("Stellar Gamepad", systemImage: "gamecontroller") {
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
}
