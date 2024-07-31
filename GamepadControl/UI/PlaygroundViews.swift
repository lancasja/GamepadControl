//
//  PlaygroundViews.swift
//  GamepadControl
//
//  Created by Jonathan Lancaster on 7/23/24.
//

import SwiftUI
import SceneKit

let roomRadius: CGFloat = 1

enum CameraPerspective: String, CaseIterable {
    case perspective, top, left, right, front, back, firstPerson
}

enum CameraPOV: CaseIterable {
    case perspective, top, left, right, front, back, firstPerson
    
    var vector: (SCNVector3, SCNVector3) {
        var position: SCNVector3
        var rotation: SCNVector3
        
        let distance = roomRadius * 2
        let deg90 = deg2rad(90)
        let deg180 = deg2rad(180)
        
        switch self {
        case .perspective:
            position = SCNVector3(0, 0, 2)
            rotation = SCNVector3(0, 0, 0)
        case .top:
            position = SCNVector3(0, distance, 0)
            rotation = SCNVector3(-deg90, 0, 0)
        case .left:
            position = SCNVector3(-distance, 0, 0)
            rotation = SCNVector3(0, -deg90, 0)
        case .right:
            position = SCNVector3(distance, 0, 0)
            rotation = SCNVector3(0, deg90, 0)
        case .front:
            position = SCNVector3(0, 0, -distance)
            rotation = SCNVector3(0, deg180, 0)
        case .back:
            position = SCNVector3(0, 0, distance)
            rotation = SCNVector3(0, 0, 0)
        case .firstPerson:
            position = SCNVector3(0, 0, 1)
            rotation = SCNVector3(0, 0, 0)
        }
        
        return (position, rotation)
    }
}

class Camera: SCNNode, ObservableObject {
    @Published var pov: CameraPOV = .top
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override init() {
        super.init()
        self.camera = SCNCamera()
        self.setViewpoint(self.pov)
    }
    
    func setViewpoint(_ pov: CameraPOV) {
        self.pov = pov
        self.position = pov.vector.0
        self.eulerAngles = pov.vector.1
    }
}

struct PlaygroundViews: View {
    let sceneView = SCNView()
    let scene = SCNScene()
    @StateObject var cameraNode = Camera()
    
    @State private var trackObjects: [TrackObject] = [TrackObject()]
//    @State private var trackDistance: Double = 1.0
//    @State private var trackAzim: Double = 0
//    @State private var trackElev: Double = 0
    @State private var trackSize: CGFloat = 0.05
    
    var body: some View {
        VStack {
            SceneView(
                scene: scene,
                pointOfView: cameraNode,
                options: [
                    .autoenablesDefaultLighting,
                    .allowsCameraControl
                ]
            )
            .onAppear {
//                trackDistance = trackObjects[0].position.y
//                trackAzim = trackObjects[0].eulerAngles.y
//                trackElev = trackObjects[0].eulerAngles.x
                
                let sphere = SCNSphere(radius: roomRadius)
                sphere.materials = [WireframeMaterial()]
                let sphereNode = SCNNode(geometry: sphere)
                
                scene.rootNode.addChildNode(sphereNode)
                scene.rootNode.addChildNode(trackObjects[0])
                scene.rootNode.addChildNode(Speaker())
                
                sceneView.pointOfView = cameraNode
            }
        }
        
        Slider(
            value: $trackObjects[0].object.position.y,
            in: -roomRadius/2 ... roomRadius/2,
            label: {
                Text("Distance")
            }
        )
        .onChange(of: trackObjects[0].object.position.y) { oldValue, newValue in
            trackObjects[0].setDistance(newValue)
        }
        
        Slider(
            value: $trackObjects[0].eulerAngles.y,
            in: -CGFloat.pi ... CGFloat.pi,
            label: {
                Text("Azimuth")
            }
        )
        .onChange(of: trackObjects[0].eulerAngles.y) { oldValue, newValue in
            trackObjects[0].setAzim(-newValue)
        }
        
        Slider(
            value: $trackObjects[0].eulerAngles.x,
            in: -CGFloat.pi ... CGFloat.pi,
            label: {
                Text("Elevation")
            }
        )
        .onChange(of: trackObjects[0].eulerAngles.x) { oldValue, newValue in
            trackObjects[0].setElev(newValue)
        }
        
        Slider(
            value: $trackSize,
            in: 0.02 ... 0.2,
            label: {
                Text("Size")
            }
        )
        .onChange(of: trackSize) { oldValue, newValue in
            trackObjects[0].setSize(newValue)
        }
    }
}

func deg2rad(_ degrees: CGFloat) -> CGFloat {
    return degrees * CGFloat.pi / 180
}

class WireframeMaterial: SCNMaterial {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init() {
        super.init()
        self.fillMode = .lines
        self.diffuse.contents = NSColor.systemTeal
        self.isDoubleSided = true
        self.transparency = 1
    }
}

class Speaker: SCNNode {
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override init() {
        super.init()
        self.geometry = SCNBox(
            width: 0.1,
            height: 0.15,
            length: 0.1,
            chamferRadius: 0
        )
        self.geometry?.materials = [WireframeMaterial()]
        self.position.z = -roomRadius
    }
}

class TrackObject: SCNNode, ObservableObject {
    var object = SCNNode(geometry: SCNSphere(radius: 0.05))
    var pole = SCNNode(geometry: SCNCylinder(radius: 0.01, height: roomRadius))
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override init() {
        super.init()
        
        // Pivot (as a directional cone)
        self.geometry = SCNCone(
            topRadius: 0,
            bottomRadius: 0.05,
            height: 0.1
        )
        self.geometry?.materials = [WireframeMaterial()]
        
        // Pole that the object attaches to and moves along
        pole.geometry?.materials = [WireframeMaterial()]
        pole.geometry?.firstMaterial?.transparency = 0.05
        pole.pivot = SCNMatrix4MakeTranslation(0, -roomRadius / 2, 0)
        
        // Visible object representing a track
        object.geometry?.materials = [WireframeMaterial()]
        object.position.y = 0 // distance (z)
        
        pole.addChildNode(object)
        self.addChildNode(pole)
        
        self.eulerAngles.x = deg2rad(-90)
        self.eulerAngles.y = 0
        self.eulerAngles.z = 0
    }
    
    func setDistance(_ value: Double) {
        object.position.y = value
    }
    
    func setAzim(_ value: Double) {
        self.eulerAngles.y = value
    }
    
    func setElev(_ value: Double) {
        self.eulerAngles.x = value
    }
    
    func setSize(_ value: CGFloat) {
        if let geometry = object.geometry as? SCNSphere {
            geometry.radius = value
        }
    }
}

#Preview {
    PlaygroundViews()
}
