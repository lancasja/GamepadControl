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
    
    @Published var version: [Int] = [0, 0] // [major, minor]
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
    
    var lastReceivedMessage: AnyCancellable?
    
    func handleReceivedMessages() {
        lastReceivedMessage = osc.$lastReceivedMessage.sink { [weak self] newValue in
            if let message = newValue {
                switch(message.addressPattern) {
                case "/live/application/get/version":
                    self?.version = [Int("\(message.values[0])")!, Int("\(message.values[1])")!]
                case "/live/error":
                    if (message.values[0] == "Error handling OSC message: Index out of range") {}
                    print(message)
                case "/live/song/get/is_playing":
                    self?.is_playing = Bool("\(message.values[0])")!
                case "/live/song/get/song_length":
                    self?.song_length = Float("\(message.values[0])")!
                case "/live/song/get/current_song_time":
                    self?.current_song_time = Float("\(message.values[0])")!
                case "/live/song/get/loop":
                    self?.loop = Bool("\(message.values[0])")!
                case "/live/song/get/loop_length":
                    self?.loop_length = Float("\(message.values[0])")!
                case "/live/song/get/loop_start":
                    self?.loop_start = Float("\(message.values[0])")!
                case "/live/song/get/metronome":
                    self?.metronome = Bool("\(message.values[0])")!
                case "/live/song/get/punch_in":
                    self?.punch_in = Bool("\(message.values[0])")!
                case "/live/song/get/punch_out":
                    self?.punch_out = Bool("\(message.values[0])")!
                case "/live/song/get/record_mode":
                    self?.record_mode = Bool("\(message.values[0])")!
                case "/live/song/get/signature_denominator":
                    self?.signature_denominator = Int("\(message.values[0])")!
                case "/live/song/get/signature_numerator":
                    self?.signature_numerator = Int("\(message.values[0])")!
                case "/live/song/get/tempo":
                    self?.tempo = Float("\(message.values[0])")!
                case "/live/view/get/selected_track":
                    self?.selected_track = Int("\(message.values[0])")!
                    let has_track = self?.tracks.contains(where: {
                        $0.id == Int("\(message.values[0])")!
                    })
                    if !has_track! {
                        self?.tracks.append(Track(id: Int("\(message.values[0])")!))
                    }
                default:
                    print("Unhandled: \(message)")
                }
            }
        }
    }
    
    func printTracks() {
        print(tracks)
    }
    
    init() {
        osc.startServer()
        self.handleReceivedMessages()
        
        print("Getting Live version...")
        osc.sendMessage(address: "/live/application/get/version", query: [])
        
        // Enabled Song properties
        let songProps = [
            "is_playing",
            "song_length",
            "current_song_time",
            "loop",
            "loop_length",
            "loop_start",
            "metronome",
            "punch_in",
            "punch_out",
            "record_mode",
            "signature_denominator",
            "signature_numerator",
            "tempo"
        ]
        for prop in songProps {
            osc.sendMessage(address: "/live/song/start_listen/\(prop)", query: [])
        }
        osc.sendMessage(address: "/live/view/get/selected_track", query: [])
        print("Started listening for changes to song.")
    }
}

class Track: ObservableObject {
    @ObservedObject var osc = OSC()
    
    enum SpatialTrackType: String {
        case master, panner, effect, send, rtrn, util
    }
    
    @Published var arm: Bool = false
    @Published var devices: [Device]?
    @Published var id: Int = -1
    @Published var monitor: Bool = false
    @Published var mute: Bool = false
    @Published var name: String = ""
    @Published var solo: Bool = false
    @Published var spatialType: SpatialTrackType?
    @Published var volume: Float = 0.85 // 0...1
    
    init(id: Int) {
        self.id = id
        let trackProps = [
            "arm",
            "current_monitoring_state",
            "mute",
            "name",
            "solo",
            "volume"
        ]
        for prop in trackProps {
            osc.sendMessage(address: "/live/track/start_listen/\(prop)", query: [self.id])
        }
    }
}

struct Device {
    struct Device {
        let name: AnyOSCValue = "{device}"
        let className: AnyOSCValue = "{class}"
        let type: AnyOSCValue = 1
        let paramsCount: AnyOSCValue = 0
        let paramsNames: OSCValues = []
        let paramsValues: OSCValues = []
        let paramsMins: OSCValues = []
        let paramsMaxes: OSCValues = []
        let paramsQuantized: OSCValues = []
        
        init() {}
    }
}
