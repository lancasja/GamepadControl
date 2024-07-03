//
//  OSCManager.swift
//  GamepadControl
//
//  Created by Jonathan Lancaster on 7/2/24.
//

import SwiftUI
import OSCKit

enum TrackProps: String, CaseIterable {
    case index,
         name,
         mute,
         solo,
         arm,
         can_be_armed,
         has_audio_input,
         has_audio_output,
         has_midi_input,
         has_midi_output,
         is_grouped,
         is_foldable,
         color,
         color_index
}

struct Parameter: Identifiable {
    let id = UUID()
    var name: String?
    var value: Any?
    var min: Float?
    var max: Float?
    var is_quantized: Bool?
    var value_string: String?
}

struct Device: Identifiable {
    let id = UUID()
    var name: String?
    var class_name: String?
    var type: Int?
    var num_parameters: Int?
    var parameters: [Parameter]?
}

struct Track: Identifiable {
    let id = UUID()
    
    var index = 0
    var name: String = ""
    var mute: Bool = false
    var solo: Bool = false
    var arm: Bool = false
    var can_be_armed: Bool = false
    var has_audio_input: Bool = false
    var has_audio_output: Bool = false
    var has_midi_input: Bool = false
    var has_midi_output: Bool = false
    var is_grouped: Bool = false
    var is_foldable: Bool = false
    var color: Int = 0
    var color_index: Int = 0
    
    var panning: Float = 0.0
    var volume: Float = 0.0
    
    var num_devices: Int?
    var devices: [Device] = []
}

class DAWState: ObservableObject {
    static var shared = DAWState()
    
    @Published var numTracks = 0
    @Published var tracks: [Track] = []
    @Published var selectedTrack: Int = 0
    @Published var is_playing: Bool = false
    @Published var can_undo: Bool = false
    @Published var can_redo: Bool = false
    @Published var current_song_time: Float = 0
    @Published var metronome: Bool = false
    @Published var record_mode: Bool = false
    @Published var song_length: Int = 0
    @Published var current_beat: Int = 0
}

class OSCManager: ObservableObject {
    static let shared = OSCManager()
    static var localPort: UInt16 = 11000
    static var serverPort: UInt16 = 11001
    static var host = "localhost"
    
    @Published var client = OSCClient()
    @Published var server = OSCServer(port: serverPort)
    
    @ObservedObject var dawState = DAWState.shared
    
    init() {
        server.setHandler { message, timeTag in
            self.handleReceivedMessage(message)
        }
        
        startServer()
        startClient()
        
        // 1. Ask for number of tracks
        // - Kicks everything off, all other initializer calls are made
        // within the switch stastement chain in handleReceivedMessages
        self.send("/live/song/get/num_tracks")
        self.send("/live/song/get/current_song_time")
        
        self.send("/live/song/start_listen/is_playing")
        self.send("/live/song/start_listen/beat")
        self.send("/live/song/start_listen/record_mode")
        self.send("/live/song/start_listen/can_undo")
        self.send("/live/song/start_listen/can_redo")
    }
    
    func startServer() {
        do {
            print("Starting OSC server...")
            try server.start()
        } catch {
            print("Error starting OSC server:", error)
        }
    }
    
    func startClient() {
        client.isPortReuseEnabled = true
        client.isIPv4BroadcastEnabled = true
        
        do {
            print("Starting OSC client...")
            try client.start()
        } catch {
            print("Error starting OSC client:", error)
        }
    }
    
    func send(
        _ address: OSCAddressPattern,
        _ values: [AnyOSCValue] = [],
        to: String = host,
        port: UInt16 = localPort
    ) {
        let message = OSCMessage(address, values: values)
        try? client.send(message, to: to, port: port)
        print("Sending OSC \(message)")
    }
    
