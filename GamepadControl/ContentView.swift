//
//  ContentView.swift
//  GamepadControl
//
//  Created by JL on 2/26/24.
//
//  AbletonOSC docs: https://github.com/ideoforms/AbletonOSC
//  OSCKit docs: https://orchetect.github.io/OSCKit/documentation/osckit/
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @ObservedObject var gamepad = Gamepad()
    @ObservedObject var trackModel = TrackViewModel()
    @ObservedObject var messageCenter = MessageCenter()

    
    let scene = RoomScene()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoomView()
            TrackView()
        }
        .onAppear {
            self.messageCenter.oscStart()
        }
        .onDisappear {
            self.messageCenter.oscStop()
        }
    }
}

#Preview {
    ContentView()
}
