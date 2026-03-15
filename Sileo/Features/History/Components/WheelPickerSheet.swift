import SwiftUI

struct WheelPickerSheet: View {
    @Binding var currentMonth: Date
    @Environment(\.dismiss) var dismiss
    
    private let calendar = Calendar.current
    let theme: AppTheme

    @State private var selectedMonth: Int
    @State private var selectedYear: Int

    init(currentMonth: Binding<Date>, theme: AppTheme) {
        self._currentMonth = currentMonth
        self.theme = theme
        
        let initialMonth = Calendar.current.component(.month, from: currentMonth.wrappedValue)
        let initialYear = Calendar.current.component(.year, from: currentMonth.wrappedValue)
        
        self._selectedMonth = State(initialValue: initialMonth)
        self._selectedYear = State(initialValue: initialYear)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Month")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(theme.textColor)
                .padding(.top, 25)
            
            HStack(spacing: 0) {
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(calendar.monthSymbols[month - 1].capitalized).tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                Picker("Year", selection: $selectedYear) {
                    let currentYear = calendar.component(.year, from: HistoryManager.shared.currentDate)
                    ForEach((currentYear - 5)...currentYear, id: \.self) { year in
                        Text(String(format: "%d", year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            Button(action: {
                applyDate()
                dismiss()
            }) {
                Text("Done")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.accentColor)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationDetents([.height(350)])
        .presentationDragIndicator(.visible)

        .onChange(of: selectedMonth) { _, _ in validateDate() }
        .onChange(of: selectedYear) { _, _ in validateDate() }
    }
    
    private func applyDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        
        if let newDate = calendar.date(from: components) {
            currentMonth = newDate
        }
    }
    
    private func validateDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        
        if let newDate = calendar.date(from: components), newDate > HistoryManager.shared.currentDate {
            selectedMonth = calendar.component(.month, from: HistoryManager.shared.currentDate)
            selectedYear = calendar.component(.year, from: HistoryManager.shared.currentDate)
        }
    }
}
