import SwiftUI
import GameController
import OSCKit

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
    
    @Published var leftStickXValue: Float = 0.0
    @Published var leftStickYValue: Float = 0.0
    @Published var rightStickXValue: Float = 0.0
    @Published var rightStickYValue: Float = 0.0
    
    @Published var r2Mode: Bool = false
    @Published var l2Mode: Bool = false
    
    @Published var deadZone: Float = 0.1
    
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
 
    
    func leftThumbstickChangeHandler(parameterName: String, element: GCControllerAxisInput, value: Float) {
        
        let selectedTrackIndex: Int = self.dawState.selectedTrack
        let selectedTrack: Track = self.dawState.tracks[selectedTrackIndex]
        let devices = selectedTrack.devices

        
        if devices.count > 0 {
            devices.enumerated().forEach { (deviceIndex, device) in
                if device.name == "360 WalkMix Creator" {
                    device.parameters.enumerated().forEach { (paramIndex, param) in
                            if param.name.contains(parameterName) {
                                if let curVal = param.value as? Float {
                                    var newVal = curVal
                                    let step: Float = 0.1
                                    
                                    if value != 0 && abs(value) > self.deadZone {
                                        newVal += step * (value * 0.5)
                                        
                                        if newVal >= param.max {
                                            newVal = param.max
                                        }
                                        
                                        if newVal <= param.min {
                                            newVal = param.min
                                        }
                                    }
                                    
                                    print("Setting parameter \(param.name) to \(newVal) (device \(deviceIndex) param \(paramIndex))")
                                    self.oscManager.send("/live/device/set/parameter/value", [selectedTrackIndex, deviceIndex, paramIndex, newVal])
                                }
                            }
                    }
                }
            }
        }
    }
    
    
    func startPolling() {
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(pollThumbstick), userInfo: nil, repeats: true)
    }
    
    @objc func pollThumbstick() {
        guard let input = self.gamepad?.physicalInputProfile as? GCDualSenseGamepad else {
            print("Error getting gamepad input")
            return
        }
        self.l2Mode = input.leftTrigger.isPressed
        self.r2Mode = input.rightTrigger.isPressed
        
        if abs(input.leftThumbstick.yAxis.value) > self.deadZone {
            if self.r2Mode && !self.l2Mode {
                self.leftThumbstickChangeHandler(parameterName:"Gain", element:input.leftThumbstick.yAxis, value:input.leftThumbstick.yAxis.value)
                
            }
        }
        
        if abs(input.leftThumbstick.xAxis.value) > self.deadZone {
            let value = input.leftThumbstick.xAxis.value
            let element = input.leftThumbstick.xAxis
            if self.l2Mode && !self.r2Mode {
                self.leftThumbstickChangeHandler(parameterName: "Width", element: element, value: value)
            } else if !self.r2Mode && !self.l2Mode {
                self.leftThumbstickChangeHandler(parameterName: "Azimuth", element: element, value: value)
            }
        }
        
        if abs(input.rightThumbstick.yAxis.value) > self.deadZone && !self.r2Mode && !self.l2Mode {
            let value = input.rightThumbstick.yAxis.value
            let element = input.rightThumbstick.yAxis
            self.leftThumbstickChangeHandler(parameterName: "Elevation", element: element, value: value)
        }
    }
    
    @objc func gamepadConnected(_ notification: Notification) {
        guard let gamepad = notification.object as? GCController else { return }
        self.gamepad = gamepad
        print("\(gamepad.vendorName!) connected")
        self.vendorName = gamepad.vendorName
        
        GCController.shouldMonitorBackgroundEvents = true
        
        guard let input = gamepad.physicalInputProfile as? GCDualSenseGamepad else {
            print("Error getting gamepad input")
            return
            
        }
        
        input.buttonA.valueChangedHandler = { element, value, pressed in
            self.xButtonPressed = pressed
            
            if !pressed {
                let is_playing = self.dawState.is_playing
                
                if is_playing {
                    self.oscManager.send("/live/song/stop_playing")
                } else {
                    self.oscManager.send("/live/song/start_playing")
                }
            }
        }
        
        input.buttonB.valueChangedHandler = { element, value, pressed in
            self.circleButtonPressed = pressed
            
            if !pressed {
                let record_mode = self.dawState.record_mode
                self.dawState.record_mode = !record_mode
                self.oscManager.send("/live/song/set/record_mode", [!record_mode])
            }
        }
        
        input.buttonX.valueChangedHandler = { element, value, pressed in
            self.squareButtonPressed = pressed
            
            if !pressed {
                self.oscManager.send("/live/song/stop_playing")
            }
        }
        
        input.buttonY.valueChangedHandler = { element, value, pressed in
            self.triangleButtonPressed = pressed
            
            if !pressed {
                let selectedTrackIndex = self.dawState.selectedTrack
                let arm = self.dawState.tracks[selectedTrackIndex].arm
                self.dawState.tracks[selectedTrackIndex].arm = !arm
                self.oscManager.send("/live/track/set/arm", [selectedTrackIndex, !arm])
            }
        }
        
        input.dpad.down.valueChangedHandler = { element, value, pressed in
            self.dpadDownPressed = pressed
            
            if !pressed {
                let selectedTrackIndex = self.dawState.selectedTrack
                var selectedTrack: Track = self.dawState.tracks[selectedTrackIndex]

                selectedTrack.devices.enumerated().forEach { deviceIndex, device in
                    if (device.name == "360 WalkMix Creator") && (device.parameters.count > 0) {
                        device.parameters.enumerated().forEach { paramIndex, param in
                            if param.name.contains("Mute") {
                                let muteValue = selectedTrack.devices[deviceIndex].parameters[paramIndex].value
                                let mute: Bool = (muteValue as! Float == 1.0) ? true : false
                                
                                selectedTrack.devices[deviceIndex].parameters[paramIndex].value = !mute ? 1.0 : 0.0
                                
                                self.oscManager.send(
                                    "/live/device/set/parameter/value",
                                    [selectedTrackIndex, deviceIndex, paramIndex, !mute]
                                )
                            }
                        }
                    }
                }
            }
        }
        
        input.dpad.up.valueChangedHandler = { element, value, pressed in
            self.dpadUpPressed = pressed
            
            if !pressed {
                let selectedTrackIndex = self.dawState.selectedTrack
                var selectedTrack: Track = self.dawState.tracks[selectedTrackIndex]

                selectedTrack.devices.enumerated().forEach { deviceIndex, device in
                    if (device.name == "360 WalkMix Creator") && (device.parameters.count > 0) {
                        device.parameters.enumerated().forEach { paramIndex, param in
                            if param.name.contains("Solo") {
                                let soloValue = selectedTrack.devices[deviceIndex].parameters[paramIndex].value
                                let solo: Bool = (soloValue as! Float == 1.0) ? true : false
                                
                                selectedTrack.devices[deviceIndex].parameters[paramIndex].value = !solo ? 1.0 : 0.0
                                
                                self.oscManager.send(
                                    "/live/device/set/parameter/value",
                                    [selectedTrackIndex, deviceIndex, paramIndex, !solo]
                                )
                            }
                        }
                    }
                }
            }
        }
        
        input.dpad.left.valueChangedHandler = { element, value, pressed in
            self.dpadLeftPressed = pressed
            self.oscManager.send("/live/song/undo")
        }
        
        input.dpad.right.valueChangedHandler = { element, value, pressed in
            self.dpadRightPressed = pressed
            self.oscManager.send("/live/song/redo")
        }
        
        input.leftShoulder.valueChangedHandler = { element, value, pressed in
            self.l1Pressed = pressed
            
            if !pressed {
                let selectedTrackIndex = self.dawState.selectedTrack
                var nextTrack = selectedTrackIndex - 1
                
                let numTracks = self.dawState.numTracks
                
                if nextTrack < 0 {
                    nextTrack = numTracks - 1
                }
                
                self.dawState.selectedTrack = nextTrack
                self.oscManager.send("/live/view/set/selected_track", [nextTrack])
            }
        }
        
        input.leftTrigger.valueChangedHandler = { element, value, pressed in
            self.l2Mode = pressed
        }
        
        input.rightShoulder.valueChangedHandler = { element, value, pressed in
            self.r1Pressed = pressed
            
            if !pressed {
                let selectedTrackIndex = self.dawState.selectedTrack
                var nextTrack = selectedTrackIndex + 1
                let numTracks = self.dawState.numTracks
                
                if nextTrack >= numTracks {
                    nextTrack = nextTrack - numTracks
                }
                
                self.dawState.selectedTrack = nextTrack
                self.oscManager.send("/live/view/set/selected_track", [nextTrack])
            }
        }
        
        input.rightTrigger.valueChangedHandler = { element, value, pressed in
            self.r2Mode = pressed
        }
        
        input.leftThumbstick.yAxis.valueChangedHandler = { element, value in
            if (self.r2Mode) {
                self.leftThumbstickChangeHandler(parameterName:"Gain", element:element, value:value)
            }
        }
        
        input.leftThumbstick.xAxis.valueChangedHandler = { element, value in
            if self.l2Mode {
                self.leftThumbstickChangeHandler(parameterName: "Width", element: element, value: value)
            } else if !self.r2Mode {
                self.leftThumbstickChangeHandler(parameterName: "Azimuth", element: element, value: value)
            }
        }
        
        input.rightThumbstick.yAxis.valueChangedHandler = { element, value in
            self.leftThumbstickChangeHandler(parameterName: "Elevation", element: element, value: value)
        }
        
        startPolling()
    
        
//        input.rightThumbstick.xAxis.valueChangedHandler = { element, value in
//            self.rightThumbstickChangeHandler(parameterName: "Elevation", element: element, value: value)
//        }
    }
    
    @objc func gamepadDisconnected(_ notification: Notification) {
        self.gamepad = nil
        self.vendorName = nil
        print("Gamepad diconnected")
    }
}
