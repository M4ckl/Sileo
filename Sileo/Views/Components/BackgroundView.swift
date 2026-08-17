import SwiftUI

struct BackgroundView: View {
    let theme: AppTheme
    
    var body: some View {
        ZStack {
            GradientPaletteView(theme: theme)
            
            Image(theme.backImage)
                .resizable()
                .scaledToFill()

            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.4)

            Color(theme.backColor1)
                .blendMode(.overlay)
                .opacity(0.4)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: theme.id)
    }
}

struct BackgroundOnlyColorsView: View {
    let theme: AppTheme
    
    var body: some View {
        ZStack {
            GradientPaletteView(theme: theme)

            Color.black.opacity(0.1)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: theme.id)
    }
}
