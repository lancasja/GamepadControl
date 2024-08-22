//
//  GamepadManager.swift
//  GamepadControl
//
//  Created by Jonathan Lancaster on 7/2/24.
//

import SwiftUI
import GameController

func convertRange(value: Double) -> Double {
        let inputStart = -1.0
        let inputEnd = 1.0
        let outputStart = -180.0
        let outputEnd = 180.0
        
        let inputRange = inputEnd - inputStart
        let outputRange = outputEnd - outputStart
        
        let scaledValue = (value - inputStart) / inputRange
        return outputStart + (scaledValue * outputRange)
    }


class GamepadManager: ObservableObject {
    static let shared = GamepadManager()
    
    @ObservedObject var oscManager = OSCManager.shared
    @ObservedObject var dawState = DAWState.shared
    
    @Published var vendorName: String?
    
    @State private var r2Mode = false
    
    init() {
        setupGamepadObservers()
    }
    
    func setupGamepadObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gamepadConnected),
            name: .GCControllerDidConnect,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gamepadDisconnected),
            name: .GCControllerDidDisconnect,
            object: nil
        )
    }
    
    @objc func gamepadConnected(_ notification: Notification) {
        guard let gamepad = notification.object as? GCController else {
            print("Error getting gamepad")
            return
        }

        self.vendorName = gamepad.vendorName!
        
        print("\(gamepad.vendorName!) connected")
        
        GCController.shouldMonitorBackgroundEvents = true
        
        guard let input = gamepad.physicalInputProfile as? GCDualSenseGamepad else {
            print("Error getting gamepad input")
            return
        }
        
        // Cross
        input.buttonA.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Circle
        input.buttonB.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Square
        input.buttonX.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Triangle
        input.buttonY.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Dpad Up
        input.dpad.up.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Dpad Down
        input.dpad.down.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Dpad Left
        input.dpad.left.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Dpad Right
        input.dpad.right.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // L1
        input.leftShoulder.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // R1
        input.rightShoulder.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // L2
        input.leftTrigger.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released") \(value)")
        }
        
        // R2
        input.rightTrigger.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released") \(value)")
        }
        
        // Left Stick Button (L3)
        input.leftThumbstickButton?.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Right Stick Button (R3)
        input.rightThumbstickButton?.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Left Thumbstick X
        input.leftThumbstick.xAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
        }
        
        // Left Thumbstick Y
        input.leftThumbstick.yAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
        }
        
        // Right Thumbstick X
        input.rightThumbstick.xAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
        }
        
        // Right Thumbstick Y
        input.rightThumbstick.yAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
        }
        
        // Options Button
        input.buttonOptions?.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Create Button
        input.buttonMenu.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // PS Button
        input.buttonHome?.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
        
        // Touchpad Button
        input.touchpadButton.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
        }
    }
    
    @objc func gamepadDisconnected(_ notification: Notification) {
        self.vendorName = nil
        print("Gamepad diconnected")
    }
}


