//
//  Device.swift
//  GamepadControl
//
//  Created by Admin on 3/8/24.
//
import SwiftUI

class Device: ObservableObject {
    @ObservedObject var osc = OSC()
    
    enum DeviceTypes: Int {
        case audio_effect = 1, instrument = 2, midi_effect = 4
    }
    
    @Published var index: Int
    @Published var trackIndex: Int
    @Published var name: String = ""
    @Published var deviceType: DeviceTypes = .audio_effect
    @Published var className: String = ""
    @Published var params: [DeviceParam] = []
    
    func setName(value: String) {
        self.name = value
        print("Track \(self.trackIndex) | Device \(self.index) | Name: \(self.name)")
    }
    
    func setType(value: Int) {
        switch(value) {
        case 1:
            self.deviceType = DeviceTypes.audio_effect
        case 2:
            self.deviceType = DeviceTypes.instrument
        case 4:
            self.deviceType = DeviceTypes.midi_effect
        default:
            print("[Unrecognized device type]")
            return
        }
        print("Track \(self.trackIndex) | Device \(self.index) | Type: \(self.deviceType)")
    }
    
    func setClassName(value: String) {
        self.className = value
        print("Track \(self.trackIndex) | Device \(self.index) | Class: \(self.className)")
    }
    
    func initParams(count: Int) {
        print("Track \(self.trackIndex) | Device \(self.index) | Param count: \(count)")
        if count > 0 {
            for i in 0...(count - 1) {
                let param = DeviceParam(index: i, deviceIndex: self.index, trackIndex: self.trackIndex)
                self.params.append(param)
            }
        }
    }
    
    init(trackIndex: Int, deviceIndex: Int) {
        print("Creating device on track \(trackIndex) at index \(deviceIndex)")
        self.index = deviceIndex
        self.trackIndex = trackIndex
        
        // Get number of parameters
        osc.sendMessage(address: "/live/device/get/num_parameters", query: [self.trackIndex, self.index])
        
        // Get parameter names
        osc.sendMessage(address: "/live/device/get/parameters/name", query: [self.trackIndex, self.index])
        
        // Get parameter mins
        osc.sendMessage(address: "/live/device/get/parameters/min", query: [self.trackIndex, self.index])
        
        // Get parameter maxs
        osc.sendMessage(address: "/live/device/get/parameters/max", query: [self.trackIndex, self.index])
        
        // Get parameter values
        osc.sendMessage(address: "/live/device/get/parameters/value", query: [self.trackIndex, self.index])
    }
}
