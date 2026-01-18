import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(UserManager.self) var userManager
        
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    // Выбранный день (для статистики)
    @State private var selectedDate: Date = Date()
    
    // Текущий месяц (для скролла)
    @State private var currentMonth: Date = {
        let components = Calendar.current.dateComponents([.year, .month], from: HistoryManager.shared.currentDate)
        return Calendar.current.date(from: components)!
    }()
    
    // Модалка выбора даты
    @Namespace private var animation
    @State private var showWheelPicker = false
    @State private var currentStatsPage = 0
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    // Список месяцев для карусели
    @State private var monthsList: [Date] = []
    
    var stats: DailyData {
        HistoryManager.shared.getData(for: selectedDate)
    }
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // 1. ПОДНЯЛИ ВЕСЬ КОНТЕНТ ВЫШЕ
                // Было 40, стало 20.
                Spacer().frame(height: 20)
                
                // ==========================================
                // БЛОК 1: КАРУСЕЛЬ МЕСЯЦЕВ (HEADER)
                // ==========================================
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .glassEffect(.clear)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    
                    GeometryReader { geo in
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 0) {
                                    ForEach(monthsList, id: \.self) { monthDate in
                                        
                                        let isSelected = calendar.isDate(monthDate, equalTo: currentMonth, toGranularity: .month)
                                        
                                        ZStack {
                                            if isSelected {
                                                Capsule()
                                                    .frame(height: 40)
                                                    .glassEffect(.clear.interactive())
                                                    .matchedGeometryEffect(id: "activeTab", in: animation)
                                            }
                                            
                                            Text(monthDate.monthYearString().capitalized)
                                                .font(.system(size: 16, weight: isSelected ? .bold : .medium, design: .rounded))
                                                .foregroundColor(isSelected ? theme.secondTextColor : .white.opacity(0.5))
                                                .scaleEffect(isSelected ? 1.0 : 0.95)
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 20)
                                                .fixedSize()
                                        }
                                        .id(monthDate)
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                currentMonth = monthDate
                                            }
                                        }
                                        .onLongPressGesture(minimumDuration: 1.0) {
                                            if isSelected {
                                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                                generator.impactOccurred()
                                                showWheelPicker = true
                                            } else {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                    currentMonth = monthDate
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, geo.size.width / 2 - 60)
                            }
                            .onChange(of: currentMonth) { _, newValue in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    proxy.scrollTo(newValue, anchor: .center)
                                }
                            }
                            .onAppear {
                                if monthsList.isEmpty { generateMonths() }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    proxy.scrollTo(currentMonth, anchor: .center)
                                }
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                .frame(height: 48)
                .padding(.horizontal, 20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                
                // 2. РАССТОЯНИЕ МЕЖДУ МЕСЯЦАМИ И КАЛЕНДАРЕМ (12px)
                Spacer().frame(height: 12)
                
                // ==========================================
                // БЛОК 2: КАЛЕНДАРЬ
                // ==========================================
                VStack(spacing: 15) {
                    HStack {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    TabView(selection: $currentMonth) {
                        ForEach(monthsList, id: \.self) { monthDate in
                            MonthGridView(
                                month: monthDate,
                                theme: theme,
                                selectedDate: $selectedDate,
                                currentMonth: $currentMonth
                            )
                            .tag(monthDate)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                .cornerRadius(30)
                .padding(.horizontal, 20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                .frame(height: 340)
                
                // 3. РАССТОЯНИЕ ОТ КАЛЕНДАРЯ ДО ДИВАЙДЕРА (14px)
                Spacer().frame(height: 14)
                
                // 4. НОВЫЙ ДИЗАЙН ДИВАЙДЕРА
                Capsule()
                    .fill(theme.textColor.opacity(0.1)) // Полупрозрачный цвет текста
                    .frame(height: 2) // Толще
                    .padding(.horizontal, 40) // Не касается краев экрана
                
                // 5. РАССТОЯНИЕ ОТ ДИВАЙДЕРА ДО СТАТИСТИКИ (14px)
                Spacer().frame(height: 14)
                
                // ==========================================
                // БЛОК 3: СТАТИСТИКА
                // ==========================================
                ZStack {
                    // Фон блока
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    
                    VStack(spacing: 0) {
                        // Контент (Табы)
                        TabView(selection: $currentStatsPage) {
                            statsOverview
                                .tag(0)
                            
                            sessionsGraph
                                .tag(1)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .animation(.easeInOut(duration: 0.3), value: currentStatsPage)
                        
                        // Индикаторы (Точки) внизу
                        HStack(spacing: 6) {
                            ForEach(0..<2) { index in
                                Capsule()
                                    .fill(currentStatsPage == index ? theme.accentColor : Color.gray.opacity(0.3))
                                    .frame(width: currentStatsPage == index ? 20 : 6, height: 6)
                                    .animation(.spring(), value: currentStatsPage)
                            }
                        }
                        .padding(.bottom, 12) // Отступ от самого низа белого блока
                    }
                }
                .frame(height: 180) // ⚠️ Чуть увеличил высоту (было 160), чтобы график влез нормально
                .padding(.horizontal, 20)
                .animation(.easeInOut(duration: 0.3), value: selectedDate)
                
                // 6. ПРИЖИМАЕМ ВСЁ ВНИЗ
                Spacer(minLength: 0)
                
                // --- НИЖНЯЯ ПАНЕЛЬ ---
                HStack {
                    Text("HISTORY")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .tracking(2)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                        .glassEffect(.clear.interactive())
                        .foregroundStyle(theme.textColor.opacity(0.7))
                    Spacer()
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Text("back")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .glassEffect(.clear.interactive())
                        .foregroundStyle(theme.textColor)
                    }
                }
                .padding(.horizontal, 20)
                // 7. МИНИМАЛЬНЫЙ ОТСТУП, ЧТОБЫ БЫЛО МАКСИМАЛЬНО НИЗКО
                // safeAreaPadding сделает остальную работу (поднимет над Home Indicator)
                .padding(.bottom, 0)
            }
            .safeAreaPadding(.bottom)
        }
        .navigationBarHidden(true)
        .onAppear {
            if monthsList.isEmpty { generateMonths() }
        }
        .sheet(isPresented: $showWheelPicker) {
            WheelPickerSheet(currentMonth: $currentMonth, theme: theme)
        }
    }
    
    // ... [ОСТАЛЬНОЙ КОД БЕЗ ИЗМЕНЕНИЙ] ...
    // Скопируй сюда функции generateMonths, statsOverview, sessionsGraph,
    // а также структуры MonthGridView и WheelPickerSheet из предыдущего кода.
    
    func generateMonths() {
        let now = Date()
        let calendar = Calendar.current
        guard let start = calendar.date(byAdding: .year, value: -5, to: now),
              let end = calendar.date(byAdding: .year, value: 2, to: now) else { return }
        
        var date = start
        var res: [Date] = []
        
        let components = calendar.dateComponents([.year, .month], from: date)
        date = calendar.date(from: components)!
        
        while date <= end {
            res.append(date)
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
        monthsList = res
    }
    
    var statsOverview: some View {
            VStack(spacing: 0) {
                // 1. ЗАГОЛОВОК (Идентичен Графику)
                HStack {
                    Text(dateString(date: selectedDate))
                        .font(.system(size: 14, weight: .medium, design: .rounded)) // Как в графике
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                // Отступ, чтобы цифры были по центру по вертикали
                Spacer()
                
                // 2. ЦИФРЫ
                HStack(spacing: 0) {
                    // Левая часть (Минуты)
                    VStack(spacing: 2) {
                        Text("\(stats.totalMinutes)")
                            .font(.system(size: 44, weight: .light, design: .rounded))
                            .foregroundColor(theme.accentColor)
                            .contentTransition(.numericText())
                        
                        Text("min")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.6))
                            .textCase(.uppercase) // Капсом, чтобы сочеталось с заголовком
                    }
                    .frame(maxWidth: .infinity) // Занимает ровно половину ширины
                    
                    // Разделитель (Стиль как у сетки графика)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 2, height: 50)
                    
                    // Правая часть (Паузы)
                    VStack(spacing: 2) {
                        Text("\(stats.sessionsCount)")
                            .font(.system(size: 44, weight: .light, design: .rounded))
                            .foregroundColor(theme.textColor)
                            .contentTransition(.numericText())
                        
                        Text("pauses")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.6))
                            .textCase(.uppercase)
                    }
                    .frame(maxWidth: .infinity)
                }
                // Небольшая коррекция, чтобы оптически центр был приятнее
                .padding(.bottom, 10)
                
                Spacer()
            }
        }
    
    var sessionsGraph: some View {
        VStack(spacing: 10) {
            // Заголовок
            HStack {
                Text("Sessions Timeline")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            
            if stats.sessions.isEmpty {
                Spacer()
                Text("No data")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary.opacity(0.5))
                Spacer()
            } else {
                // ГРАФИК
                HStack(alignment: .bottom, spacing: 10) {
                    
                    // 1. ОСЬ Y (Время)
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("60m").font(.system(size: 9, weight: .bold)).foregroundColor(.gray.opacity(0.5))
                        Spacer()
                        Text("30m").font(.system(size: 9, weight: .bold)).foregroundColor(.gray.opacity(0.5))
                        Spacer()
                        Text("0m").font(.system(size: 9, weight: .bold)).foregroundColor(.gray.opacity(0.5))
                    }
                    .frame(height: 80) // Высота рабочей области графика
                    .padding(.bottom, 16) // Компенсация подписей оси X
                    
                    // 2. ОБЛАСТЬ СТОЛБЦОВ
                    ZStack(alignment: .bottom) {
                        // СЕТКА (Линии)
                        VStack {
                            Divider().background(Color.gray.opacity(0.1))
                            Spacer()
                            Divider().background(Color.gray.opacity(0.1))
                            Spacer()
                            Divider().background(Color.gray.opacity(0.1))
                        }
                        .frame(height: 80)
                        .padding(.bottom, 16)
                        
                        // СТОЛБЦЫ
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .bottom, spacing: 12) {
                                // ✅ ИСПРАВЛЕНИЕ: stats.sessions теперь массив структур PauseSession
                                ForEach(Array(stats.sessions.enumerated()), id: \.offset) { index, session in
                                    VStack(spacing: 4) {
                                        // Столбик
                                        ZStack(alignment: .bottom) {
                                            // Фон столбика
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.05))
                                                .frame(width: 16, height: 80)
                                            
                                            // Заполненный столбик
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(theme.accentColor)
                                            // ✅ Берем .durationMinutes из структуры сессии
                                                .frame(width: 16, height: heightForBar(minutes: session.durationMinutes, maxHeight: 80))
                                        }
                                        
                                        // Ось X (Номер паузы)
                                        Text("\(index + 1)")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }
    
    // Хелпер для расчета высоты
    func heightForBar(minutes: Int, maxHeight: CGFloat) -> CGFloat {
        let maxMinutes: CGFloat = 60
        // Если минут больше 60, обрезаем график, но лучше чтобы не вылезало
        let normalizedMinutes = min(CGFloat(minutes), maxMinutes)
        let height = (normalizedMinutes / maxMinutes) * maxHeight
        // Минимальная высота 4px, чтобы столбик было видно, даже если 1 минута
        return max(4, height)
    }
    
    func heightForBar(minutes: Int) -> CGFloat {
        let maxBarHeight: CGFloat = 80
        let maxMinutes: CGFloat = 60
        let height = (CGFloat(minutes) / maxMinutes) * maxBarHeight
        return max(10, min(height, maxBarHeight))
    }
    
    func dateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
}
