//
//  TrackObject.swift
//  GamepadControl
//
//  Created by Admin on 4/27/24.
//

import SceneKit
import SwiftUI

class TrackObject: SCNNode, ObservableObject {
    @ObservedObject var trackViewModel = TrackViewModel()
    
    @Published var index: Int = 0
    @Published var size: CGFloat = 0.5
    @Published var color: NSColor = NSColor.orange
    @Published var location: SCNVector3 = SCNVector3(0, 5, -5)
    
    func setColor(nsColor: NSColor) {
        color = nsColor
        self.geometry?.firstMaterial?.diffuse.contents = color
    }
    
    func setLocation(vector3: SCNVector3) {
        location = vector3
        self.position = location
    }
    
    required init(coder: NSCoder = NSCoder()) {
        super.init()
        self.index = trackViewModel.index
        self.geometry = TrackGeometry()
        setColor(nsColor: color)
        setLocation(vector3: location)
    }
}

extension TrackObject {
    class TrackGeometry: SCNSphere, ObservableObject{
        @Published var size = 0.5
        
        func setSize(value: CGFloat) {
            size = value
            self.radius = size
        }
        
        required init(coder: NSCoder = NSCoder()) {
            super.init()
            self.radius = size
        }
    }
}
