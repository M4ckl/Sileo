import SwiftUI

struct AudioVisualizerView: View {
    @State private var isAnimating = false
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(theme.textColor.opacity(0.8))
                    // Логика высоты: если анимируется, выбираем случайную высоту, иначе минимальную (5)
                    .frame(width: 3, height: isAnimating ? CGFloat.random(in: 12...22) : 5)
                    .animation(
                        .easeInOut(duration: 0.7) // ✅ 1. Сделали медленнее (было 0.4)
                        .repeatForever(autoreverses: true) // ✅ 2. Добавили плавный возврат назад
                        .delay(Double(index) * 0.15), // Чуть увеличили задержку волны
                        value: isAnimating
                    )
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .glassEffect(.clear.interactive())
        .onAppear {
            isAnimating = true
        }
    }
}
