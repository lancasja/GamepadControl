//
//  Live.swift
//  GamepadControl
//
//  Created by Admin on 2/29/24.
//

import SwiftUI
import OSCKit
import Combine

class Live:ObservableObject {
    @ObservedObject var osc = OSC()
    
    @Published var version: String = ""
    @Published var is_playing: Bool = false
    @Published var song_length: Float = 0.0
    @Published var current_song_time: Float = 0.0
    @Published var loop: Bool = false
    @Published var loop_length: Float = 0.0
    @Published var loop_start: Float = 0.0
    @Published var metronome: Bool = false
    @Published var punch_in: Bool = false
    @Published var punch_out: Bool = false
    @Published var record_mode: Bool = false
    @Published var signature_denominator: Int = 4
    @Published var signature_numerator: Int = 4
    @Published var tempo: Float = 120.0
    @Published var selected_track: Int = 0
    @Published var tracks: [Track] = []
    
    @Published var trackCount: Int = 0
    
    var lastReceivedMessage: AnyCancellable?
    
    func handleReceivedMessages() {
        lastReceivedMessage = osc.$lastReceivedMessage.sink { [weak self] newValue in
            if let message = newValue {
                switch(message.addressPattern) {
                // ==== APPLICATION ====
                case "/live/application/get/version":
                    let values = message.values
                    let version = {
                        var typedValues: [String] = []
                        for value in values {
                            let typedValue = String("\(value)")
                            typedValues.append(typedValue)
                        }
                        return typedValues.joined(separator: ".")
                    }()
                    print("Live \(version)")
                    self?.version = version
                
                // ==== TRACKS ====
                case "/live/song/get/num_tracks":
                    let value = Int("\(message.values[0])")!
                    print("Track count: \(value)")
                    self?.trackCount = value
                    
                    for index in 0...(value - 1) {
                        let track = Track(index: index)
                        self?.tracks.append(track)
                    }

                case "/live/song/get/track_names":
                    let values = message.values
                    for (i, value) in values.enumerated() {
                        let typedValue = String("\(value)")
                        self?.tracks[i].setName(value: typedValue)
                    }
                
                // ==== DEVICES ====
                case "/live/track/get/num_devices":
                    let trackIndex = Int("\(message.values[0])")!
                    let value = Int("\(message.values[1])")!
                    self?.tracks[trackIndex].initDevices(count: value)
                
                case "/live/track/get/devices/name":
                    let trackIndex = Int("\(message.values[0])")!
                    let values = message.values[1...]
                    if values.count > 0 {
                        for (i, value) in values.enumerated() {
                            let typedValue = String("\(value)")
                            self?.tracks[trackIndex].devices[i].setName(value: typedValue)
                        }
                    }
                case "/live/track/get/devices/type":
                    let trackIndex = Int("\(message.values[0])")!
                    let values = message.values[1...]
                    if values.count > 0 {
                        for (i, value) in values.enumerated() {
                            let typedValue = Int("\(value)")!
                            self?.tracks[trackIndex].devices[i].setType(value: typedValue)
                        }
                    }
                    
                case "/live/track/get/devices/class_name":
                    let trackIndex = Int("\(message.values[0])")!
                    let values = message.values[1...]
                    if values.count > 0 {
                        for (i, value) in values.enumerated() {
                            let typedValue = String("\(value)")
                            self?.tracks[trackIndex].devices[i].setClassName(value: typedValue)
                        }
                    }
                
                case "/live/device/get/num_parameters":
                    let trackIndex = Int("\(message.values[0])")!
                    let deviceIndex = Int("\(message.values[1])")!
                    let paramCount = Int("\(message.values[2])")!
                    self?.tracks[trackIndex].devices[deviceIndex].initParams(count: paramCount)

                case "/live/device/get/parameters/name":
                    let trackIndex = Int("\(message.values[0])")!
                    let deviceIndex = Int("\(message.values[1])")!
                    let paramNames = message.values[2...]
                    if paramNames.count > 0 {
                        for (i, name) in paramNames.enumerated() {
                            
                            let typedName = String("\(name)")
                            self?.tracks[trackIndex].devices[deviceIndex].params[i].setName(value: typedName)
                        }
                    }

                case "/live/device/get/parameters/min":
                    let trackIndex = Int("\(message.values[0])")!
                    let deviceIndex = Int("\(message.values[1])")!
                    let paramMins = message.values[2...]
                    if paramMins.count > 0 {
                        for (i, min) in paramMins.enumerated() {
                            let typedMin = Float("\(min)")!
                            self?.tracks[trackIndex].devices[deviceIndex].params[i].setMin(value: typedMin)
                        }
                    }

                case "/live/device/get/parameters/max":
                    let trackIndex = Int("\(message.values[0])")!
                    let deviceIndex = Int("\(message.values[1])")!
                    let paramMaxs = message.values[2...]
                    if paramMaxs.count > 0 {
                        for (i, max) in paramMaxs.enumerated() {
                            let typedMax = Float("\(max)")!
                            self?.tracks[trackIndex].devices[deviceIndex].params[i].setMax(value: typedMax)
                        }
                    }
                    
                case "/live/device/get/parameters/value":
                    let trackIndex = Int("\(message.values[0])")!
                    let deviceIndex = Int("\(message.values[1])")!
                    let paramVals = message.values[2...]
                    if paramVals.count > 0 {
                        for (i, val) in paramVals.enumerated() {
                            let typedVal = Float("\(val)")!
                            self?.tracks[trackIndex].devices[deviceIndex].params[i].setValue(value: typedVal)
                        }
                    }

                default:
                    print("Unhandled: \(message)")
                }
            }
        }
    }
    
    func reload() {
        osc.sendMessage(address: "/live/api/reload", query: [])
    }
    
    init() {
        osc.startServer()
        self.handleReceivedMessages()
        
        // Get version of Live
        osc.sendMessage(address: "/live/application/get/version", query: [])
        
        // Get number of tracks
        osc.sendMessage(address: "/live/song/get/num_tracks", query: [])
        
        // Get list of track names
        osc.sendMessage(address: "/live/song/get/track_names", query: [])
        
        // Enabled Song properties
//        let songProps = [
//            "is_playing",
//            "song_length",
//            "current_song_time",
//            "loop",
//            "loop_length",
//            "loop_start",
//            "metronome",
//            "punch_in",
//            "punch_out",
//            "record_mode",
//            "signature_denominator",
//            "signature_numerator",
//            "tempo"
//        ]
//        for prop in songProps {
//            osc.sendMessage(address: "/live/song/start_listen/\(prop)", query: [])
//        }
//        osc.sendMessage(address: "/live/view/set/selected_track", query: [0])
//        osc.sendMessage(address: "/live/view/start_listen/selected_track", query: [])
//        print("Listening for changes to Song and View")
    }
}
