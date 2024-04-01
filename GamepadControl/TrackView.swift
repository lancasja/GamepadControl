//
//  TrackView.swift
//  GamepadControl
//
//  Created by Admin on 4/1/24.
//

import SwiftUI
import Controls
import Sliders

struct TrackView: View {
    @State var testValue = 0.5
    @State var pan: Float = 0.33
    
    var body: some View {
        VStack {
            Text("track_name")
            
            Divider()
            
            // Sends
            Grid {
                GridRow {
                    ArcKnob("A", value: $pan, range: -50...50)
                        .foregroundColor(.accentColor)
                        .frame(width: 50, height: 50)
                    ArcKnob("B", value: $pan, range: -50...50)
                        .foregroundColor(.accentColor)
                        .frame(width: 50, height: 50)
                }
            }
            
            Divider()
            
            // Controls
            HStack {
                // Left
                VStack {
                    
                    // State
                    VStack {
                        Button {} label: {
                            Image(systemName: "speaker.slash")
                                .font(.largeTitle)
                        }
                        Button {} label: {
                            Image(systemName: "s.square")
                                .font(.largeTitle)
                        }
                        Button {} label: {
                            Image(systemName: "record.circle")
                                .font(.largeTitle)
                        }
                    }
                }
                
                // Right
                VStack {
                    Text("-inf")
                    ValueSlider(value: $testValue)
                        .valueSliderStyle(
                            VerticalValueSliderStyle()
                        )
                }.frame(width: 50)
            }
            
            Divider()
            
            HStack {
                Text("devices")
            }
        }
        .frame(width: 100)
    }
}

#Preview {
    TrackView()
}
