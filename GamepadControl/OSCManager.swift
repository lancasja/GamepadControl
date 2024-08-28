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
    var name: String = ""
    var value: Any = 0
    var min: Float = 0.0
    var max: Float = 0.0
    var is_quantized: Bool = false
    var value_string: String = ""
}

struct Device: Identifiable {
    let id = UUID()
    var name: String = ""
    var class_name: String = ""
    var type: Int = 0
    var num_parameters: Int = 0
    var parameters: [Parameter] = []
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
    
    var num_devices: Int = 0
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
//        print("Sending OSC \(message)")
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
//                        print("Unhandled track data:", item)
                        break
                    }
                }
                
                tracks.append(trackData)
                
                self.send("/live/track/get/panning", [trackIndex])
                self.send("/live/track/get/volume", [trackIndex])
                self.send("/live/track/get/num_devices", [trackIndex])
                
                self.send("/live/track/start_listen/name", [trackIndex])
//                self.send("/live/track/start_listen/mute", [trackIndex])
//                self.send("/live/track/start_listen/solo", [trackIndex])
                self.send("/live/track/start_listen/arm", [trackIndex])
                self.send("/live/track/start_listen/volume", [trackIndex])
                self.send("/live/track/start_listen/panning", [trackIndex])
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
                print("Error getting volume: \(error)")
            }
        case "/live/track/get/arm":
            do {
                let values = try message.values.masked(Int.self, Bool.self)
                self.dawState.tracks[values.0].arm = values.1
            } catch {
                print("Error getting arm: \(error)")
            }
//        case "/live/track/get/mute":
//            do {
//                let values = try message.values.masked(Int.self, Bool.self)
//                self.dawState.tracks[values.0].mute = values.1
//            } catch {
//                print("Error getting mute: \(error)")
//            }
        case "/live/track/get/name":
            do {
                let values = try message.values.masked(Int.self, String.self)
                print("hello?", values)
//                if self.dawState.numTracks < values.0
            } catch {
                print("Error getting track name: \(error)")
            }
//        case "/live/track/get/solo":
//            do {
//                let values = try message.values.masked(Int.self, Bool.self)
//                self.dawState.tracks[values.0].solo = values.1
//            } catch {
//                print("Error getting solo: \(error)")
//            }
        
        // ==== DEVICES ====
        case "/live/track/get/num_devices":
            print("NUM DEVICES", message)
            do {
                let values = try message.values.masked(Int.self, Int.self)
                self.dawState.tracks[values.0].num_devices = values.1
                
                self.send("/live/track/get/devices/name", [values.0])
            } catch {
                print("Error getting num_devices:", error)
            }
        case "/live/track/get/devices/name":
            if message.values.count > 1 {
                guard let trackIndex = message.values[0] as? Int32 else { return }

                message.values.enumerated().forEach { (index, oscValue) in
                    var device = Device()
                    
                    switch oscValue {
                    case let val as String:
                        device.name = val
                    default:
                        break
                    }
                    
                    if index > 0 {
                        self.dawState.tracks[Int(trackIndex)].devices.append(device)
                    }
                }
                
                self.send("/live/track/get/devices/type", [trackIndex])
            }
        case "/live/track/get/devices/type":
            if message.values.count > 1 {
                guard let trackIndex = message.values[0] as? Int32 else { return }

                message.values.enumerated().forEach { (index, oscValue) in
                    if index > 0 {
                        switch oscValue {
                        case let val as Int32:
                            self.dawState.tracks[Int(trackIndex)].devices[index - 1].type = Int(val)
                        default:
                            break
                        }
                    }
                }
                
                self.send("/live/track/get/devices/class_name", [trackIndex])
            }
        case "/live/track/get/devices/class_name":
            if message.values.count > 1 {
                guard let trackIndex = message.values[0] as? Int32 else { return }

                message.values.enumerated().forEach { (index, oscValue) in
                    if index > 0 {
                        switch oscValue {
                        case let val as String:
                            let deviceIndex = index - 1
                            self.dawState.tracks[Int(trackIndex)].devices[deviceIndex].class_name = val
                            self.send("/live/device/get/parameters/name", [trackIndex, deviceIndex])
                        default:
                            break
                        }
                    }
                }
            }
        case "/live/device/get/parameters/name":
            guard let trackIndex = message.values[0] as? Int32 else { return }
            guard let deviceIndex = message.values[1] as? Int32 else { return }
            
            message.values.enumerated().forEach { (index, oscValue) in
                var param = Parameter()
                
                if index > 1 {
                    switch oscValue {
                    case let val as String:
                        param.name = val
                    default:
                        break
                    }
                    
                    self.dawState
                        .tracks[Int(trackIndex)]
                        .devices[Int(deviceIndex)]
                        .parameters.append(param)
                    
                    self.send("/live/device/get/parameters/value", [trackIndex, deviceIndex])
                }
            }
        case "/live/device/get/parameters/value":
            guard let trackIndex = message.values[0] as? Int32 else { return }
            guard let deviceIndex = message.values[1] as? Int32 else { return }
            
            message.values.enumerated().forEach { (index, oscValue) in
                if index > 1 {
                    switch oscValue {
                    case let val as Any:
                        self.dawState
                            .tracks[Int(trackIndex)]
                            .devices[Int(deviceIndex)]
                            .parameters[index - 2].value = val
                        
                        self.send("/live/device/start_listen/parameter/value", [trackIndex, deviceIndex, index - 2])
                    default:
                        break
                    }
                }
            }
        case "/live/device/get/parameter/value_string":
            break
        case "/live/device/get/parameter/name":
            do {
                let values = try message.values.masked(Int.self, Int.self, Int.self, String.self)
                self.dawState.tracks[values.0].devices[values.1].parameters[values.2].name = values.3
            } catch {
                print("Error getting parameter value:", error)
            }
        case "/live/device/get/parameter/value":
            do {
                let values = try message.values.masked(Int.self, Int.self, Int.self, Float.self)
                self.dawState.tracks[values.0].devices[values.1].parameters[values.2].value = values.3
            } catch {
                print("Error getting parameter value:", error)
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
