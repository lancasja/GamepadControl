//
//  Track.swift
//  GamepadControl
//
//  Created by Admin on 3/8/24.
//
import SwiftUI

class Track: ObservableObject {
    @ObservedObject var osc = OSC()
    
    enum SpatialTrackType: String {
        case master, panner, effect, send, rtrn, util
    }
    
    enum MonitoringState: Int {
        case input = 0, auto = 1, off = 2
    }
    
    @Published var arm: Bool = false
    @Published var devices: [Device] = []
    @Published var index: Int
    @Published var monitoring: MonitoringState = .off
    @Published var mute: Bool = false
    @Published var name: String = ""
    @Published var solo: Bool = false
    @Published var spatialType: SpatialTrackType?
    @Published var volume: Float = 0.85 // 0...1
    
    func setName(value: String) {
        self.name = value
        print("Track \(self.index) name: \(self.name)")
    }
    
    func initDevices(count: Int) {
        print("Track \(self.index) device count: \(count)")
        if count > 0 {
            for i in 0...(count - 1) {
                let device = Device(trackIndex: self.index, deviceIndex: i)
                self.devices.append(device)
            }
        }
    }
    
    func setArm(value: Bool) {
        self.arm = value
        print("Track \(self.index) arm value: \(self.arm)")
    }
    
    func setMonitoringState(value: Int) {
        switch(value) {
        case 0:
            self.monitoring = MonitoringState.input
        case 1:
            self.monitoring = MonitoringState.auto
        case 2:
            self.monitoring = MonitoringState.off
        default:
            self.monitoring = MonitoringState.off
        }
        print("Track \(self.index) monitoring value: \(self.monitoring)")
    }
    
    func setMute(value: Bool) {
        self.mute = value
        print("Track \(self.index) mute value: \(self.mute)")
    }
    
    func setSolo(value: Bool) {
        self.solo = value
        print("Track \(self.index) solo value: \(self.solo)")
    }
    
    func setVolume(value: Float) {
        self.volume = value
        print("Track \(self.index) volume value: \(self.volume)")
    }
    
    init(index: Int) {
        print("Creating track at index: \(index)")
        self.index = index
        
        // Get number of devices
        osc.sendMessage(address: "/live/track/get/num_devices", query: [self.index])
        
        // Get device names
        osc.sendMessage(address: "/live/track/get/devices/name", query: [self.index])
        
        // Get device types
        osc.sendMessage(address: "/live/track/get/devices/type", query: [self.index])
        
        // Get device class names
        osc.sendMessage(address: "/live/track/get/devices/class_name", query: [self.index])

//        let trackProps = [
//            "arm",
//            "current_monitoring_state",
//            "mute",
//            "name",
//            "solo",
//            "volume"
//        ]
//        for prop in trackProps {
//            osc.sendMessage(address: "/live/track/start_listen/\(prop)", query: [self.index])
//        }
//        print("Listening for changes to track \(self.index)...")
//
//        // Devices
//
//        print("Devices at track index: \(self.index):")
    }
}
