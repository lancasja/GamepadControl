//
//  Track.swift
//  GamepadControl
//
//  Created by Admin on 5/9/24.
//
import SwiftUI
import SceneKit

class Track: ObservableObject, Identifiable {
    var name: String
    var id: Int
    
    var mute: Bool = false
    var solo: Bool = false
    var rec: Bool = false
    var volume: CGFloat = 0.0
    
    var size: Int = 1
    var azimuth: CGFloat = 0.0
    var elevation: CGFloat = 0.0
    var distance: CGFloat = 0.0
    
    var devices: [Device] = []
    
    var sceneNode: TrackObject = TrackObject()
//    var view: TrackView = TrackView()
    
    init(id: Int = 0, name: String = "track_name") {
        self.id = id
        self.name = name
    }
}

class Device: ObservableObject, Identifiable {
    // variable parameters
}
