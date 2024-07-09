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

struct ParameterView: View {
    var device: Device
    
    init(device: Device) {
        self.device = device
//        print(device.parameters)
    }
    
    var body: some View {
        VStack {
            ForEach(device.parameters) { param in
                HStack {
                    Text(param.name)
                    Text("\(param.value)")
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var gamepadManager = GamepadManager.shared
    @StateObject private var dawState = DAWState.shared
    
    var body: some View {
        VStack {
            MixerView()
            
            Divider()
            
            Text("\(gamepadManager.gamepad?.vendorName ?? "No controller")")
            
            Divider()
            
            HStack {
                Text(dawState.is_playing ? "Playing" : "Stopped")
                Text("Current beat: \(dawState.current_beat)")
                Text(dawState.record_mode ? "Recording" : "")
            }
            
            HStack(alignment: .top) {
                ForEach(dawState.tracks) { track in
                    VStack {
                        Divider()
                        
                        Text("\(track.name)")
                            .foregroundStyle(dawState.selectedTrack == track.index ? .blue : .white)
                        
                        Text("Mute: \(track.mute ? "on" : "off")")
                        Text("Solo: \(track.solo ? "on" : "off")")
                        Text("Arm: \(track.arm ? "on" : "off")")
                        
                        Text("Pan: \(track.panning)")
                        Text("Vol: \(track.volume)")
                        
                        if !track.devices.isEmpty {
                            Divider()
                            
                            ForEach(track.devices) { device in
                                Text(device.name)
                                ParameterView(device: device)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
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
