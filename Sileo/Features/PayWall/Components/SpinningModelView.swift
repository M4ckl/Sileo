import SwiftUI
import SceneKit

struct SpinningModelView: UIViewRepresentable {
    
    let modelName: String
    let accentColor: Color

    static let easeOutBack: (Float) -> Float = { t in
        let c1: Float = 1.70158
        let c3: Float = c1 + 1.0
        let tMinus1 = t - 1.0
        return 1.0 + c3 * pow(tMinus1, 3) + c1 * pow(tMinus1, 2)
    }
    
    class Coordinator: NSObject {
        var rotationNode: SCNNode?
        var startPanAngle: Float = 0.0
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let node = rotationNode else { return }
            
            switch gesture.state {
            case .began:
                node.removeAllActions()
                startPanAngle = node.eulerAngles.y
                
            case .changed:
                let translation = gesture.translation(in: gesture.view)
                let deltaAngle = Float(translation.x) * 0.01
                node.eulerAngles.y = startPanAngle + deltaAngle
                
            case .ended, .cancelled:
                let velocity = gesture.velocity(in: gesture.view).x
                let currentAngle = node.eulerAngles.y
                let twoPi = Float.pi * 2
                
                var targetAngle = round(currentAngle / twoPi) * twoPi

                if velocity > 800 { targetAngle += twoPi }
                else if velocity < -800 { targetAngle -= twoPi }
                
                let diff = abs(targetAngle - currentAngle)
                let duration = 0.6 + Double(diff / twoPi) * 0.3
                
                let snapBack = SCNAction.rotateTo(
                    x: 0,
                    y: CGFloat(targetAngle),
                    z: 0,
                    duration: duration,
                    usesShortestUnitArc: false
                )
                
                snapBack.timingFunction = SpinningModelView.easeOutBack
                node.runAction(snapBack)
                
            default:
                break
            }
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = false
        sceneView.clipsToBounds = true
        sceneView.antialiasingMode = .multisampling4X
        
        let scene = SCNScene()
        sceneView.scene = scene

        scene.lightingEnvironment.contents = UIColor(white: 0.85, alpha: 1.0)
        scene.lightingEnvironment.intensity = 1.2

        setupCamera(in: scene, sceneView: sceneView)
        setupLights(in: scene)

        let wrapperNode = SCNNode()
        let rotationNode = SCNNode()
        let modelContainer = SCNNode()
        
        scene.rootNode.addChildNode(wrapperNode)
        wrapperNode.addChildNode(rotationNode)
        rotationNode.addChildNode(modelContainer)
        context.coordinator.rotationNode = rotationNode

        if let loadedScene = SCNScene(named: modelName) {
            for child in loadedScene.rootNode.childNodes {
                modelContainer.addChildNode(child)
            }
        }

        applyPBRMaterials(to: modelContainer)
        centerAndScale(modelContainer: modelContainer)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let initialSpin = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 4.3)
            initialSpin.timingFunction = SpinningModelView.easeOutBack
            rotationNode.runAction(initialSpin)
        }

        let scaleUp = SCNAction.scale(to: 1.1, duration: 2.0)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SCNAction.scale(to: 1.0, duration: 2.0)
        scaleDown.timingMode = .easeInEaseOut
        wrapperNode.runAction(.repeatForever(.sequence([scaleUp, scaleDown])))

        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    // MARK: - Private Setup Helpers
    
    private func setupCamera(in scene: SCNScene, sceneView: SCNView) {
        let camera = SCNCamera()
        camera.fieldOfView = 38
        camera.wantsHDR = true
        camera.exposureOffset = -0.5
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 2.5)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
    }
    
    private func setupLights(in scene: SCNScene) {
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.intensity = 900
        keyLight.temperature = 5500
        keyLight.castsShadow = true
        keyLight.shadowRadius = 8
        keyLight.shadowSampleCount = 16
        
        let keyNode = SCNNode()
        keyNode.light = keyLight
        keyNode.eulerAngles = SCNVector3(-0.8, 0.8, 0)
        scene.rootNode.addChildNode(keyNode)
        
        let fillLight = SCNLight()
        fillLight.type = .directional
        fillLight.intensity = 400
        fillLight.temperature = 6500
        
        let fillNode = SCNNode()
        fillNode.light = fillLight
        fillNode.eulerAngles = SCNVector3(-0.3, -0.8, 0)
        scene.rootNode.addChildNode(fillNode)
        
        let rimLight = SCNLight()
        rimLight.type = .directional
        rimLight.intensity = 600
        rimLight.temperature = 7000
        
        let rimNode = SCNNode()
        rimNode.light = rimLight
        rimNode.eulerAngles = SCNVector3(0.5, .pi, 0)
        scene.rootNode.addChildNode(rimNode)
    }
    
    private func applyPBRMaterials(to modelContainer: SCNNode) {
        let baseUiColor = UIColor(accentColor)
        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0
        baseUiColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)

        let reflectiveTint = UIColor(hue: hue, saturation: min(sat * 1.3, 1.0), brightness: bri * 0.6, alpha: alpha)

        modelContainer.enumerateChildNodes { node, _ in
            guard let geometry = node.geometry else { return }
            for material in geometry.materials {
                material.lightingModel = .physicallyBased
                material.diffuse.contents = baseUiColor
                material.metalness.contents = 0.9
                material.roughness.contents = 0.2
                material.reflective.contents = reflectiveTint
                material.fresnelExponent = 3.0

                material.multiply.contents = nil
                material.shaderModifiers = nil
            }
        }
    }
    
    private func centerAndScale(modelContainer: SCNNode) {
        let (min, max) = modelContainer.boundingBox
        let sizeX = max.x - min.x
        let sizeY = max.y - min.y
        let sizeZ = max.z - min.z
        let maxDimension = Swift.max(sizeX, Swift.max(sizeY, sizeZ))
        
        let centerX = min.x + sizeX / 2
        let centerY = min.y + sizeY / 2
        let centerZ = min.z + sizeZ / 2
        
        modelContainer.pivot = SCNMatrix4MakeTranslation(centerX, centerY, centerZ)
        
        let targetSize: Float = 1.3
        let scale = targetSize / maxDimension
        modelContainer.scale = SCNVector3(scale, scale, scale)
        modelContainer.eulerAngles.y = .pi
    }
}
