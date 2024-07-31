import SwiftUI

struct VisualizerView: View {
    
    var defaultCamera: CameraPerspective
    
    init(defaultCamera: CameraPerspective = .perspective) {
        self.defaultCamera = defaultCamera
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            MixerView()
            
            HStack {
                ViewsPicker(selected: defaultCamera)
                
                Spacer()
                
                HStack {
                    SceneToggle(forEls: .speakers)
                    SceneToggle(forEls: .names)
                    
                    Image(systemName: "arrow.down.backward.and.arrow.up.forward")
                }
            }
        }
    }
}

#Preview {
    VisualizerView()
}
