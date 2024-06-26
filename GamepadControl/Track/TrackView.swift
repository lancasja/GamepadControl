//
//  TrackView.swift
//  GamepadControl
//
//  Created by Admin on 4/1/24.
//

import SwiftUI
import SceneKit

struct TrackView: View {
    @ObservedObject var model: Track
    
    init(_model: Track) {
        self.model = _model
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(model.id)")
                    .foregroundStyle(.black)
                    .padding([.leading, .trailing], 12)
                    .padding([.top, .bottom], 4)
                    .background(.yellow)
                
                Text(model.name)
                    .frame(width: 99, alignment: .leading)
                
                Image(systemName: "chevron.down")
            }
            .padding(.trailing, 8)
            
            HStack(spacing: 4) {
                Button {
                    let mute = model.mute
                    model.mute = !mute
                } label: {
                    Image(systemName: "speaker.slash\(model.mute ? ".fill" : "")")
                        .foregroundStyle(model.mute ? .black : .white)
                }
                .buttonStyle(.borderedProminent)
                .tint(model.mute ? .orange : .gray)
                
                
                Button {
                    let solo = model.solo
                    model.solo = !solo
                } label: {
                    Image(systemName: "s.circle\(model.solo ? ".fill" : "")")
                        .foregroundColor(model.solo ? .black : .white)
                }
                .buttonStyle(.borderedProminent)
                .tint(model.solo ? .blue : .gray)
                
                Button {
                    let rec = model.rec
                    model.rec = !rec
                } label: {
                    Image(systemName: "record.circle\(model.rec ? ".fill" : "")")
                        .foregroundColor(model.rec ? .black : .white)
                }
                .buttonStyle(.borderedProminent)
                .tint(model.rec ? .red : .gray)
            }
            
            HStack(spacing: 4) {
                VStack {
                    Text("Azim")
                    HStack(spacing: 0) {
                        Image(systemName: "arrowtriangle.left.fill")
                            .imageScale(.small)
                        Text("\(model.azimuth, specifier: "%.0f")")
                            .frame(width: 25)
                            .padding([.leading, .trailing], 4)
                            .monospaced()
                        Image(systemName: "arrowtriangle.right.fill")
                            .imageScale(.small)
                    }.background(.black)
                }
                .gesture(DragGesture().onChanged({ value in
                    model.azimuth = value.location.x
                }))
                
                VStack {
                    Text("Elev")
                    HStack(spacing: 0) {
                        Image(systemName: "arrowtriangle.up.fill")
                            .imageScale(.small)
                        Text("\(model.elevation, specifier: "%.0f")")
                            .frame(width: 25)
                            .padding([.leading, .trailing], 4)
                            .monospaced()
                        Image(systemName: "arrowtriangle.down.fill")
                            .imageScale(.small)
                    }.background(.black)
                }
                .gesture(DragGesture().onChanged({ value in
                    model.elevation = value.location.x
                }))
                
                VStack {
                    Text("Dist")
                    HStack(spacing: 0) {
                        Image(systemName: "minus")
                            .imageScale(.small)
                        Text("\(model.distance, specifier: "%.0f")")
                            .frame(width: 25)
                            .padding([.leading, .trailing], 4)
                            .monospaced()
                        Image(systemName: "plus")
                            .imageScale(.small)
                    }.background(.black)
                }
                .gesture(DragGesture().onChanged({ value in
                    model.distance = value.location.x
                }))
            }
        }.background()
    }
}

#Preview {
    TrackView(_model: Track())
}
