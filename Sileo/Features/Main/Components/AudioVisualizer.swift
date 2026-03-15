import SwiftUI

struct AudioVisualizerView: View {
    @State private var isAnimating = false
    let theme: AppTheme

    private let heights: [CGFloat] = [14, 22, 18, 12]
    private let durations: [Double] = [0.6, 0.8, 0.5, 0.7]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.textColor.opacity(0.8))
                    .frame(width: 3, height: isAnimating ? heights[index] : 5)
                    .animation(
                        .easeInOut(duration: durations[index])
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
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
