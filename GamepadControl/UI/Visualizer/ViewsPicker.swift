import SwiftUI

struct ViewsPicker: View {
    var options: [CameraView] = CameraView.allCases
    
    @State var selected: CameraView = .perspective
    
    var body: some View {
        Picker("", selection: $selected) {
            ForEach(options, id: \.self) { option in
                Text("\(option)")
            }
        }
        .pickerStyle(.menu)
        .frame(width: 140)
    }
}
