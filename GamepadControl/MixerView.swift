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
                
                if (device.name == "E4L Mono Panner") || (device.name == "E4L Stereo Panner") {
                    var x: CGFloat = 0
                    var y: CGFloat = 0
                    var z: CGFloat = 0
                    
                    device.parameters.forEach { param in
                        switch param.name {
                        case "Azim":
                            if let val = param.value as? Float {
                                x = mapRange(
                                    value: CGFloat(val),
                                    fromLow: -180.00,
                                    fromHigh: 180.00,
                                    toLow: -1.00,
                                    toHigh: 1.00
                                )
                            }
                        case "Elev":
                            if let val = param.value as? Float {
                                y = mapRange(
                                    value: CGFloat(val),
                                    fromLow: -90.00,
                                    fromHigh: 90.00,
                                    toLow: -1.00,
                                    toHigh: 1.00
                                )
                            }
                        case "Radius":
                            if let val = param.value as? Float {
                                z = CGFloat(val)
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

func mapRange(value: CGFloat, fromLow: CGFloat, fromHigh: CGFloat, toLow: CGFloat, toHigh: CGFloat) -> CGFloat {
    return (value - fromLow) * (toHigh - toLow) / (fromHigh - fromLow) + toLow
}

#Preview {
    MixerView()
}
