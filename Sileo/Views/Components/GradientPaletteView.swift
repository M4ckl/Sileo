import SwiftUI

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
