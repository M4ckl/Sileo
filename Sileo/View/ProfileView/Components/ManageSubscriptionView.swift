import SwiftUI

struct ManageSubscriptionView: View {
    // ❌ Убрали binding theme
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    // ✅ 1. Добавляем Environment и AppStorage как в Ачивках
    @Environment(UserManager.self) var userManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Анимация
    @State private var textOpacity: Double = 0
    
    // ✅ 2. Вычисляем тему на лету
    var theme: AppTheme {
        userManager.getCurrentTheme()
    }
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // ВЕРХНЯЯ ПАНЕЛЬ (Без изменений)
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
                
                // КОНТЕНТ
                VStack(spacing: 20) {
                    
                    // Живая иконка (Без изменений расстояния)
                    CalmPlusIcon(theme: theme)
                        .padding(.vertical, 20)
                    
                    // ТЕКСТ (Увеличили spacing с 12 до 32, чтобы распределить по высоте)
                    VStack(spacing: 32) {
                        Text("Thank you for being here.")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundStyle(theme.textColor)
                            .minimumScaleFactor(0.8)
                        
                        Text("Your support helps keep Sileo calm, simple,\nand focused on creating space for pause.")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(theme.textColor.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .minimumScaleFactor(0.8)
                        
                        Text("All themes and sounds are now available,\nand you can pause as often as you need.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.accentColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                            .cornerRadius(20)
                            .minimumScaleFactor(0.8)
                        
                        Text("Below, without any pressure,\nyou can manage your subscription.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(theme.textColor.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                    }
                    .opacity(textOpacity)
                }
                
                Spacer()
                
                // НИЖНИЙ БЛОК
                VStack(spacing: 16) {
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Manage in Apple Settings")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(theme.secondTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(theme.accentColor)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal, 30)
                    
                    #if DEBUG
                    Button(action: {
                        UserManager.shared.resetSubscription()
                        dismiss()
                    }) {
                        Text("Cancel Subscription (Test Mode)")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .padding(.bottom, 10)
                    #endif
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarHidden(true)
        // ✅ 3. Принудительно ставим цветовую схему
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                textOpacity = 1
            }
        }
    }
}
