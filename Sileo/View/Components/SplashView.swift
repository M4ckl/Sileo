import SwiftUI

struct SplashView: View {
    let theme: AppTheme
    // Передаем сюда связь с главным экраном
    @Binding var isAppReady: Bool
    
    @State private var isAnimating = false
    // УБРАЛИ: @State private var viewOpacity: Double = 1.0 — больше не нужно

    var body: some View {
        ZStack {
            // Фон
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            // Вращающаяся иконка
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
        // УБРАЛИ: .opacity(viewOpacity) — больше не нужно
        .onAppear {
            isAnimating = true
            
            // НОВАЯ ЛОГИКА:
            // Просто ждем 3 секунды и переключаем состояние.
            // Всю красоту перехода сделает .transition(.opacity) в файле SileoApp.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // Используем withAnimation здесь, чтобы переход в главном файле был плавным
                withAnimation(.easeOut(duration: 1.0)) {
                    isAppReady = true
                }
            }
        }
    }
}
