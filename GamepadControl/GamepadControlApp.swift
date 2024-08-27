//
//  GamepadControlApp.swift
//  GamepadControl
//
//  Created by Admin on 2/26/24.
//

import SwiftUI
import SwiftData

@main
struct GCTestApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var gamepad = GamepadManager()
    @StateObject private var osc = OSCManager()
    
    var body: some Scene {
        Window("Visualizer", id: "visualizer") {
            ContentView()
                .environmentObject(gamepad)
                .environmentObject(osc)
        }
        
        MenuBarExtra {
            MenuBarView()
                .environmentObject(gamepad)
                .environmentObject(osc)
        } label: {
            Image(systemName: "gamecontroller\(gamepad.vendorName != nil ? ".fill" : "")")
        }
    }
}
