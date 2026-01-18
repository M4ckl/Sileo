import SwiftUI
import StoreKit

struct CalmPlusIcon: View {
    var theme: AppTheme // Передаем тему для цвета градиента
    @State private var isBreathing = false
    @State private var isFloating = false
    
    var body: some View {
        ZStack {
            // Фон: Градиент круга
            Circle()
                .fill(
                    LinearGradient(
                        colors: [theme.accentColor, theme.accentColor.opacity(0.6), .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .shadow(color: theme.accentColor.opacity(0.5), radius: 20, x: 0, y: 10)
            
            // Картинка: Белая, светится и тускнеет
            Image("CalmPlusImage") // Твоя картинка
                .resizable()
                .renderingMode(.original) // Оставляем оригинальный (белый) цвет
                .scaledToFit()
                .frame(width: 128, height: 128) // Размер картинки внутри круга
                .opacity(isBreathing ? 1.0 : 0.7) // Пульсация (тускнеет/светлеет)
                .shadow(color: .white.opacity(isBreathing ? 0.8 : 0.2), radius: isBreathing ? 15 : 5)
        }
        // Эффект 2.5D (Парение и легкий наклон)
        .offset(y: isFloating ? -5 : 5)
        .rotation3DEffect(
            .degrees(isFloating ? 2 : -2),
            axis: (x: 1, y: 0, z: 0) // Легкий наклон вперед-назад
        )
        .onAppear {
            // Анимация 1: Яркость (1 секунда)
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isBreathing.toggle()
            }
            // Анимация 2: Парение (чуть медленнее для естественности)
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isFloating.toggle()
            }
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var storeManager = StoreManager.shared
    @Environment(\.colorScheme) var colorScheme
    // ✅ 1. Environment и AppStorage для темы
    @Environment(UserManager.self) var userManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Анимация текста
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    
    // ✅ 2. Вычисляем тему
    var theme: AppTheme {
        userManager.getCurrentTheme()
    }
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ВЕРХНЯЯ ПАНЕЛЬ
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                        }
                        .foregroundColor(theme.textColor)
                        .padding(.vertical ,8)
                        .padding(.horizontal , 12)
                        .clipShape(Capsule())
                        .glassEffect(.clear.interactive())
                    }
                    Spacer()
                    Text("CALM PLUS") // Исправил "СALM" на английскую C
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textColor)
                        .textCase(.uppercase)
                        .tracking(1)
                    Spacer()
                    // Пустышка для баланса
                    Image(systemName: "chevron.left").opacity(0).padding()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // ИКОНКА (Без изменений)
                CalmPlusIcon(theme: theme)
                    .padding(.vertical, 20)
                
                // ТЕКСТ И БЛОК ВОЗМОЖНОСТЕЙ
                VStack(spacing: 16) { // Чуть увеличил общий spacing для воздуха
                    
                    Text("This is not just a subscription.")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(theme.textColor)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                    
                    Text("It’s a small contribution to your own calm.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(theme.textColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.9)
                    
                    Text("With Calm Plus, you unlock more themes, sounds,\nand unlimited pauses —")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(theme.textColor.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .minimumScaleFactor(0.9)
                    
                    // ✅ НОВЫЙ БЛОК ВОЗМОЖНОСТЕЙ
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 12) {
                            Image(systemName: "infinity")
                                .foregroundColor(theme.accentColor)
                                .frame(width: 24)
                            Text("Unlimited pauses")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(theme.textColor)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "paintpalette.fill")
                                .foregroundColor(theme.accentColor)
                                .frame(width: 24)
                            Text("4 additional themes")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(theme.textColor)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(theme.accentColor)
                                .frame(width: 24)
                            Text("4 additional sounds")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(theme.textColor)
                        }
                    }
                    .padding(24) // Внутренний отступ
                    .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1)) // Полупрозрачный фон
                    .cornerRadius(30) // Радиус 30
                    .padding(.horizontal, 10) // Отступ от краев экрана
                    
                    Text("No pressure. No goals.\nJust more space to breathe.")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.accentColor)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 20)
                .opacity(textOpacity)
                .offset(y: textOffset)
                
                Spacer()
                
                // КНОПКА ПОКУПКИ
                VStack(spacing: 12) {
                    if let product = storeManager.products.first {
                        Button(action: {
                            Task {
                                await storeManager.purchase(product)
                                if UserManager.shared.isPremium { dismiss() }
                            }
                        }) {
                            Text("Purchase for \(product.displayPrice)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.accentColor)
                                .cornerRadius(30)
                                .shadow(color: theme.accentColor.opacity(0.4), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 30)
                    } else {
                        ProgressView()
                            .tint(theme.textColor)
                            .padding()
                    }
                    
                    Text("You can cancel anytime. No pressure.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(theme.textColor.opacity(0.5))
                    
                    Button("Restore Purchases") {
                        Task { await storeManager.restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundColor(theme.textColor.opacity(0.3))
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        // ✅ 3. Принудительно ставим цветовую схему
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .task {
            await storeManager.loadProducts()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                textOpacity = 1
                textOffset = 0
            }
        }
    }
}
