import SwiftUI

struct SceneToggle: View {
    enum SceneElements: String {
        case speakers, names
    }
    
    var forEls: SceneElements
    
    @State var hidden = false
    
    private var onSymbolName: String
    private var offSymbolName: String
    
    init(forEls: SceneElements) {
        self.forEls = forEls
        
        switch forEls {
        case .speakers:
            onSymbolName = "hifispeaker.fill"
            offSymbolName = "hifispeaker"
        case .names:
            onSymbolName = "eye"
            offSymbolName = "eye.slash"
        }
    }
    
    var body: some View {
        Image(systemName: hidden ? offSymbolName : onSymbolName)
            .onTapGesture {
                hidden.toggle()
            }
    }
}
