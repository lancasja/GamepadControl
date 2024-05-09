//
//  MessageCenter.swift
//  GamepadControl
//
//  Created by Admin on 5/8/24.
//

import SwiftUI

enum AudioControlAction: String {
    case trackMute, trackSolo, trackArm
    case trackVolumeInc, trackVolumeDec
    case trackPrevious, trackNext
    case pannerAzimuthLeft, pannerAzimuthRight
    case pannerElevationInc, pannerElevationDec
    case pannerDistanceInc, pannerDistanceDec
    case pannerSpreadInc, pannerSpreadDec
    case transportPlay, transportStop
    case transportRecord, transportUndo, transportRedo
}

class MessageCenter: ObservableObject {
    
    @ObservedObject var osc = OSC()
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackMute),
            name: Notification.Name(AudioControlAction.trackMute.rawValue),
            object: nil
        )
    }
    
    @objc func handleTrackMute() {
        self.osc.send("/live/track/set/mute", [0, true])
    }
}

