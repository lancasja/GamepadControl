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
    @ObservedObject var osc = OSC()
    @ObservedObject var gamepad = Gamepad()
    @ObservedObject var trackModel = TrackViewModel()
    
    let scene = RoomScene()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoomView()
            TrackView()
        }
        .onAppear {
            self.osc.startServer()
            self.osc.send("/live/song/get/num_tracks")
            self.osc.send("/live/view/start_listen/selected_track")
        }
        .onDisappear {
            self.osc.send("/live/view/stop_listen/selected_track")
            self.osc.stopServer()
        }
    }
}

#Preview {
    ContentView()
}
