//
//  GamepadControlApp.swift
//  GamepadControl
//
//  Created by Admin on 2/26/24.
//

import SwiftUI

@main
struct GCTestApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var gamepad = GamepadManager()
    
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
