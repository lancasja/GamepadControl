//
//  TrackView.swift
//  GamepadControl
//
//  Created by Admin on 4/1/24.
//

import SwiftUI
import Controls

struct TrackView: View {
    @State var index = 0
    @State var name = "track_name"
    @State var mute = false
    @State var solo = false
    @State var rec = false
    @State var gain = 0.0
    @State var size = 1
    @State var azimuth = 0.0
    @State var elevation = 0.0
    @State var distance = 0.0
    @State var popover = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(index)")
                    .foregroundStyle(.black)
                    .padding([.leading, .trailing], 12)
                    .padding([.top, .bottom], 4)
                    .background(.yellow)
                
                Text(name)
                    .frame(width: 99, alignment: .leading)
                
//                Image(systemName: "chevron.down")
            }
            .padding(.trailing, 8)
            
            HStack(spacing: 4) {
                Button {
                    mute = !mute
                } label: {
                    Image(systemName: "speaker.slash\(mute ? ".fill" : "")")
                        .foregroundStyle(mute ? .black : .white)
                }
                .buttonStyle(.borderedProminent)
                .tint(mute ? .orange : .gray)
                
                
                Button {
                    solo = !solo
                } label: {
                    Image(systemName: "s.circle\(solo ? ".fill" : "")")
                        .foregroundColor(solo ? .black : .white)
                }
                .buttonStyle(.borderedProminent)
                .tint(solo ? .blue : .gray)
                
                Button {
                    rec = !rec
                } label: {
                    Image(systemName: "record.circle\(rec ? ".fill" : "")")
                        .foregroundColor(rec ? .black : .white)
                }
                .buttonStyle(.borderedProminent)
                .tint(rec ? .red : .gray)
            }
            
            HStack(spacing: 4) {
                VStack {
                    Text("Azim")
                    HStack(spacing: 0) {
                        Image(systemName: "arrowtriangle.left.fill")
                            .imageScale(.small)
                        Text("\(azimuth, specifier: "%.0f")")
                            .frame(width: 25)
                            .padding([.leading, .trailing], 4)
                            .monospaced()
                        Image(systemName: "arrowtriangle.right.fill")
                            .imageScale(.small)
                    }.background(.black)
                }
                .gesture(DragGesture().onChanged({ value in
                    azimuth = value.location.x
                }))
                
                VStack {
                    Text("Elev")
                    HStack(spacing: 0) {
                        Image(systemName: "arrowtriangle.up.fill")
                            .imageScale(.small)
                        Text("\(elevation, specifier: "%.0f")")
                            .frame(width: 25)
                            .padding([.leading, .trailing], 4)
                            .monospaced()
                        Image(systemName: "arrowtriangle.down.fill")
                            .imageScale(.small)
                    }.background(.black)
                }
                .gesture(DragGesture().onChanged({ value in
                    elevation = value.location.x
                }))
                
                VStack {
                    Text("Dist")
                    HStack(spacing: 0) {
                        Image(systemName: "minus")
                            .imageScale(.small)
                        Text("\(distance, specifier: "%.0f")")
                            .frame(width: 25)
                            .padding([.leading, .trailing], 4)
                            .monospaced()
                        Image(systemName: "plus")
                            .imageScale(.small)
                    }.background(.black)
                }
                .gesture(DragGesture().onChanged({ value in
                    distance = value.location.x
                }))
            }
        }.background()
    }
}

#Preview {
    TrackView()
}
