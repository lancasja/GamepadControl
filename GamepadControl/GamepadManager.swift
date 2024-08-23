//
//  GamepadManager.swift
//  GamepadControl
//
//  Created by Jonathan Lancaster on 7/2/24.
//

import SwiftUI
import GameController

class GamepadManager: ObservableObject {
    @StateObject private var oscManager = OSCManager.shared
    
    var vendorName: String?
    
    var r2Mode = false
    var l2Mode = false
    
    var leftShoulderPressed = false
    var rightShoulderPressed = false
    
    var leftTriggerValue: Float = 0
    var rightTriggerValue: Float = 0
    
    var leftStickXValue: Float = 0
    var leftStickYValue: Float = 0
    var rightStickXValue: Float = 0
    var rightStickYValue: Float = 0
    
    var leftStickPressed = false
    var rightStickPressed = false
    
    var dpadUpPressed = false
    var dpadDownPressed = false
    var dpadLeftPressed = false
    var dpadRightPressed = false
    
    var crossPressed = false
    var circlePressed = false
    var squarePressed = false
    var trianglePressed = false
    
    var optionsPressed = false
    var menuPressed = false
    var homePressed = false
    
    var tpadPressed = false
    
    var tpadPrimaryXValue: Float = 0
    var tpadPrimaryYValue: Float = 0
    var tpadSecondaryXValue: Float = 0
    var tpadSecondaryYValue: Float = 0
    
    init() {
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
            self.crossPressed = pressed
            // play/continue
        }
        
        // Circle
        input.buttonB.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.circlePressed = pressed
            // record
        }
        
        // Square
        input.buttonX.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.squarePressed = pressed
            // pause/stop
        }
        
        // Triangle
        input.buttonY.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.trianglePressed = pressed
            // arm
        }
        
        // Dpad Up
        input.dpad.up.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.dpadUpPressed = pressed
            //solo
        }
        
        // Dpad Down
        input.dpad.down.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.dpadDownPressed = pressed
            // mute
        }
        
        // Dpad Left
        input.dpad.left.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.dpadLeftPressed = pressed
        }
        
        // Dpad Right
        input.dpad.right.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.dpadRightPressed = pressed
        }
        
        // L1
        input.leftShoulder.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.leftShoulderPressed = pressed
            // previous track
        }
        
        // R1
        input.rightShoulder.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.rightShoulderPressed = pressed
            // next track
        }
        
        // L2
        input.leftTrigger.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released") \(value)")
            self.l2Mode = pressed
            self.leftTriggerValue = value
        }
        
        // R2
        input.rightTrigger.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released") \(value)")
            self.r2Mode = pressed
            self.rightTriggerValue = value
        }
        
        // Left Stick Button (L3)
        input.leftThumbstickButton?.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.leftStickPressed = pressed
        }
        
        // Right Stick Button (R3)
        input.rightThumbstickButton?.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.rightStickPressed = pressed
        }
        
        // Left Stick X
        input.leftThumbstick.xAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
            self.leftStickXValue = value
            
            if self.l2Mode && !self.r2Mode {
                print("Width: \(value)")
            } else {
                print("Azimuth: \(value)")
            }
        }
        
        // Left Stick Y
        input.leftThumbstick.yAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
            self.leftStickYValue = value
            
            if self.r2Mode && !self.l2Mode {
                print("Gain: \(value)")
            }
        }
        
        // Right Stick X
        input.rightThumbstick.xAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
            self.rightStickXValue = value
        }
        
        // Right Stick Y
        input.rightThumbstick.yAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
            self.rightStickYValue = value
            print("Elevation: \(value)")
        }
        
        // Options Button
        input.buttonOptions?.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.optionsPressed = pressed
        }
        
        // Create Button
        input.buttonMenu.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.menuPressed = pressed
        }
        
        // PS Button
        input.buttonHome?.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.homePressed = pressed
        }
        
        // Touchpad Button
        input.touchpadButton.valueChangedHandler = { element, value, pressed in
            print("\(element.localizedName!) \(pressed ? "pressed" : "released")")
            self.tpadPressed = pressed
        }
        
        // Touchpad First Finger X
        input.touchpadPrimary.xAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
            self.tpadPrimaryXValue = value
        }
        
        // Touchpad First Finger Y
        input.touchpadPrimary.yAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
            self.tpadPrimaryYValue = value
        }
        
        // Touchpad Second Finger X
        input.touchpadSecondary.xAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
            self.tpadSecondaryXValue = value
        }
        
        // Touchpad Second Finger Y
        input.touchpadSecondary.yAxis.valueChangedHandler = { element, value in
            print("\(element.localizedName!) \(value)")
            self.tpadSecondaryYValue = value
        }
    }
    
    @objc func gamepadDisconnected(_ notification: Notification) {
        self.vendorName = nil
        print("Gamepad diconnected")
    }
}
