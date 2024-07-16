import SwiftUI

struct MainView: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                HStack(spacing: 2) {
                    VisualizerView()
                    VisualizerView(defaultCamera: .top)
                }
                
                TaskBar()
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Objects")
                    
                    HStack(spacing: 2) {
                        Button {} label: {
                            Image(systemName: "m.circle")
                        }
                        
                        Button {} label: {
                            Image(systemName: "s.circle")
                        }
                    }
                }
                
                HStack {
                    Text("1-Audio")
                    // VolumeMeter()
                    Spacer()
                    Image(systemName: "lock.open")
                }
            }
        }
    }
}

#Preview {
    MainView()
}
