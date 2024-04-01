//
//  Gamepad.swift
//  GamepadControl
//
//  Created by Admin on 4/1/24.
//

import SwiftUI
import GameController

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
            if let name = button.localizedName {
                self.handleButton(name, pressed)
            }
        }
        
        controller.extendedGamepad?.leftShoulder.pressedChangedHandler = { (button, value, pressed) in
            if let name = button.localizedName {
                self.handleButton(name, pressed)
            }
        }
    }
    
    func didDisconnect(_ notification: Notification) {
        print("controller disconnected")
        self.connected = false
    }
    
    func handleButton(_ name: String, _ pressed: Bool) {
        self.elements[name]?.isPressed = pressed
    }
}
