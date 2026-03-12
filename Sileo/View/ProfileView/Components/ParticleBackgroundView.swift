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
        var seed: Double
    }
    
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    for particle in particles {
                        let rect = CGRect(
                            x: particle.x + sin(particle.y / 30 + particle.seed) * particle.sway,
                            y: particle.y,
                            width: particle.size,
                            height: particle.size
                        )

                        let fadeOut = max(0, 1.0 - Double(particle.y / (size.height * 0.5)))
                        let finalOpacity = particle.opacity * fadeOut
                        
                        context.opacity = finalOpacity
                        context.fill(Path(ellipseIn: rect), with: .color(color))
                    }
                }
                .onChange(of: timeline.date) {
                    updateParticles(in: geo.size)
                }
            }
            .onAppear {
                if particles.isEmpty {
                    createInitialParticles(in: geo.size)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func createInitialParticles(in size: CGSize) {
        for _ in 0...90 {
            particles.append(newParticle(in: size, isInitial: true))
        }
    }
    
    private func newParticle(in size: CGSize, isInitial: Bool = false) -> Particle {
        Particle(
            x: CGFloat.random(in: 0...size.width),
            y: isInitial ? CGFloat.random(in: 0...size.height * 0.8) : -20,
            size: CGFloat.random(in: 3...6),
            opacity: Double.random(in: 0.3...0.6),
            speed: CGFloat.random(in: 0.7...1.5),
            sway: CGFloat.random(in: 10...30),
            seed: Double.random(in: 0...100)
        )
    }
    
    private func updateParticles(in size: CGSize) {
        for i in 0..<particles.count {
            particles[i].y += particles[i].speed
            if particles[i].y > size.height * 0.6 {
                particles[i] = newParticle(in: size, isInitial: false)
            }
        }
    }
}

