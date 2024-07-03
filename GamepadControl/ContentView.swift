//
//  ContentView.swift
//  GamepadControl
//
//  Created by JL on 2/26/24.
//
//  AbletonOSC docs: https://github.com/ideoforms/AbletonOSC
//  OSCKit docs: https://orchetect.github.io/OSCKit/documentation/osckit/
//

import SwiftUI
import SwiftData
import GameController

enum ButtonTypes: String {
    case x = "xmark.circle"
    case circle = "circle.circle"
    case square = "square.circle"
    case triangle = "triangle.circle"
    case dpad = "dpad"
    case dpadLeft = "dpad.left.filled"
    case dpadUp = "dpad.up.filled"
    case dpadRight = "dpad.right.filled"
    case dpadDown = "dpad.down.filled"
    case l1 = "l1.button.roundedbottom.horizontal"
    case r1 = "r1.button.roundedbottom.horizontal"
}

struct GamepadButton: View {
    var symbol: ButtonTypes = .circle
    var isPressed: Bool = false
    
    var body: some View {
        Image(systemName: "\(symbol.rawValue)\(isPressed ? ".fill" : "")")
            
    }
}

struct ContentView: View {
    @StateObject private var gamepadManager = GamepadManager.shared
    @StateObject private var dawState = DAWState.shared
    
    var body: some View {
        VStack {
            Text("\(gamepadManager.gamepad?.vendorName ?? "No controller")")
            HStack {
                Text(dawState.is_playing ? "Playing" : "Stopped")
                Text("Current beat: \(dawState.current_beat)")
                Text(dawState.record_mode ? "Recording" : "")
            }
            
            HStack {
                ForEach(dawState.tracks) { track in
                    VStack {
                        Text("\(track.name)")
                            .foregroundStyle(dawState.selectedTrack == track.index ? .blue : .white)
                        
                        Text("Mute: \(track.mute ? "on" : "off")")
                        Text("Solo: \(track.solo ? "on" : "off")")
                        Text("Arm: \(track.arm ? "on" : "off")")
                        
                        Text("Pan: \(track.panning)")
                        Text("Vol: \(track.volume)")
                        
                        ForEach(track.devices) { device in
                            VStack {
                                Text("Name: \(device.name ?? "")")
                                Text("Type: \(device.type ?? 0)")
                                Text("Class: \(device.class_name ?? "")")
                            }
                        }
                    }
                }
            }
            
            HStack {
                VStack {
                    GamepadButton(symbol: .circle, isPressed: gamepadManager.circleButtonPressed)
                    GamepadButton(symbol: .square, isPressed: gamepadManager.squareButtonPressed)
                    GamepadButton(symbol: .triangle, isPressed: gamepadManager.triangleButtonPressed)
                    GamepadButton(symbol: .x, isPressed: gamepadManager.xButtonPressed)
                }
                
                VStack {
                    
                    ZStack {
                        if gamepadManager.dpadUpPressed {
                            GamepadButton(symbol: .dpadUp)
                        }
                        
                        if gamepadManager.dpadDownPressed {
                            GamepadButton(symbol: .dpadDown)
                        }
                        
                        if gamepadManager.dpadLeftPressed {
                            GamepadButton(symbol: .dpadLeft)
                        }
                        
                        if gamepadManager.dpadRightPressed {
                            GamepadButton(symbol: .dpadRight)
                        }
                        
                        GamepadButton(symbol: .dpad)
                    }
                }
                
                VStack {
                    GamepadButton(symbol: .l1, isPressed: gamepadManager.l1Pressed)
                    GamepadButton(symbol: .r1, isPressed: gamepadManager.r1Pressed)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
