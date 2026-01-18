import SwiftUI

struct AchievementsGridView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(UserManager.self) var userManager
    
    // Переданная настройка темы
    var isDarkMode: Bool
    
    // Вычисляем схему
    var currentScheme: ColorScheme { isDarkMode ? .dark : .light }
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    // ✅ 1. Создаем пространство имен для анимации
    @Namespace private var animationNamespace
    
    // Состояние выбранной медали
    @State private var selectedMedal: Medal?
    // Состояние для анимации вращения в детальном режиме
    @State private var isSpinning = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            // 1. ФОН ПРИЛОЖЕНИЯ
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            
            // 2. ОСНОВНОЙ КОНТЕНТ (Сетка)
            VStack(spacing: 0) {
                // ЗАГОЛОВОК (Виден, только когда медаль НЕ выбрана)
                headerView
                    .opacity(selectedMedal == nil ? 1 : 0)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(userManager.medals) { medal in
                            let isUnlocked = userManager.isMedalUnlocked(medal)
                            
                            // КАРТОЧКА В СЕТКЕ
                            if selectedMedal?.id != medal.id {
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        selectedMedal = medal
                                    }
                                }) {
                                    AchievementCard(medal: medal, isUnlocked: isUnlocked, theme: theme)
                                        // ✅ Привязываем геометрию
                                        .matchedGeometryEffect(id: medal.id, in: animationNamespace)
                                }
                            } else {
                                // ПУСТЫШКА (Занимает место, пока медаль "летает")
                                Color.clear.frame(height: 180)
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
                .opacity(selectedMedal == nil ? 1 : 0) // Скрываем скролл при открытии
            }
            
            // 3. ДЕТАЛЬНЫЙ ПРОСМОТР (Слой поверх всего)
            if let medal = selectedMedal {
                detailView(for: medal)
            }
        }
        .navigationBarHidden(true)
        .environment(\.colorScheme, currentScheme)
    }
    
    // --- КОМПОНЕНТЫ ---
    
    // Верхняя панель (вынесена отдельно, чтобы использовать дважды)
    var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24))
                }
                .foregroundColor(theme.textColor)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .clipShape(Capsule())
                .glassEffect(.clear.interactive())
            }
            Spacer()
            Text("Achievements")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.textColor)
                .textCase(.uppercase)
                .tracking(1)
            Spacer()
            Image(systemName: "chevron.left").opacity(0).padding()
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    // Экран детального просмотра
    @ViewBuilder
    func detailView(for medal: Medal) -> some View {
        let isUnlocked = userManager.isMedalUnlocked(medal)
        
        ZStack {
            // 1. Затемненный фон (размытие)
            Rectangle()
                .fill(Color.black.opacity(0.0)) // Эффект матового стекла // Всегда темный фон для фокуса
                .ignoresSafeArea()
                .opacity(selectedMedal != nil ? 1 : 0)
                .onTapGesture {
                    closeDetail()
                }
            
            VStack(spacing: 0) {
                // 2. Фейковый хедер (чтобы кнопка "Назад" осталась на месте)
                HStack {
                    Button(action: { closeDetail() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                        }
                        .foregroundColor(theme.textColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .clipShape(Capsule())
                        .glassEffect(.clear.interactive())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                // 3. ОГРОМНАЯ МЕДАЛЬ
                ZStack {
                    // Свечение сзади
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .opacity(isUnlocked ? 0.6 : 0)
                    
                    // Сама карточка (но перерисованная для большого размера)
                    AchievementCard(medal: medal, isUnlocked: isUnlocked, theme: theme, isDetail: true)
                        // ✅ Та же геометрия = магия полета
                        .matchedGeometryEffect(id: medal.id, in: animationNamespace)
                        // Добавляем 3D вращение
                        .rotation3DEffect(
                            .degrees(isSpinning ? 10 : 0),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .scaleEffect(1.2) // Делаем чуть больше оригинала
                }
                .onAppear {
                    // Запуск ленивой анимации покачивания
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        isSpinning = true
                    }
                }
                
                Spacer()
                
                // 4. ТЕКСТ СНИЗУ (Появляется с задержкой)
                VStack(spacing: 16) {
                    Text(medal.name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if !isUnlocked {
                        Text("LOCKED")
                            .font(.caption.bold())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Earned")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(theme.accentColor)
                    }
                    
                    Text(medal.description)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 50)
            }
        }
        .zIndex(2) // Убеждаемся, что этот слой выше всего
    }
    
    func closeDetail() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            selectedMedal = nil
            isSpinning = false
        }
    }
}

// ОБНОВЛЕННАЯ КАРТОЧКА (Адаптирована для использования и в сетке, и в деталях)
struct AchievementCard: View {
    let medal: Medal
    let isUnlocked: Bool
    let theme: AppTheme
    var isDetail: Bool = false // Флаг: мы в сетке или на весь экран?
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // Если это детальный просмотр, мы убираем фон карточки и текст,
        // оставляя только красивую круглую иконку
        VStack(spacing: 12) {
            // ИКОНКА
            ZStack {
                Circle()
                    .fill(
                        isUnlocked ?
                        LinearGradient(colors: [theme.accentColor.opacity(0.8), theme.accentColor], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    // В деталях иконка большая, в сетке маленькая
                    .frame(width: isDetail ? 200 : 80, height: isDetail ? 200 : 80)
                    .shadow(color: isUnlocked ? theme.accentColor.opacity(0.4) : .clear, radius: isDetail ? 20 : 10, x: 0, y: 5)
                
                Image(systemName: medal.icon)
                    .font(.system(size: isDetail ? 80 : 36))
                    .foregroundColor(isUnlocked ? .white : theme.accentColor.opacity(0.6))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 2)
            }
            .grayscale(isUnlocked ? 0 : 1.0)
            .opacity(isUnlocked ? 1 : 0.6)
            
            // ТЕКСТ (Показываем только в сетке. В деталях текст вынесен вниз отдельно)
            if !isDetail {
                Text(medal.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .opacity(isUnlocked ? 1 : 0.5)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        // В деталях убираем белую подложку, оставляем только иконку
        .frame(height: isDetail ? 250 : 180)
        .background(
            isDetail ? nil : // Если деталь - фона нет
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
