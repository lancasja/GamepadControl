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

struct ContentView: View {
    @ObservedObject var osc = OSC()
    @ObservedObject var gamepad = Gamepad()
    
    @State var testValue = 0.5
    @State var testKnobVal: Float = 0.5
    
    var body: some View {
        VStack {
            // Tracks
            TrackView()
            
            
        }
        .padding()
        .onAppear {
            self.osc.startServer()
            self.osc.send("/live/song/get/num_tracks")
            self.osc.send("/live/view/start_listen/selected_track")
            
            let els = gamepad.elements.keys.sorted()
            print(els)
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
