import SwiftUI

struct AudioVisualizerView: View {
    @State private var isAnimating = false
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.textColor.opacity(0.8))
                    .frame(width: 3, height: isAnimating ? CGFloat.random(in: 12...22) : 5)
                    .animation(
                        .easeInOut(duration: 0.7)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: isAnimating
                    )
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .glassEffect(.clear)
        .onAppear {
            isAnimating = true
        }
    }
}
