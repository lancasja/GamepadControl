import SwiftUI

struct TaskBar: View {
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "headphones")
                Image(systemName: "lightbulb")
            }
            
            HStack {
                Image(systemName: "arrow.uturn.backward")
                Image(systemName: "clock")
                Image(systemName: "arrow.uturn.forward")
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "bell.fill")
                Image(systemName: "gearshape.fill")
                Image(systemName: "questionmark.circle")
            }
        }
    }
}

#Preview {
    TaskBar()
}
