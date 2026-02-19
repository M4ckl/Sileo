import SwiftUI

struct ParticleBackgroundView: View {
    let color: Color
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: CGFloat
        var sway: CGFloat
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(color)
                        .frame(width: particle.size, height: particle.size)
                        .opacity(particle.opacity * max(0, (1.0 - Double(particle.y / (geo.size.height * 0.5)))))
                        .position(x: particle.x + sin(particle.y / 30) * particle.sway, y: particle.y)
                }
            }
            .onAppear {
                if particles.isEmpty {
                    createInitialParticles(in: geo.size)
                    startAnimation(in: geo.size)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func createInitialParticles(in size: CGSize) {
        for _ in 100...160 {
            particles.append(newParticle(in: size, isInitial: true))
        }
    }
    
    private func newParticle(in size: CGSize, isInitial: Bool = false) -> Particle {
        Particle(
            x: CGFloat.random(in: 0...size.width),
            y: isInitial ? CGFloat.random(in: 0...size.height * 0.7) : -20,
            size: CGFloat.random(in: 3...7),
            opacity: Double.random(in: 0.3...0.6),
            speed: CGFloat.random(in: 0.5...1.8),
            sway: CGFloat.random(in: 15...40)
        )
    }
    
    private func startAnimation(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            for i in 0..<particles.count {
                particles[i].y += particles[i].speed

                if particles[i].y > size.height * 0.6 {
                    particles[i] = newParticle(in: size, isInitial: false)
                }
            }
        }
    }
}
