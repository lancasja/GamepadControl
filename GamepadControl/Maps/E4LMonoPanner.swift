//
//  E4LMonoPanner.swift
//  GamepadControl
//
//  Created by Jonathan Lancaster on 7/8/24.
//

struct E4LMonoPanner {
    enum ParameterNames: String {
        case device_on = "Device On"
        
        case azim = "Azim"
        case azim_lfo_time_mode = "Azim LFO Time Mode"
        case azim_lfo_freq = "Azim LFO Freq"
        case azim_lfo_rate = "Azim LFO Rate"
        case azim_lfo_mode = "Azim LFO Mode"
        case azim_lfo_depth = "Azim LFO Depth"
        case azim_lfo_onoff = "Azim LFO On/Off"
        
        case elev = "Elev"
        case elev_lfo_time_mode = "Elev LFO Time Mode"
        case elev_lfo_freq = "Elev LFO Freq"
        case elev_lfo_rate = "Elev LFO Rate"
        case elev_lfo_mode = "Elev LFO Polar"
        case elev_lfo_depth = "Elev LFO Depth"
        case elev_lfo_onoff = "Elev LFO On/Off"
        
        case radius = "Radius"
        case range = "Range"
    }
}
