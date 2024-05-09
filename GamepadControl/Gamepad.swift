//
//  Gamepad.swift
//  GamepadControl
//
//  Created by Admin on 4/1/24.
//

import SwiftUI
import GameController

enum GameControlKeys: String {
    case DownArrow, UpArrow, Triangle, L1, R1
}

class Gamepad: ObservableObject {
    struct ButtonElement {
        var id = UUID()
        var offSymbol: String
        var onSymbol: String
        var isPressed: Bool = false
    }
    
    struct TriggerElement: Identifiable {
        var id = UUID()
        var offSymbol: String
        var onSymbol: String
        var isPressed: Bool = false
        var value: Float = 0.0
    }
    
    struct StickElement: Identifiable {
        var id = UUID()
        var offSymbol: String
        var onSymbol: String
        var isPressed: Bool = false
        var x: Float = 0.0
        var y: Float = 0.0
    }
    
    var keymap: [GameControlKeys : AudioControlAction] = [
        GameControlKeys.DownArrow: AudioControlAction.trackMute,
        GameControlKeys.UpArrow: AudioControlAction.trackSolo,
        GameControlKeys.Triangle: AudioControlAction.trackArm,
        GameControlKeys.L1: AudioControlAction.trackPrevious,
        GameControlKeys.R1: AudioControlAction.trackNext
    ]
    
    
    @Published var connected = false
    
    @Published var elements = [
        "R1 Button": ButtonElement(offSymbol: "r1.rectangle.roundedbottom", onSymbol: "r1.rectangle.roundedbottom.fill"),
        "L1 Button": ButtonElement(offSymbol: "l1.rectangle.roundedbottom", onSymbol: "l1.rectangle.roundedbottom.fill")
        
    ]
    
    
    init() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect, object: nil, queue: nil, using: didConnect
        )
        
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect, object: nil, queue: nil, using: didDisconnect
        )
    }
    
    func didConnect(_ notification: Notification) {
        print("controller connected")
        self.connected = true
        
        let controller = notification.object as! GCController
        
        controller.extendedGamepad?.rightShoulder.pressedChangedHandler = { (button, value, pressed) in
            if let action = self.keymap[GameControlKeys.R1] {
                NotificationCenter.default.post(
                    name: Notification.Name(action.rawValue),
                    object: nil
                )
            }
        }
        
        controller.extendedGamepad?.leftShoulder.pressedChangedHandler = { (button, value, pressed) in
            if let action = self.keymap[GameControlKeys.L1] {
                NotificationCenter.default.post(
                    name: Notification.Name(action.rawValue),
                    object: nil
                )
            }
        }
        
        controller.extendedGamepad?.buttonY.pressedChangedHandler = { (button, value, pressed) in
            if let action = self.keymap[GameControlKeys.Triangle] {
                NotificationCenter.default.post(
                    name: Notification.Name(action.rawValue),
                    object: nil
                )
            }
        }
        
        controller.extendedGamepad?.dpad.down.pressedChangedHandler = { (button, value, pressed) in
            if let action = self.keymap[GameControlKeys.DownArrow] {
                NotificationCenter.default.post(
                    name: Notification.Name(action.rawValue),
                    object: nil
                )
            }
        }
        
        controller.extendedGamepad?.dpad.up.pressedChangedHandler = { (button, value, pressed) in
            if let action = self.keymap[GameControlKeys.UpArrow] {
                NotificationCenter.default.post(
                    name: Notification.Name(action.rawValue),
                    object: nil
                )
            }
        }

    }
    
    func didDisconnect(_ notification: Notification) {
        print("controller disconnected")
        self.connected = false
    }
}
