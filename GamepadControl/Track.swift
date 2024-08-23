import SwiftUI

enum TrackProps: String, CaseIterable {
    case index,
         name,
         mute,
         solo,
         arm,
         can_be_armed,
         has_audio_input,
         has_audio_output,
         has_midi_input,
         has_midi_output,
         is_grouped,
         is_foldable,
         color,
         color_index
}

struct Parameter: Identifiable {
    let id = UUID()
    var name: String = ""
    var value: Any = 0
    var min: Float = 0.0
    var max: Float = 0.0
    var is_quantized: Bool = false
    var value_string: String = ""
}

struct Device: Identifiable {
    let id = UUID()
    var name: String = ""
    var class_name: String = ""
    var type: Int = 0
    var num_parameters: Int = 0
    var parameters: [Parameter] = []
}

struct Track: Identifiable {
    let id = UUID()
    
    var index = 0
    var name: String = ""
    var mute: Bool = false
    var solo: Bool = false
    var arm: Bool = false
    var can_be_armed: Bool = false
    var has_audio_input: Bool = false
    var has_audio_output: Bool = false
    var has_midi_input: Bool = false
    var has_midi_output: Bool = false
    var is_grouped: Bool = false
    var is_foldable: Bool = false
    var color: Int = 0
    var color_index: Int = 0
    
    var panning: Float = 0.0
    var volume: Float = 0.0
    
    var num_devices: Int = 0
    var devices: [Device] = []
}
