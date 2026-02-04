import SwiftUI

struct SplashView: View {
    let theme: AppTheme
    @Binding var isAppReady: Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            
            Image("CircleIcon1")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: isAnimating)
            
            Image("CircleIcon2")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(isAnimating ? 0 : 360))
                .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: isAnimating)
            
            Image("CircleIcon3")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
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
