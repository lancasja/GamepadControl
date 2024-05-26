//
//  MenuBarView.swift
//  GamepadControl
//
//  Created by Admin on 5/25/24.
//

import SwiftUI

struct GamepadInputPicker: View {
    enum GamepadInputs: String, CaseIterable, Identifiable {
        var id: Self { self }
        case r1, l1, r2, l2, dpadUp, dpadDown, dpadLeft, dpadRight, triangle, circle, x, square, option, menu, home, leftStick, rightStick, mic
    }
    
    @State private var selectedGamepadInput: GamepadInputs
    
    var title: String = "Picker"
    
    init(_ title: String, defaultItem: GamepadInputs = .circle) {
        self.title = title
        self.selectedGamepadInput = defaultItem
    }
    
    var body: some View {
        Picker(self.title, selection: $selectedGamepadInput) {
            Text("R1").tag(GamepadInputs.r1)
            Text("R2").tag(GamepadInputs.r2)
            Text("L1").tag(GamepadInputs.l1)
            Text("L2").tag(GamepadInputs.l2)
            Text("Dpad Left").tag(GamepadInputs.dpadLeft)
            Text("Dpad Up").tag(GamepadInputs.dpadUp)
            Text("Dpad Right").tag(GamepadInputs.dpadRight)
            Text("Dpad Down").tag(GamepadInputs.dpadDown)
            Text("Square").tag(GamepadInputs.square)
            Text("Triangle").tag(GamepadInputs.triangle)
            Text("Circle").tag(GamepadInputs.circle)
            Text("X").tag(GamepadInputs.x)
            Text("Option").tag(GamepadInputs.option)
            Text("Menu").tag(GamepadInputs.menu)
            Text("Home").tag(GamepadInputs.home)
            Text("Mic").tag(GamepadInputs.mic)
            Text("Left Stick").tag(GamepadInputs.leftStick)
            Text("Right Stick").tag(GamepadInputs.rightStick)
        }
    }
}

struct MenuBarView: View {
    @AppStorage("gamepad_connected") var gamepadConnencted: Bool?
    @AppStorage("gamepad_name") var gamepadName: String = "No gamepad connected"
    @AppStorage("live_version") var liveVersion: String?
    
    var body: some View {
        VStack {
            
            if let connected = gamepadConnencted {
                Label(gamepadName, systemImage: "circle\(connected ? ".fill" : "")")
                    .padding(.top, 8)
                    .padding(.bottom, 4)
            }
            
            TabView {
                VStack(alignment: .leading) {
                    if liveVersion != nil {
                        Text("Ableton Live \(liveVersion ?? "")")
                    
                        ScrollView {
                            DisclosureGroup {
                                List {
                                    GamepadInputPicker("Play", defaultItem: .x)
                                    GamepadInputPicker("Stop", defaultItem: .square)
                                    GamepadInputPicker("Metronome", defaultItem: .mic)
                                }
                            } label : {
                                Label("Song", systemImage: "music.note")
                            }
                            
                            DisclosureGroup {
                                VStack {
                                    List {
                                        Text("Mute")
                                        Text("Solo")
                                        Text("Rec Enable")
                                    }.listStyle(.plain)
                                }
                            } label : {
                                Label("Tracks", systemImage: "slider.vertical.3")
                            }
                        }
                    } else {
                        Text("No DAW connected")
                    }
                }
                .tabItem {
                    Label("DAW", systemImage: "waveform")
                }
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing])
                
                Text("Spatial")
                    .tabItem {
                        Label("Spatial", systemImage: "headphones")
                    }
                
                Text("Settings")
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            
            Button("Open visualizer") {
                
            }
            .padding(.top, 4)
            .padding(.bottom, 12)
        }.padding([.leading, .trailing])
    }
}

