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

class StateStore: ObservableObject {
    var tracks: [Track] = []
}

struct ContentView: View {
    @ObservedObject var gamepad = Gamepad()
    @ObservedObject var messageCenter = MessageCenter()
    
    var store = StateStore()
    
    let scene = RoomScene()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoomView()
            
            HStack {
                ForEach(store.tracks) { track in
                    TrackView(_model: track)
                }
            }
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
