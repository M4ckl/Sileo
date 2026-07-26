import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(UserManager.self) var userManager
    
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    @State private var selectedDate: Date = Date()
    
    @State private var currentMonth: Date = {
        let components = Calendar.current.dateComponents([.year, .month], from: HistoryManager.shared.currentDate)
        return Calendar.current.date(from: components)!
    }()
    
    @Namespace private var animation
    @State private var showWheelPicker = false
    @State private var currentStatsPage = 0
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    
    @State private var monthsList: [Date] = []
    
    var stats: DailyData {
        HistoryManager.shared.getData(for: selectedDate)
    }
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 20)
                
                // MARK: - Month Picker
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

                                            Text(monthDate.formatted(.dateTime.month(.wide).year()))
                                                .font(.system(size: 16, weight: isSelected ? .bold : .medium, design: .rounded))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.9)
                                                .fixedSize(horizontal: true, vertical: false)
                                                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                                                .scaleEffect(isSelected ? 1.0 : 0.95)
                                                .padding(.vertical, 12)
                                                .padding(.horizontal, 20)
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
                
                Spacer().frame(height: 12)
                
                // MARK: - Calendar Grid
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
                
                Spacer().frame(height: 14)
                
                Capsule()
                    .fill(theme.textColor.opacity(0.1))
                    .frame(height: 2)
                    .padding(.horizontal, 40)
                
                Spacer().frame(height: 14)
                
                // MARK: - Stats & Graph
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    
                    VStack(spacing: 0) {
                        TabView(selection: $currentStatsPage) {
                            StatsOverviewView(date: selectedDate, stats: stats, theme: theme)
                                .tag(0)
                            
                            SessionsGraphView(stats: stats, theme: theme)
                                .tag(1)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .animation(.easeInOut(duration: 0.3), value: currentStatsPage)
                        
                        // Custom Page Indicator
                        HStack(spacing: 6) {
                            ForEach(0..<2) { index in
                                Capsule()
                                    .fill(currentStatsPage == index ? theme.accentColor : Color.gray.opacity(0.3))
                                    .frame(width: currentStatsPage == index ? 20 : 6, height: 6)
                                    .animation(.spring(), value: currentStatsPage)
                            }
                        }
                        .padding(.bottom, 12)
                    }
                }
                .frame(height: 180)
                .padding(.horizontal, 20)
                .animation(.easeInOut(duration: 0.3), value: selectedDate)
                
                Spacer(minLength: 0)
                
                // MARK: - Header / Back Button
                HStack {
                    Text("HISTORY")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .tracking(2)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                        .glassEffect(.clear)
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
    
    // MARK: - Helper Methods
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
}
