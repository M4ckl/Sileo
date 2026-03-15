import SwiftUI

struct BackgroundView: View {
    @Environment(UserManager.self) var userManager
    
    var theme: AppTheme { userManager.getCurrentTheme() }
    
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
    @Environment(UserManager.self) var userManager
    
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    var body: some View {
        ZStack {
            GradientPaletteView(theme: theme)

            Color.black.opacity(0.1)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: theme.id)
    }
}

struct GradientPaletteView: View {
    let theme: AppTheme
    
    var body: some View {
        ZStack {
            Color(theme.backColor1)
            
            RadialGradient(
                gradient: Gradient(colors: [Color(theme.backColor2), Color(theme.backColor2).opacity(0)]),
                center: .leading,
                startRadius: 0,
                endRadius: 300
            )
            .blendMode(.multiply)
            
            RadialGradient(
                gradient: Gradient(colors: [Color(theme.backColor3), Color(theme.backColor3).opacity(0)]),
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 350
            )
            
            RadialGradient(
                gradient: Gradient(colors: [Color(theme.backColor4), Color(theme.backColor4).opacity(0)]),
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 500
            )
        }
    }
}
