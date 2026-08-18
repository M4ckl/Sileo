import SwiftUI

struct TimeInfoView: View {
    let engine: PauseViewModel
    let color: Color
    let shouldShowStartButton: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if engine.state != .finished {
                Text(engine.state == .idle ? String(format: "%02d:00", engine.selectedMinutes) : timeString(time: engine.remainingSeconds))
                    .font(.system(size: 54, weight: .light, design: .rounded))
                    .foregroundColor(color)
                    .contentTransition(.numericText())
                    .offset(y: shouldShowStartButton ? -15 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: shouldShowStartButton)
                
                if shouldShowStartButton {
                    Text("START")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(color)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .padding(.top, 4)
                }
                
                if engine.state == .paused {
                    Text("PAUSED")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.2))
                        .clipShape(Capsule())
                        .padding(.top, 5)
                }
            }
        }
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
