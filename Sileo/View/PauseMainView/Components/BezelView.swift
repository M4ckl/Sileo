import SwiftUI

struct BezelView: View {
    // Двусторонняя связь: мы читаем минуты и можем их менять
    @Binding var minutes: Int
    // Размер самого кольца
    var size: CGFloat
    let theme: AppTheme
    
    // Колбеки для анимаций интерфейса (скрыть/показать старт)
    var onDragStart: () -> Void
    var onDragEnd: () -> Void
    
    // Внутреннее состояние угла вращения (для визуальной плавности)
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // 1. Невидимое сенсорное кольцо (чтобы легче было попасть пальцем)
            Circle()
                .stroke(Color.white.opacity(0.001), lineWidth: 40)
                .frame(width: size, height: size)
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            handleDrag(value: value)
                        }
                        .onEnded { _ in
                            onDragEnd()
                            // Примагничивание к минуте при отпускании
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                snapToMinute()
                            }
                        }
                )
            
            
            ZStack {
                // СЛОЙ А: Основное белое тело кольца
                Circle()
                    .stroke(Color.white, lineWidth: 6)
                // Твоя внешняя тень (Drop Shadow) — создает объем над фоном
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 5, y: 5)
                
                // СЛОЙ Б: Внутренняя тень (Inner Shadow)
                // Создает эффект "желобка" внутри линии
                Circle()
                    .stroke(theme.accentColor.opacity(0.1), lineWidth: 6) // Цвет внутренней тени
                    .blur(radius: 4) // Мягкость тени
                    .offset(x: 2, y: 2) // Направление тени (внутрь-вниз)
                    .mask(
                        // Маска обрезает тень, чтобы она была видна ТОЛЬКО на самом кольце
                        Circle()
                            .stroke(Color.black, lineWidth: 6)
                    )
            }
            .frame(width: size, height: size)
            
            
            ZStack {
                // Внешний синий круг
                Circle()
                    .fill(theme.accentColor.opacity(0.6))
                
                // Внутренний белый круг (меньшего размера)
                Circle()
                    .fill(Color.white).opacity(0.8)
                    .frame(width: 24, height: 24) // Размер внутренней точки можно менять здесь
                
            }
            // Все общие модификаторы применяем к ZStack целиком
            .frame(width: 32, height: 32) // Общий размер бегунка
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .offset(y: -size / 2) // Ставим на 12 часов (верх)
            .rotationEffect(.degrees(rotation)) // Вращаем всю конструкцию
        }
        // При появлении синхронизируем позицию бегунка с минутами (00:00 -> 0 градусов)
        .onAppear {
            syncRotationWithMinutes()
        }
        // Если минуты сбросились извне (например, кнопка ресет)
        .onChange(of: minutes, initial: false) { oldValue, newValue in
            if newValue == 0 {
                withAnimation(.spring()) { rotation = 0 }
            }
        }
    }
    
    // --- Математика Жеста ---
    
    private func handleDrag(value: DragGesture.Value) {
        onDragStart()
        
        // Вектор от центра view (которое 0,0 в .local space) к пальцу
        // Поскольку ZStack центрирован, центр это width/2, height/2.
        // Но проще считать вектор от центра координат.
        let vector = CGVector(dx: value.location.x - (size / 2 + 20), dy: value.location.y - (size / 2 + 20))
        
        // Магия atan2: вычисляет угол вектора
        // +90 градусов нужно, чтобы 0 был на 12 часах, а не на 3 часах
        let angle = atan2(vector.dy, vector.dx) * 180 / .pi + 90
        
        // Нормализация (чтобы не было отрицательных углов)
        var fixedAngle = angle
        if fixedAngle < 0 { fixedAngle += 360 }
        
        // Обновляем визуал (плавно)
        self.rotation = fixedAngle
        
        // Обновляем данные (минуты)
        let progress = fixedAngle / 360
        let newMinutes = Int((progress * 60).rounded())
        
        // Ограничиваем от 0 до 60
        let clampedMinutes = min(60, max(0, newMinutes))
        
        if clampedMinutes != minutes {
            // Легкая вибрация при смене минуты
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.5)
            minutes = clampedMinutes
        }
    }
    
    private func snapToMinute() {
        // Округляем угол до ближайшей минуты, чтобы бегунок встал ровно
        let minuteAngle = Double(minutes) / 60.0 * 360.0
        rotation = minuteAngle
    }
    
    private func syncRotationWithMinutes() {
        rotation = Double(minutes) / 60.0 * 360.0
    }
}
