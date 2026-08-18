import SwiftUI

struct Vector3 {
    var x, y, z: CGFloat
}

struct MorphParticle {
    var text1Pos: Vector3
    var text2Pos: Vector3
    var spherePos: Vector3
    var randomOffset: CGFloat
}

struct ParticleMorphView: View {
    let particleColor: Color
    
    @State private var particles: [MorphParticle] = []
    @State private var startTime: Date?
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                guard !particles.isEmpty, let start = startTime else { return }
                
                let elapsed = timeline.date.timeIntervalSince(start)
                
                let morph1Progress = min(max((elapsed - 2.5) / 1.5, 0.0), 1.0)
                let ease1 = morph1Progress * morph1Progress * (3.0 - 2.0 * morph1Progress)
                
                let morph2Progress = min(max((elapsed - 6.0) / 1.5, 0.0), 1.0)
                let ease2 = morph2Progress * morph2Progress * (3.0 - 2.0 * morph2Progress)
                
                let rotationSpeed: CGFloat = 0.4
                let angleY = CGFloat(elapsed) * rotationSpeed * ease2
                let angleX = CGFloat(elapsed) * (rotationSpeed * 0.3) * ease2
                
                for p in particles {
                    let currX: CGFloat
                    let currY: CGFloat
                    let currZ: CGFloat
                    
                    if elapsed < 2.5 {
                        currX = p.text1Pos.x; currY = p.text1Pos.y; currZ = p.text1Pos.z
                    } else if elapsed < 4.0 {
                        currX = p.text1Pos.x * (1 - ease1) + p.text2Pos.x * ease1
                        currY = p.text1Pos.y * (1 - ease1) + p.text2Pos.y * ease1
                        currZ = p.text1Pos.z * (1 - ease1) + p.text2Pos.z * ease1
                    } else if elapsed < 6.0 {
                        currX = p.text2Pos.x; currY = p.text2Pos.y; currZ = p.text2Pos.z
                    } else {
                        currX = p.text2Pos.x * (1 - ease2) + p.spherePos.x * ease2
                        currY = p.text2Pos.y * (1 - ease2) + p.spherePos.y * ease2
                        currZ = p.text2Pos.z * (1 - ease2) + p.spherePos.z * ease2
                    }
                    
                    let cosY = cos(angleY); let sinY = sin(angleY)
                    let x1 = currX * cosY - currZ * sinY
                    let z1 = currX * sinY + currZ * cosY
                    
                    let cosX = cos(angleX); let sinX = sin(angleX)
                    let y2 = currY * cosX - z1 * sinX
                    let z2 = currY * sinX + z1 * cosX
                    let x2 = x1
                    
                    let perspective: CGFloat = 800
                    let scale = perspective / (perspective + z2)
                    
                    let screenX = size.width / 2 + x2 * scale
                    let screenY = size.height / 2 + y2 * scale - 40
                    
                    let r = max(1.5 * scale, 0.5)
                    let rect = CGRect(x: screenX - r, y: screenY - r, width: r * 2, height: r * 2)
                    
                    let twinkle = sin(elapsed * 4.0 + p.randomOffset) * 0.4 + 0.6
                    let baseAlpha = 0.4 + (0.6 * ease2)
                    let alpha = Double(scale) * twinkle * Double(baseAlpha)
                    
                    context.opacity = min(max(alpha, 0.05), 1.0)
                    context.fill(Path(ellipseIn: rect), with: .color(particleColor))
                }
            }
        }
        .onAppear {
            if particles.isEmpty { generateParticles() }
        }
    }
    
    private func generateParticles() {
        Task.detached(priority: .userInitiated) {
            let targetCount = 2800
            let canvasSize = CGSize(width: 600, height: 600)
            
            let text1 = "Take\na moment\nwith\nSILEO"
            let style1 = NSMutableParagraphStyle(); style1.alignment = .center; style1.lineSpacing = 6
            let attr1 = NSMutableAttributedString(string: text1, attributes: [.font: UIFont.systemFont(ofSize: 42, weight: .light), .foregroundColor: UIColor.white, .paragraphStyle: style1])
            let sileoRange = (text1 as NSString).range(of: "SILEO")
            attr1.addAttribute(.font, value: UIFont.systemFont(ofSize: 55, weight: .medium), range: sileoRange)
            attr1.addAttribute(.tracking, value: 6.0, range: sileoRange)
            
            let text2 = "Breathe.\nThen decide."
            let style2 = NSMutableParagraphStyle(); style2.alignment = .center; style2.lineSpacing = 8
            let attr2 = NSMutableAttributedString(string: text2, attributes: [.font: UIFont.systemFont(ofSize: 38, weight: .light), .foregroundColor: UIColor.white, .paragraphStyle: style2])
            let pauseRange = (text2 as NSString).range(of: "Breathe.") // Поправил на правильное слово
            attr2.addAttribute(.font, value: UIFont.systemFont(ofSize: 50, weight: .semibold), range: pauseRange)
            attr2.addAttribute(.tracking, value: 1.5, range: pauseRange)
            
            let pts1 = await self.extractPoints(from: attr1, canvasSize: canvasSize, targetCount: targetCount)
            let pts2 = await self.extractPoints(from: attr2, canvasSize: canvasSize, targetCount: targetCount)
            
            var spherePts: [Vector3] = []
            let sphereRadius: CGFloat = 135
            let phi = CGFloat.pi * (3.0 - sqrt(5.0))
            for i in 0..<targetCount {
                let y = 1.0 - (CGFloat(i) / CGFloat(targetCount - 1)) * 2.0
                let r = sqrt(1 - y * y)
                let theta = phi * CGFloat(i)
                let shellRadius = sphereRadius + CGFloat.random(in: -4...4)
                spherePts.append(Vector3(x: cos(theta) * r * shellRadius, y: y * shellRadius, z: sin(theta) * r * shellRadius))
            }
            
            var newParticles: [MorphParticle] = []
            for i in 0..<targetCount {
                newParticles.append(MorphParticle(
                    text1Pos: pts1[i],
                    text2Pos: pts2[i],
                    spherePos: spherePts[i],
                    randomOffset: CGFloat.random(in: 0...10)
                ))
            }
            
            let shuffled = newParticles.shuffled()
            
            await MainActor.run {
                self.particles = shuffled
                self.startTime = Date()
            }
        }
    }
    
    private func extractPoints(from attrStr: NSAttributedString, canvasSize: CGSize, targetCount: Int) -> [Vector3] {
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.preferredRange = .standard
        
        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)
        let image = renderer.image { context in
            let textRect = attrStr.boundingRect(with: canvasSize, options: .usesLineFragmentOrigin, context: nil)
            let drawRect = CGRect(
                x: (canvasSize.width - textRect.width) / 2,
                y: (canvasSize.height - textRect.height) / 2,
                width: textRect.width,
                height: textRect.height
            )
            attrStr.draw(in: drawRect)
        }
        
        guard let cgImage = image.cgImage,
              let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else { return [] }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = cgImage.bytesPerRow
        var allPoints: [Vector3] = []
        
        var maxX: CGFloat = 1.0
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = y * bytesPerRow + x * 4
                
                if bytes[offset] > 50 || bytes[offset+1] > 50 || bytes[offset+2] > 50 || bytes[offset+3] > 50 {
                    let px = CGFloat(x) - CGFloat(width)/2
                    let py = CGFloat(y) - CGFloat(height)/2
                    
                    if abs(px) > maxX { maxX = abs(px) }
                    
                    allPoints.append(Vector3(x: px, y: py, z: 0))
                }
            }
        }
        
        if allPoints.isEmpty { return [] }
        
        let safeHalfWidth: CGFloat = 140.0
        let scaleFactor = maxX > safeHalfWidth ? (safeHalfWidth / maxX) : 1.0
        
        allPoints = allPoints.map { Vector3(x: $0.x * scaleFactor, y: $0.y * scaleFactor, z: $0.z) }
        allPoints.shuffle()
        
        var result: [Vector3] = []
        var index = 0
        while result.count < targetCount {
            result.append(allPoints[index % allPoints.count])
            index += 1
        }
        return result
    }
}
