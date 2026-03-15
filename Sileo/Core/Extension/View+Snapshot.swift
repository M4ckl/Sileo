import SwiftUI

@MainActor
extension View {
    func snapshot() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = UITraitCollection.current.displayScale
        return renderer.uiImage
    }
}
