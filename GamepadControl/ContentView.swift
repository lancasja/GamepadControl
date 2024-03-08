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
            Text("Live version: \(live.version)")
            Button("Reload osc server", action: live.reload)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
