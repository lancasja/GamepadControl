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
import OSCKit

struct ContentView: View {
    @ObservedObject var live = Live()
    
    var body: some View {
        VStack {
            Text("Live version: \(live.version[0]).\(live.version[1])")
            Text("Selected track index: \(live.selected_track)")
            Button("Print tracks", action: live.printTracks)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
