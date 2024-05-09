//
//  OSCReceiver.swift
//  GamepadControl
//
//  Created by Admin on 4/1/24.
//

import SwiftUI
import OSCKit

class OSCReceiver: ObservableObject {
    private let addressSpace = OSCAddressSpace()

    private let test: OSCAddressSpace.MethodID
    private let num_tracks: OSCAddressSpace.MethodID
    private let selected_track: OSCAddressSpace.MethodID
    private let error: OSCAddressSpace.MethodID
    private let mute: OSCAddressSpace.MethodID
    
    @ObservedObject var dawState: DawState
    
    public init(_ dawStateInit: DawState) {
        test = addressSpace.register(localAddress: "/live/test")
        num_tracks = addressSpace.register(localAddress: "/live/song/get/num_tracks")
        selected_track = addressSpace.register(localAddress: "/live/view/get/selected_track")
        error = addressSpace.register(localAddress: "/live/error")
        mute = addressSpace.register(localAddress: "/live/track/get/mute")
        dawState = dawStateInit
    }
    
    public func handle(message: OSCMessage, timeTag: OSCTimeTag) throws {
        let ids = addressSpace.methods(matching: message.addressPattern)
        
        guard !ids.isEmpty else {
            print("No handler for address: \(message.addressPattern)")
            return
        }
        
        try ids.forEach { id in
            switch id {
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
                let muteState = try message.values.masked(Bool.self)
//                self.handleMute(value: muteState)
                print("mute?????")
            default:
                return
            }
        }
    }
    
    private func handleTest(value: String) {
        print("handleTest: \(value)")
    }
    
    private func handleNumTracks(count: Int) {
        print("num_tracks: \(count)")
    }
    
    private func handleSelectedTrack(index: Int) {
        self.dawState.setSelectedTrack(index)
        print("selected_track: \(index)")
    }
    
    private func handleMute(value: Bool) {
        print("VALUE: \(value)")
    }
}

