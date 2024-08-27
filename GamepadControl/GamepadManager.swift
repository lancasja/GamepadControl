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
    
    @Published var gamepad: GCController?
    @Published var vendorName: String?
    
    @Published var xButtonPressed: Bool = false
    @Published var circleButtonPressed: Bool = false
    @Published var squareButtonPressed: Bool = false
    @Published var triangleButtonPressed: Bool = false
    
    @Published var dpadUpPressed: Bool = false
    @Published var dpadRightPressed: Bool = false
    @Published var dpadDownPressed: Bool = false
    @Published var dpadLeftPressed: Bool = false
    
    @Published var l1Pressed: Bool = false
    @Published var r1Pressed: Bool = false
    
    @Published var r2Mode: Bool = false
    
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
        guard let gamepad = notification.object as? GCController else { return }
        self.gamepad = gamepad
        print("\(gamepad.vendorName!) connected")
        self.vendorName = gamepad.vendorName
        
        GCController.shouldMonitorBackgroundEvents = true
        setupGamepadInputHandling(gamepad)
    }
    
    @objc func gamepadDisconnected(_ notification: Notification) {
        self.gamepad = nil
        self.vendorName = nil
        print("Gamepad diconnected")
    }

    func setupGamepadInputHandling(_ gamepad: GCController) {
        gamepad.extendedGamepad?.valueChangedHandler = {
            [weak self] (extGamepad: GCExtendedGamepad, element: GCControllerElement) in
                self?.handleGamepadInput(gamepad: extGamepad, element: element)
        }
    }
    
    func handleGamepadInput(gamepad: GCExtendedGamepad, element: GCControllerElement) {
        DispatchQueue.main.async { [weak self] in
            
            switch element {
            case gamepad.buttonA:
                let isPressed = gamepad.buttonA.isPressed
                self?.xButtonPressed = isPressed
                if isPressed {
                    guard let is_playing = self?.dawState.is_playing else { return }
                    
                    if is_playing {
                        self?.oscManager.send("/live/song/stop_playing")
                    } else {
                        self?.oscManager.send("/live/song/continue_playing")
                    }
                }
            case gamepad.buttonB:
                let isPressed = gamepad.buttonB.isPressed
                self?.circleButtonPressed = isPressed
                if isPressed {
                    guard let record_mode = self?.dawState.record_mode else { return }
                    self?.dawState.record_mode = !record_mode
                    self?.oscManager.send("/live/song/set/record_mode", [!record_mode])
                }
            case gamepad.buttonX:
                let isPressed = gamepad.buttonX.isPressed
                self?.squareButtonPressed = isPressed
                if isPressed {
                    guard let is_playing = self?.dawState.is_playing else { return }
                    
                    if is_playing {
                        self?.oscManager.send("/live/song/stop_playing")
                    }
                    
                    self?.oscManager.send("/live/song/set/current_song_time", [0])
                }
            case gamepad.buttonY:
                let isPressed = gamepad.buttonY.isPressed
                self?.triangleButtonPressed = isPressed
                if isPressed {
                    guard let selectedTrack = self?.dawState.selectedTrack else { return }
                    guard let arm = self?.dawState.tracks[selectedTrack].arm else { return }
                    self?.dawState.tracks[selectedTrack].arm = !arm
                    self?.oscManager.send("/live/track/set/arm", [selectedTrack, !arm])
                }
            case gamepad.dpad:
                self?.dpadDownPressed = gamepad.dpad.down.isPressed
                if gamepad.dpad.down.isPressed {
                    guard let selectedTrack = self?.dawState.selectedTrack else { return }
                    guard let mute = self?.dawState.tracks[selectedTrack].mute else { return }
                    self?.dawState.tracks[selectedTrack].mute = !mute
                    self?.oscManager.send("/live/track/set/mute", [selectedTrack, !mute])
                }
                
                self?.dpadUpPressed = gamepad.dpad.up.isPressed
                if gamepad.dpad.up.isPressed {
                    guard let selectedTrack = self?.dawState.selectedTrack else { return }
                    guard let solo = self?.dawState.tracks[selectedTrack].solo else { return }
                    self?.dawState.tracks[selectedTrack].solo = !solo
                    self?.oscManager.send("/live/track/set/solo", [selectedTrack, !solo])
                }
                
                self?.dpadLeftPressed = gamepad.dpad.left.isPressed
                if gamepad.dpad.left.isPressed {
                    self?.oscManager.send("/live/song/undo")
                }
                
                self?.dpadRightPressed = gamepad.dpad.right.isPressed
                if gamepad.dpad.right.isPressed {
                    self?.oscManager.send("/live/song/redo")
                }
                
            case gamepad.leftShoulder:
                let isPressed = gamepad.leftShoulder.isPressed
                self?.l1Pressed = isPressed
                if isPressed {
                    if let selectedTrack = self?.dawState.selectedTrack {
                        var nextTrack = selectedTrack - 1
                        if let numTracks = self?.dawState.numTracks {
                            if nextTrack < 0 {
                                nextTrack = numTracks - 1
                            }
                        }
                        self?.dawState.selectedTrack = nextTrack
                        self?.oscManager.send("/live/view/set/selected_track", [nextTrack])
                    }
                }
            case gamepad.rightShoulder:
                let isPressed = gamepad.rightShoulder.isPressed
                self?.r1Pressed = isPressed
                if isPressed {
                    if let selectedTrack = self?.dawState.selectedTrack {
                        var nextTrack = selectedTrack + 1
                        if let numTracks = self?.dawState.numTracks {
                            if nextTrack >= numTracks {
                                nextTrack = nextTrack - numTracks
                            }
                        }
                        self?.dawState.selectedTrack = nextTrack
                        self?.oscManager.send("/live/view/set/selected_track", [nextTrack])
                    }
                }
            case gamepad.rightTrigger:
                let isPressed = gamepad.rightTrigger.isPressed
                self?.r2Mode = isPressed
                
            case gamepad.leftThumbstick:
                guard let r2Mode = self?.r2Mode else { return }
                guard let selectedTrack = self?.dawState.selectedTrack else { return }
                guard let volume = self?.dawState.tracks[selectedTrack].volume else { return }
                guard let devices = self?.dawState.tracks[selectedTrack].devices else { return }
                
                let yAxis = gamepad.leftThumbstick.yAxis.value
                let xAxis = gamepad.leftThumbstick.xAxis.value
                
                if r2Mode {
                    var newVol: Float = volume
                    
                    if gamepad.leftThumbstick.up.isPressed {
                        if volume < 1 {
                            newVol = volume + 0.01
                        }
                    }
                    
                    if gamepad.leftThumbstick.down.isPressed {
                        if volume > 0 {
                            newVol = volume - 0.01
                        }
                    }
                    
                    self?.oscManager.send("/live/track/set/volume", [selectedTrack, newVol])
                    self?.dawState.tracks[selectedTrack].volume = newVol
                }
                
                if devices.count > 0 {
                    devices.enumerated().forEach { (deviceIndex, device) in
                        switch device.name {
                        case "360 WalkMix Creator":
                            device.parameters.enumerated().forEach { (paramIndex, param) in
                                if param.name.contains("Azimuth") {
                                    let step: Float = 0.1
                                if let curVal = param.value as? Float {
                                    var newVal = curVal
                                    let deadZone = true
                                    
                                    if (xAxis > 0) && deadZone {
                                        newVal = newVal + step
                                    }
                                    
                                    if (xAxis < 0) && deadZone {
                                        newVal = newVal - step
                                    }
                                    print("Setting parameter \(param.name) to \(newVal) (device \(deviceIndex) param \(paramIndex))")
                                    self?.oscManager.send("/live/device/set/parameter/value", [selectedTrack, deviceIndex, paramIndex, newVal])
                                }
                                }

                            }
                        case "E4L Mono Panner":
                            device.parameters.enumerated().forEach { (paramIndex, param) in
                                switch param.name {
                                case "Radius":
                                    if let curVal = param.value as? Float {
                                        var newVal = curVal
                                        let step: Float = 0.1
                                        let deadZone = abs(xAxis) < 0.2
                                        
                                        if (yAxis > 0) && deadZone {
                                            newVal = newVal + step
                                        }
                                        
                                        if (yAxis < 0) && deadZone {
                                            newVal = newVal - step
                                        }
                                        
                                        self?.oscManager.send(
                                            "/live/device/set/parameter/value",
                                            [selectedTrack, deviceIndex, paramIndex, newVal]
                                        )
                                    }
                                default:
                                    break
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            case gamepad.rightThumbstick:
                guard let r2Mode = self?.r2Mode else { return }
                guard let selectedTrack = self?.dawState.selectedTrack else { return }
                guard let devices = self?.dawState.tracks[selectedTrack].devices else { return }
                
                let yAxis = gamepad.rightThumbstick.yAxis.value
                
                // PANNING
                if r2Mode {
                    self?.oscManager.send("/live/track/set/panning", [selectedTrack, yAxis])
                    
                    if yAxis >= 1 {
                        self?.dawState.tracks[selectedTrack].panning = yAxis - 0.01
                    }
                    
                    if yAxis <= -1 {
                        self?.dawState.tracks[selectedTrack].panning = yAxis + 0.01
                    }
                }
                
                // AZIMUTH
                if devices.count > 0 {
                    devices.enumerated().forEach { (deviceIndex, device) in
                        switch device.name {
                        case "360 WalkMix Creator":
                                device.parameters.enumerated().forEach { (paramIndex, param) in
                                    if param.name.contains("Elevation") {
                                        let step: Float = 0.1
                                    if let curVal = param.value as? Float {
                                        var newVal = curVal
//                                        let deadZone = abs(yAxis) < 0.2
                                        let deadZone = true
                                        
                                        if (yAxis > 0) && deadZone {
                                            newVal = newVal + step
                                        }
                                        
                                        if (yAxis < 0) && deadZone {
                                            newVal = newVal - step
                                        }
                                        
                                        print("Setting parameter \(param.name) to \(newVal) (device \(deviceIndex) param \(paramIndex))")
                                        self?.oscManager.send("/live/device/set/parameter/value", [selectedTrack, deviceIndex, paramIndex, newVal])
                                    }
                                    }
                            }
                        default:
                            break
                        }
                    }
                }

            default:
                break
            }
            
        }
    }
}


