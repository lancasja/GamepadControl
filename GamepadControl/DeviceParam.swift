//
//  DeviceParam.swift
//  GamepadControl
//
//  Created by Admin on 3/8/24.
//
import SwiftUI
import OSCKit

class DeviceParam: ObservableObject {
    @Published var index: Int
    @Published var deviceIndex: Int
    @Published var trackIndex: Int
    @Published var name: String = ""
    @Published var value: Float = 0
    @Published var min: Float = 0
    @Published var max: Float = 1
    @Published var quantized: Bool = false
    
    func setName(value: String) {
        self.name = value
        print("Track \(self.trackIndex) | Device \(self.deviceIndex) | Param \(self.index) | Name: \(self.name)")
    }
    
    func setMin(value: Float) {
        self.min = value
        print("Track \(self.trackIndex) | Device \(self.deviceIndex) | Param \(self.index) | Min: \(self.min)")
    }
    
    func setMax(value: Float) {
        self.max = value
        print("Track \(self.trackIndex) | Device \(self.deviceIndex) | Param \(self.index) | Max: \(self.max)")
    }
    
    func setValue(value: Float) {
        self.value = value
        print("Track \(self.trackIndex) | Device \(self.deviceIndex) | Param \(self.index) | Value: \(self.value)")
    }
    
    init(index: Int, deviceIndex: Int, trackIndex: Int) {
        self.index = index
        self.deviceIndex = deviceIndex
        self.trackIndex = trackIndex
        print("Created param \(self.index) in device \(self.deviceIndex) on Track \(self.trackIndex)")
    }
}
