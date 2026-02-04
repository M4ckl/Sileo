import SwiftUI

struct BezelView: View {
    @State private var rotation: Double = 0
    @Binding var minutes: Int
    
    var size: CGFloat
    let theme: AppTheme
    var isSleepMode: Bool = false
    var onDragStart: () -> Void
    var onDragEnd: () -> Void
    
    var body: some View {
        ZStack {
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
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                snapToMinute()
                            }
                        }
                )
            
            
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 6)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 5, y: 5)
                
                Circle()
                    .stroke(theme.accentColor.opacity(0.1), lineWidth: 6)
                    .blur(radius: 4)
                    .offset(x: 2, y: 2)
                    .mask(
                        Circle()
                            .stroke(Color.black, lineWidth: 6)
                    )
            }
            .frame(width: size, height: size)
            .opacity(isSleepMode ? 0.2 : 1.0)
            
            
            ZStack {
                Circle()
                    .fill(theme.accentColor.opacity(isSleepMode ? 0.8 : 0.6))
                
                Circle()
                    .fill(Color.white)
                    .opacity(isSleepMode ? 0.4 : 1.0)
                    .frame(width: 24, height: 24)
                
            }
            .frame(width: 32, height: 32)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .offset(y: -size / 2)
            .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            syncRotationWithMinutes()
        }
        .onChange(of: minutes, initial: false) { oldValue, newValue in
            if newValue == 0 {
                withAnimation(.spring()) { rotation = 0 }
            }
        }
    }
    
    private func handleDrag(value: DragGesture.Value) {
        onDragStart()
        
        let vector = CGVector(dx: value.location.x - (size / 2 + 20), dy: value.location.y - (size / 2 + 20))
        let angle = atan2(vector.dy, vector.dx) * 180 / .pi + 90
        var fixedAngle = angle
        if fixedAngle < 0 { fixedAngle += 360 }
        
        self.rotation = fixedAngle
        
        let progress = fixedAngle / 360
        let newMinutes = Int((progress * 60).rounded())
        
        let clampedMinutes = min(60, max(0, newMinutes))
        
        if clampedMinutes != minutes {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.5)
            minutes = clampedMinutes
        }
    }
    
    private func snapToMinute() {
        let minuteAngle = Double(minutes) / 60.0 * 360.0
        rotation = minuteAngle
    }
    
    private func syncRotationWithMinutes() {
        rotation = Double(minutes) / 60.0 * 360.0
    }
}
