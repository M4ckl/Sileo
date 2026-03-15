import SwiftUI

struct SplashView: View {
    let theme: AppTheme
    @Binding var isAppReady: Bool
    
    @State private var isAnimating = false

    private let rings: [(name: String, startAngle: Double, endAngle: Double)] = [
        ("CircleIcon1", 0, 360),
        ("CircleIcon2", 360, 0),
        ("CircleIcon3", 0, 360)
    ]
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()

            ZStack {
                ForEach(rings, id: \.name) { ring in
                    Image(ring.name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(isAnimating ? ring.endAngle : ring.startAngle))
                }
            }
            .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    isAppReady = true
                }
            }
        }
    }
}