    func handleReceivedMessage(_ message: OSCMessage) {
        switch message.addressPattern {
        // ==== SONG ====
        case "/live/song/get/is_playing":
            do {
                let value = try message.values.masked(Bool.self)
                self.dawState.is_playing = value
            } catch {
                print("Error getting is_playing:", error)
            }
        case "/live/song/get/current_song_time":
            print(message.values[0].oscValueToken)
            do {
                let value = try message.values.masked(Float.self)
                self.dawState.current_song_time = value
            } catch {
                print("Error getting current_song_time:", error)
            }
        case "/live/song/get/beat":
            do {
                let value = try message.values.masked(Int.self)
                self.dawState.current_beat = value
            } catch {
                print("Error getting is_playing:", error)
            }
        case "/live/song/get/record_mode":
            do {
                let value = try message.values.masked(Bool.self)
                self.dawState.record_mode = value
            } catch {
                print("Error getting record_mode", error)
            }
        case "/live/song/get/can_undo":
            do {
                let value = try message.values.masked(Bool.self)
                self.dawState.can_undo = value
            } catch {
                print("Error getting can_undo:", error)
            }
        case "/live/song/get/can_redo":
            do {
                let value = try message.values.masked(Bool.self)
                self.dawState.can_redo = value
            } catch {
                print("Error getting can_redo:", error)
            }
            
        // ==== TRACKS ====
        // 2. Receive number of tracks
        case "/live/song/get/num_tracks":
            do {
                let numTracks = try message.values.masked(Int.self)
                self.dawState.numTracks = numTracks
                
                // 3. Get bulk track data within this block so it's executed
                // once we know how many tracks there are
                // - I think volume and panning are inaccessible in this way
                // https://github.com/ideoforms/AbletonOSC/blob/316c1d8460c73748b8647097ea0f48e2a6fd9959/abletonosc/song.py#L103
                let trackPropsArray = TrackProps.allCases.filter { $0 != .index }.map { "track.\($0.rawValue)" }
                self.send("/live/song/get/track_data", [0, numTracks] + trackPropsArray)
            } catch {
                print("Error getting number of tracks: \(error)")
            }
        case "/live/song/get/track_data":
            // 4. Parse bulk track data
            let valuesPerTrack = splitValuesIntoTracks(message.values)
            var tracks: [Track] = []
            
            valuesPerTrack.enumerated().forEach { (trackIndex, trackValues) in
                var trackData = Track()
                
                trackData.index = trackIndex
                
                trackValues.enumerated().forEach { (index, item) in
                    switch index {
                    case 0: trackData.name = item as! String
                    case 1: trackData.mute = item as! Bool
                    case 2: trackData.solo = item as! Bool
                    case 3: trackData.arm = item as! Bool
                    case 4: trackData.can_be_armed = item as! Bool
                    case 5: trackData.has_audio_input = item as! Bool
                    case 6: trackData.has_audio_output = item as! Bool
                    case 7: trackData.has_midi_input = item as! Bool
                    case 8: trackData.has_midi_output = item as! Bool
                    case 9: trackData.is_grouped = item as! Bool
                    case 10: trackData.is_foldable = item as! Bool
//                    case 11: trackData.color = item as! Int
//                    case 12: trackData.color_index = item as! Int
                    default:
                        print("Unhandled track data:", item)
                    }
                }
                
                tracks.append(trackData)
                
                self.send("/live/track/get/panning", [trackIndex])
                self.send("/live/track/get/volume", [trackIndex])
                self.send("/live/track/get/num_devices", [trackIndex])
//                self.send("/live/track/get/devices/name", [trackIndex])
//                self.send("/live/track/get/devices/type", [trackIndex])
//                self.send("/live/track/get/devices/class_name", [trackIndex])
            }
            
            // 5. Create local tracks
            self.dawState.tracks = tracks
            
            // 6. Get current track
            self.send("/live/view/get/selected_track")
        case "/live/view/get/selected_track":
            do {
                let selectedTrack = try message.values.masked(Int.self)
                self.dawState.selectedTrack = selectedTrack
            } catch {
                print("Error getting selected track:", error)
            }
        case "/live/track/get/panning":
            do {
                let values = try message.values.masked(Int.self, Float.self)
                self.dawState.tracks[values.0].panning = values.1
            } catch {
                print("Error getting panning: \(error)")
            }
        case "/live/track/get/volume":
            do {
                let values = try message.values.masked(Int.self, Float.self)
                self.dawState.tracks[values.0].volume = values.1
            } catch {
                print("Error getting panning: \(error)")
            }
        case "/live/track/get/arm":
            print("arm", message)
        case "/live/track/get/mute":
            print("mute", message)
        case "/live/track/get/solo":
            print("mute", message)
        
        // ==== DEVICES ====
        case "/live/track/get/num_devices":
            do {
                let values = try message.values.masked(Int.self, Int.self)
                self.dawState.tracks[values.0].num_devices = values.1
                
                if values.1 > 0 {
                    for _ in 0...values.1 {
                        let device = Device()
                        self.dawState.tracks[values.0].devices.append(device)
                    }
                }
                
                self.send("/live/track/get/devices/name", [values.0])
//                self.send("/live/track/get/devices/type", [values.0])
//                self.send("/live/track/get/devices/class_name", [values.0])
            } catch {
                print("Error getting num_devices:", error)
            }
        case "/live/track/get/devices/name":
            if message.values.count > 1 {
                print(">>> GET DEVICES:", message)
                
                message.values.enumerated().forEach { (index, oscValue) in
                    var trackIndex: Int = 0
                    var deviceName: String = ""
                    
                    switch oscValue {
                    case let val as Int32:
                        print(val)
                        trackIndex = Int("\(val)") ?? 0
                        print(">>>> INDX <<<<", trackIndex)
                    case let val as String:
                        print(val)
                        deviceName = val
                    default:
                        break
                    }
                    
                    if index > 0 {
                        print(trackIndex)
//                        self.dawState.tracks[trackIndex].devices[index].name = deviceName
                    }
                }
                
//                values.enumerated().forEach { (index, value) in
//                    guard let name = value as? String else { return }
//                    self.dawState.tracks[trackIndex].devices[index].name = name
//                }
            }
        case "/live/track/get/devices/type":
            if message.values.count > 1 {
                var values = message.values
                let trackIndex = values.removeFirst()
                
                values.enumerated().forEach { (index, value) in
                    self.dawState.tracks[trackIndex as! Int].devices[index].type = value as? Int
                }
            }
        case "/live/track/get/devices/class_name":
            if message.values.count > 1 {
                var values = message.values
                let trackIndex = values.removeFirst()
                
                values.enumerated().forEach { (index, value) in
                    self.dawState.tracks[trackIndex as! Int].devices[index].class_name = value as? String
                }
            }
        case "/live/device/get/name":
            do {
                let values = try message.values.masked(Int.self, Int.self, String.self)
                self.dawState.tracks[values.0].devices[values.1].name = values.2
            } catch {
                print("Error getting device name:", error)
            }
        case "/live/device/get/class_name":
            do {
                let values = try message.values.masked(Int.self, Int.self, String.self)
                self.dawState.tracks[values.0].devices[values.1].class_name = values.2
            } catch {
                print("Error getting device class_name:", error)
            }
        default:
            print("unhandled:", message)
        }
    }
    
    private func splitValuesIntoTracks(_ values: OSCValues) -> [OSCValues] {
        var tracks: [OSCValues] = []
        var currentTrack: OSCValues = []
        
        for value in values {
            if let stringValue = value as? String, stringValue.contains("-") {
                if !currentTrack.isEmpty {
                    tracks.append(currentTrack)
                }
                currentTrack = [stringValue as any OSCValue]
            } else {
                currentTrack.append(value)
            }
        }
        
        if !currentTrack.isEmpty {
            tracks.append(currentTrack as OSCValues)
        }
        
        return tracks
        
    }
}
