//
//  RoomView.swift
//  GamepadControl
//
//  Created by Admin on 4/18/24.
//
/**
 We should start using ARKit & RealityKit if possible.
 SceneKit is better suited for rendering a 3D thing on a 2D surface though,
 which is what we're doing right now.
 */

import SceneKit
import SceneKit.ModelIO
import SwiftUI

class RoomScene: SCNScene {
    var cameraNode = SCNNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
        background.contents = NSColor.black
        
        setupCamera()
        addFloor()
        addRoom()
        addFront()
        addTrack()
        addLights()
    }
    
    func setupCamera() {
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 7, 17)
        /**
            Euler Angles:
                1. Pitch: rotation around the x-axis.
                2. Yaw: rotation around the y-axis.
                3. Roll: rotation around the z-axis.
         
            SCNVector3(pitch, yaw, roll)
         
            Positive angles are counter clockwise.
            Negative angles are clockwise.
         
            I think `1` is equivalent to 1 meter, so 0.01 is 1 centimeter.
         */
        cameraNode.eulerAngles = SCNVector3(-15.degreesToRadians(), 0, 0)
        
        rootNode.addChildNode(cameraNode)
    }
    
    func addFloor() {
        let floor = SCNNode(geometry: SCNFloor())
        floor.geometry?.firstMaterial?.diffuse.contents = NSColor.gray
        
        rootNode.addChildNode(floor)
    }
    
    func addRoom() {
        let room = SCNNode(geometry: SCNSphere(radius: 10))
        room.geometry?.firstMaterial?.diffuse.contents = NSColor.magenta
        room.geometry?.firstMaterial?.fillMode = .lines
        room.geometry?.firstMaterial?.isDoubleSided = true
        room.position = SCNVector3(0, 0, 0)
        
        rootNode.addChildNode(room)
    }
    
    func addFront() {
        let front = SCNNode(geometry: SCNPlane(width: 20, height: 10))
        front.geometry?.firstMaterial?.diffuse.contents = NSColor.white
        front.geometry?.firstMaterial?.isDoubleSided = true
        front.position = SCNVector3(0, 5, -10)

        rootNode.addChildNode(front)
    }
    
    func addTrack() {
        let cube = SCNNode(geometry: SCNSphere(radius: 0.5))
        cube.geometry?.firstMaterial?.diffuse.contents = NSColor.yellow
        cube.position = SCNVector3(0, 5, -5)
        
        rootNode.addChildNode(cube)
    }
    
    func addLights() {
        // Add ambient light.
        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        
        ambientLight.type = .ambient
        ambientLight.color = NSColor.white
        ambientLight.intensity = 72
        
        ambientLightNode.light = ambientLight
        
        rootNode.addChildNode(ambientLightNode)
        
        // Add spot light.
        let spotLightNode = SCNNode()
        let spotLight = SCNLight()
        
        spotLight.type = .spot
        spotLight.color = NSColor.magenta
        spotLight.intensity = 1000
        spotLight.spotInnerAngle = 20
        spotLight.spotOuterAngle = 100
        spotLight.castsShadow = true
        
        spotLightNode.light = spotLight
        spotLightNode.position = SCNVector3(0, 10, 0)
        spotLightNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        
        rootNode.addChildNode(spotLightNode)
    }
}

struct RoomView: View {
    let scene = RoomScene()
    
    var body: some View {
        SceneView(
            scene: scene,
            pointOfView: scene.cameraNode,
            options: .allowsCameraControl
        ).ignoresSafeArea()
    }
}

extension Int {
    func degreesToRadians() -> CGFloat {
        return CGFloat(self) * CGFloat.pi / 180.0
    }
}

#Preview {
    RoomView()
}
