//
//  OSCReceiver.swift
//  GamepadControl
//
//  Created by Admin on 4/1/24.
//

import SwiftUI
import OSCKit

class OSCReceiver: ObservableObject {
    @AppStorage("live_version") var liveVersion: String?
    
    private let addressSpace = OSCAddressSpace()

    private let test: OSCAddressSpace.MethodID
    private let num_tracks: OSCAddressSpace.MethodID
    private let selected_track: OSCAddressSpace.MethodID
    private let error: OSCAddressSpace.MethodID
    private let mute: OSCAddressSpace.MethodID
    private let bulkTrackInfo: OSCAddressSpace.MethodID
    private let startup: OSCAddressSpace.MethodID
    private let average_process_usage: OSCAddressSpace.MethodID
    private let get_version: OSCAddressSpace.MethodID
    
    @ObservedObject var dawState: DawState
    
    public init(_ dawStateInit: DawState) {
        dawState = dawStateInit
        get_version =
            addressSpace.register(localAddress: "/live/application/get/version")
        test =
            addressSpace.register(localAddress: "/live/test")
        num_tracks = 
            addressSpace.register(localAddress: "/live/song/get/num_tracks")
        selected_track = 
            addressSpace.register(localAddress: "/live/view/get/selected_track")
        error = 
            addressSpace.register(localAddress: "/live/error")
        mute = 
            addressSpace.register(localAddress: "/live/song/get/mute")
        bulkTrackInfo = 
            addressSpace.register(localAddress: "/live/song/get/track_data")
        startup = 
            addressSpace.register(localAddress: "/live/startup")
        average_process_usage = 
            addressSpace.register(localAddress: "/live/application/get/average_process_usage")
    }
    
    public func handle(message: OSCMessage, timeTag: OSCTimeTag) throws {
        let ids = addressSpace.methods(matching: message.addressPattern)
        
        guard !ids.isEmpty else {
            print("No handler for address: \(message.addressPattern)")
            return
        }
        
        try ids.forEach { id in
            switch id {
            case average_process_usage:
                print(message)
            case get_version:
                let value = try message.values.masked(Int.self, Int.self)
                let version = "\(value.0).\(value.1)"
                liveVersion = version
            case test:
                let value = try message.values.masked(String.self)
                self.handleTest(value: value)
            case num_tracks:
                let count = try message.values.masked(Int.self)
                self.handleNumTracks(count: count)
            case selected_track:
                let index = try message.values.masked(Int.self)
                self.handleSelectedTrack(index: index)
            case mute:
                print("MUTE!!!!????")
                let muteState = try message.values.masked(Bool.self)
                self.handleMute(value: muteState)
            case bulkTrackInfo:
                print("GETTING BULK TRACK INFO: \(message)")
                self.handleBulkTrackInfo(value: message)
            default:
                return
            }
        }
    }
    
    private func handleTest(value: String) {
        print("handleTest: \(value)")
    }
    
    private func handleNumTracks(count: Int) {
        // figure out if initialized
        if count != self.dawState.numTracks {
            self.dawState.setNumTracks(count)
            NotificationCenter.default.post(name: Notification.Name("BulkGetTrackInfo"), object: nil)
        }
        self.dawState.setNumTracks(count)
        print("num_tracks: \(count)")
    }
    
    private func handleSelectedTrack(index: Int) {
        self.dawState.setSelectedTrack(index)
        print("selected_track: \(index)")
    }
    
    private func handleMute(value: Bool) {
        print("VALUE: \(value)")
        self.dawState.tracks[self.dawState.selectedTrack].muted = value
//        print("VALUE: \(value)")
    }
    
    private func handleBulkTrackInfo(value: OSCMessage) {
        // Ensure the values are in the expected format
        guard let trackInfoArray = value.values as? [AnyObject] else {
            print("Unexpected value format: \(value.values)")
            return
        }
        
        var tracks: [TrackState] = []
        
        // Iterate over the array, assuming each track has four consecutive values
        for i in stride(from: 0, to: trackInfoArray.count, by: 4) {
            guard i + 3 < trackInfoArray.count,
                  let name = trackInfoArray[i] as? String,
                  let muted = trackInfoArray[i + 1] as? Bool,
                  let armed = trackInfoArray[i + 2] as? Bool,
                  let solo = trackInfoArray[i + 3] as? Bool else {
                print("Invalid track info at index \(i)")
                continue
            }
            
            let trackState = TrackState(name: name, muted: muted, solo: solo, arm: armed)
            tracks.append(trackState)
        }
        
        // Assign the parsed track states to dawState.tracks
        self.dawState.tracks = tracks
        
        print("Updated dawState with bulk response: \(tracks)")
    }
}

