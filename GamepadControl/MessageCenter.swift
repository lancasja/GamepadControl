//
//  MessageCenter.swift
//  GamepadControl
//
//  Created by Admin on 5/8/24.
//

import SwiftUI
import Combine
import OSCKit

enum AudioControlAction: String {
    case trackMute, trackSolo, trackArm
    case trackVolumeInc, trackVolumeDec
    case trackPrevious, trackNext
    case pannerAzimuthLeft, pannerAzimuthRight
    case pannerElevationInc, pannerElevationDec
    case pannerDistanceInc, pannerDistanceDec
    case pannerSpreadInc, pannerSpreadDec
    case transportPlay, transportStop
    case transportRecord, transportUndo, transportRedo
    
    func notify() {
        print("sending notification \(self.rawValue)")
        NotificationCenter.default.post(
            name: Notification.Name(self.rawValue),
            object: nil
        )
    }
}

struct TrackState {
    var name: String = ""
    var muted: Bool = false
    var solo: Bool = false
    var arm: Bool = false
}

class DawState: ObservableObject {
    var selectedTrack = 0
    var numTracks = 1
    var tracks: [TrackState] = []
    
    func setSelectedTrack(_ index: Int) {
        selectedTrack = index
    }
    
    func setNumTracks(_ num: Int) {
        numTracks = num
        if tracks.count < numTracks {
            for _ in 0..<numTracks {
                tracks.append(TrackState())
            }
        }
    }
    
    func initialize() {
        let socket = OSCSocket(
            remoteHost: "localhost",
            remotePort: 9000
        ) { message, _ in
            print("Received \(message)")
            if let oscMessage = message as? OSCMessage {
                self.handleOSCMessage(oscMessage)
            }
        }
        
        do {
            try socket.start()

            // Send OSC message to get number of tracks
            try socket.send(OSCMessage("/live/song/get/num_tracks"))

            // Send OSC message to get selected track
            try socket.send(OSCMessage("/live/song/get/selected_track"))

            // Send OSC message to get track names
            for i in 0..<numTracks {
                try socket.send(OSCMessage("/live/track/get/name", values: [i]))
            }

        } catch {
            print("Error while setting up osc socket: \(error)")
        }
    }

    private func handleOSCMessage(_ message: OSCMessage) {
        let address = message.addressPattern.stringValue
        if address == "/live/song/num_tracks" {
            if let numTracks = message.values.first as? Int {
                DispatchQueue.main.async {
                    self.setNumTracks(numTracks)
                }
            }
        } else if address == "/live/song/selected_track" {
            if let selectedTrack = message.values.first as? Int {
                DispatchQueue.main.async {
                    self.setSelectedTrack(selectedTrack)
                }
            }
        } else if address == "/live/track/name" {
            if let trackIndex = message.values.first as? Int,
               let trackName = message.values.dropFirst().first as? String {
                DispatchQueue.main.async {
                    if trackIndex < self.tracks.count {
                        self.tracks[trackIndex].name = trackName
                    }
                }
            }
        }
    }
}

class MessageCenter: ObservableObject {
    
    @State var dawState: DawState
    @ObservedObject var osc: OSC
    
    init() {
        let dawStateInit = DawState()
        osc = OSC(dawStateInit: dawStateInit)
        dawState = dawStateInit
        
//        let dummyTrack = TrackState()
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(setSelectedTrack),
//            name: Notification.Name("SetSelectedTrack"),
//            object: nil
//        )
        

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackMute),
            name: Notification.Name(AudioControlAction.trackMute.rawValue),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackArm),
            name: Notification.Name(AudioControlAction.trackArm.rawValue),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackSolo),
            name: Notification.Name(AudioControlAction.trackSolo.rawValue),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackPrevious),
            name: Notification.Name(AudioControlAction.trackPrevious.rawValue),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackNext),
            name: Notification.Name(AudioControlAction.trackNext.rawValue),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bulkGetTrackInfo),
            name: Notification.Name("BulkGetTrackInfo"),
            object: nil
        )

    }
    
    @objc func oscStart() {
        self.osc.startServer()
        self.osc.initDawState()
        self.osc.send("/live/song/get/num_tracks")
//        self.osc.send("/live/view/start_listen/selected_track")
//        self.osc.send("/live/song/start_listen/mute")
    }
    
    @objc func oscStop() {
        self.osc.send("/live/view/stop_listen/selected_track")
        self.osc.send("/live/song/start_listen/mute")
        self.osc.stopServer()
    }
    
    @objc func handleTrackMute() {
        print("selectedTrack = \(self.dawState.selectedTrack), numTracks = \(self.dawState.numTracks)")
        if self.dawState.selectedTrack >= self.dawState.tracks.count {
            print("selected track out of range")
            print("debug: self.dawState.tracks = \(self.dawState.tracks)")
            return
        }
        if self.dawState.selectedTrack >= self.dawState.numTracks {
            return
        }
        let curTrack = self.dawState.tracks[self.dawState.selectedTrack]
        let willMute = !curTrack.muted
        self.dawState.tracks[self.dawState.selectedTrack].muted = willMute
        self.osc.send("/live/track/set/mute", [self.dawState.selectedTrack, willMute])
    }
    
    @objc func handleTrackArm() {
        self.osc.send("/live/track/set/arm", [self.dawState.selectedTrack, true])
    }
    
    @objc func handleTrackPrevious() {
        var newTrackIdx = self.dawState.selectedTrack - 1
        if newTrackIdx < 0 {
            newTrackIdx = self.dawState.numTracks - 1
        }
        self.osc.send("/live/view/set/selected_track", [newTrackIdx])
    }
    
    @objc func handleTrackNext() {
        var newTrack = (self.dawState.selectedTrack + 1)
        if newTrack >= self.dawState.numTracks {
            newTrack = newTrack - self.dawState.numTracks
        }
        self.dawState.selectedTrack = newTrack
        self.osc.send("/live/view/set/selected_track", [self.dawState.selectedTrack])
//        self.osc.send("/live/view/set/selected_track", [2])
    }
    
    @objc func bulkGetTrackInfo() {
        self.osc.send("/live/song/get/track_data", [0, self.dawState.numTracks-1, "track.name", "track.mute", "track.arm", "track.solo"])
    }
    
    @objc func handleTrackSolo() {
        self.osc.send("/live/track/set/solo", [self.dawState.selectedTrack, true])
    }
    
    
    func setSelectedTrack(trackIdx: Int) {
        print("setting selected track \(trackIdx)")
        self.dawState.selectedTrack = trackIdx
    }

    
}

