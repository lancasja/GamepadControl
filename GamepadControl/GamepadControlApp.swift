//
//  GamepadControlApp.swift
//  GamepadControl
//
//  Created by Admin on 2/26/24.
//

import SwiftUI

@main
struct GamepadControlApp: App {
    @AppStorage("showMenuBarExtra") private var showMenuBarExtra = true
    @AppStorage("showContent") private var showContent = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        MenuBarExtra(
            "App Menu Bar Extra",
            systemImage: "waveform.circle",
            isInserted: $showMenuBarExtra
        ) {
//            MenuBarView()
        }.menuBarExtraStyle(.window)
    }
}
