//
//  MixerView.swift
//  GamepadControl
//
//  Created by Jonathan Lancaster on 7/7/24.
//

import SwiftUI
import SceneKit

struct MixerView: View {
    @StateObject private var dawState = DAWState.shared
    
    var body: some View {
        SceneView(
            scene: createScene(),
            options: [.autoenablesDefaultLighting, .allowsCameraControl]
        )
    }
    func createScene() -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = NSColor.black
        
        // Sphere geometry
        let mixSphere = SCNSphere(radius: 1)
        
        // Sphere material
        let mixSphereMaterial = SCNMaterial()
        mixSphereMaterial.fillMode = .lines
        mixSphereMaterial.diffuse.contents = NSColor.green
        mixSphereMaterial.isDoubleSided = true
        mixSphereMaterial.transparency = 0.3
        mixSphere.materials = [mixSphereMaterial]
        
        // Scene node
        let mixSphereNode = SCNNode(geometry: mixSphere)
        scene.rootNode.addChildNode(mixSphereNode)
        
        self.dawState.tracks.forEach { track in
            
            if track.devices.count > 0 {
                let device = track.devices[0]
                
                if device.name == "Audio Effect Rack" {
                    var x: CGFloat = 0
                    var y: CGFloat = 0
                    var z: CGFloat = 0
                    
                    device.parameters.forEach { param in
                        switch param.name {
                        case "Macro 1":
                            if let val = param.value as? Float {
                                x = (CGFloat(val - 1) / 63.0) - 1.0
                            }
                        case "Macro 2":
                            if let val = param.value as? Float {
                                y = (CGFloat(val - 1) / 63.0) - 1.0
                            }
                        case "Macro 3":
                            if let val = param.value as? Float {
                                z = (CGFloat(val - 1) / 63.0) - 1.0
                            }
                        default:
                            break
                        }
                    }
                    
                    let trackNode = createTrackNode()
                    let position = SCNVector3(x: x, y: y, z: z)
                    trackNode.position = position
                    mixSphereNode.addChildNode(trackNode)
                }
            }
        }
        
        
        
        return scene
    }
    
    func createTrackNode() -> SCNNode {
        let trackObj = SCNSphere(radius: 0.05)
        trackObj.firstMaterial?.diffuse.contents = NSColor.yellow
        let trackNode = SCNNode(geometry: trackObj)
        
        return trackNode
    }
}

#Preview {
    MixerView()
}
