import SwiftUI

struct ViewsPicker: View {
    var options: [CameraPerspective] = CameraPerspective.allCases
    
    @State var selected: CameraPerspective = .perspective
    
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
