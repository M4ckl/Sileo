import SwiftUI

struct MonthCarouselView: View {
    @Binding var currentMonth: Date
    let monthsList: [Date]
    let theme: AppTheme
    let onLongPress: () -> Void
    
    @Namespace private var animation
    private let calendar = Calendar.current
    
    var body: some View {
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
                                
                                monthCell(for: monthDate, isSelected: isSelected)
                                    .id(monthDate)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            currentMonth = monthDate
                                        }
                                    }
                                    .onLongPressGesture(minimumDuration: 1.0) {
                                        if isSelected {
                                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                            onLongPress()
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
    }
    
    @ViewBuilder
    private func monthCell(for date: Date, isSelected: Bool) -> some View {
        ZStack {
            if isSelected {
                Capsule()
                    .frame(height: 40)
                    .glassEffect(.clear.interactive())
                    .matchedGeometryEffect(id: "activeTab", in: animation)
            }

            Text(date.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 16, weight: isSelected ? .bold : .medium, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .scaleEffect(isSelected ? 1.0 : 0.95)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
        }
    }
}
