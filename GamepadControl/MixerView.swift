//
//  MixerView.swift
//  GamepadControl
//
//  Created by Jonathan Lancaster on 7/7/24.
//

import SwiftUI
import SceneKit

//enum CameraPerspective: String, CaseIterable {
//    case perspective, top, left, right, front, back, firstPerson
//}

enum RoomModel: String {
    case sphere, box
}

struct MixerView: View {    
    @StateObject private var dawState = DAWState.shared
    
    @State var roomModel: RoomModel = .sphere
    
    @State private var cameraNode = SCNNode()
    @State private var scene = SCNScene()
    
    var body: some View {
        SceneView(
            scene: createScene(),
            pointOfView: cameraNode,
            options: [
                .autoenablesDefaultLighting,
                .allowsCameraControl,
                .temporalAntialiasingEnabled
            ]
        )
    }
    
    func createScene() -> SCNScene {
        
        // ==== SCENE ====
        scene = SCNScene()
        scene.background.contents = NSColor.black
        
        
        // ==== WIREFRAME MATERIAL ====
        let wireframeMaterial = SCNMaterial()
        wireframeMaterial.fillMode = .lines
        wireframeMaterial.diffuse.contents = NSColor.systemTeal
        wireframeMaterial.isDoubleSided = true
        wireframeMaterial.transparency = 0.3
        
        // ==== ROOM SIZE ====
        let roomScale:CGFloat = 1
        
        // ==== ROOM as SPHERE ====
        let mixSphere = SCNSphere(radius: roomScale)
        mixSphere.materials = [wireframeMaterial]
        let mixSphereNode = SCNNode(geometry: mixSphere)
        
        // ==== ROOM as BOX ====
        let mixBox = SCNBox(
            width: roomScale,
            height: roomScale,
            length: roomScale,
            chamferRadius: 0.0
        )
        mixBox.materials = [wireframeMaterial]
        let mixBoxNode = SCNNode(geometry: mixBox)
        
        // ==== CHOOSE ROOM as SPHERE or BOX ====
        switch(self.roomModel) {
        case .sphere:
            scene.rootNode.addChildNode(mixSphereNode)
        case .box:
            scene.rootNode.addChildNode(mixBoxNode)
        }
        
        // ==== RENDER Track Objects ====
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
