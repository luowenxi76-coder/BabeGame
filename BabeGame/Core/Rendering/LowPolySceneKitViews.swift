import SceneKit
import SwiftUI
import UIKit

enum HomeInteractionTarget {
    case cat
    case bowl
    case toy
}

struct LowPolyCatPreview3DView: UIViewRepresentable {
    let appearance: CatAppearance
    let outfit: OutfitDefinition?
    let accessory: AccessoryDefinition?

    func makeCoordinator() -> PreviewCoordinator {
        PreviewCoordinator()
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.scene = context.coordinator.scene
        view.antialiasingMode = .multisampling4X
        view.autoenablesDefaultLighting = false
        view.allowsCameraControl = false
        view.isPlaying = true
        context.coordinator.configureScene()
        context.coordinator.update(appearance: appearance, outfit: outfit, accessory: accessory)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.update(appearance: appearance, outfit: outfit, accessory: accessory)
    }

    final class PreviewCoordinator {
        let scene = SCNScene()
        private let stageNode = SCNNode()

        func configureScene() {
            scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }

            let target = SCNNode()
            target.position = SCNVector3(0, 0.6, 0)
            scene.rootNode.addChildNode(target)

            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.fieldOfView = 32
            cameraNode.camera?.wantsHDR = true
            cameraNode.camera?.zFar = 40
            cameraNode.position = SCNVector3(0.1, 1.65, 6.2)
            let constraint = SCNLookAtConstraint(target: target)
            constraint.isGimbalLockEnabled = true
            cameraNode.constraints = [constraint]
            scene.rootNode.addChildNode(cameraNode)

            let keyLight = SCNNode()
            keyLight.light = SCNLight()
            keyLight.light?.type = .directional
            keyLight.light?.intensity = 1350
            keyLight.light?.color = UIColor(red: 1.0, green: 0.96, blue: 0.92, alpha: 1)
            keyLight.light?.castsShadow = true
            keyLight.light?.shadowRadius = 8
            keyLight.light?.shadowMode = .deferred
            keyLight.eulerAngles = SCNVector3(-0.95, 0.7, 0)
            scene.rootNode.addChildNode(keyLight)

            let fillLight = SCNNode()
            fillLight.light = SCNLight()
            fillLight.light?.type = .omni
            fillLight.light?.intensity = 540
            fillLight.light?.color = UIColor(red: 0.93, green: 0.95, blue: 1.0, alpha: 1)
            fillLight.position = SCNVector3(-2.0, 2.2, 3.8)
            scene.rootNode.addChildNode(fillLight)

            let ambient = SCNNode()
            ambient.light = SCNLight()
            ambient.light?.type = .ambient
            ambient.light?.intensity = 240
            ambient.light?.color = UIColor(red: 0.86, green: 0.84, blue: 0.86, alpha: 1)
            scene.rootNode.addChildNode(ambient)

            let floor = SCNNode(geometry: SCNCylinder(radius: 2.5, height: 0.18))
            floor.geometry?.firstMaterial = LowPolySceneFactory.softMaterial(CoordinatePalette.stageTop)
            floor.position = SCNVector3(0, -1.08, 0)
            scene.rootNode.addChildNode(floor)

            let plinth = SCNNode(geometry: SCNCylinder(radius: 2.05, height: 0.06))
            plinth.geometry?.firstMaterial = LowPolySceneFactory.softMaterial(CoordinatePalette.stageShadow)
            plinth.position = SCNVector3(0, -0.98, 0)
            scene.rootNode.addChildNode(plinth)

            let shadowFloor = SCNNode(geometry: SCNFloor())
            shadowFloor.geometry?.firstMaterial = LowPolySceneFactory.shadowReceiverMaterial()
            shadowFloor.position = SCNVector3(0, -1.12, 0)
            scene.rootNode.addChildNode(shadowFloor)

            stageNode.runAction(
                .repeatForever(
                    .sequence([
                        .rotateTo(x: 0, y: 0.16, z: 0, duration: 3.8),
                        .rotateTo(x: 0, y: -0.16, z: 0, duration: 3.8)
                    ])
                )
            )
            scene.rootNode.addChildNode(stageNode)
        }

        func update(appearance: CatAppearance, outfit: OutfitDefinition?, accessory: AccessoryDefinition?) {
            stageNode.childNodes.forEach { $0.removeFromParentNode() }
            let cat = LowPolySceneFactory.makeCatNode(
                appearance: appearance,
                outfit: outfit,
                accessory: accessory,
                mood: .relaxed,
                name: nil
            )
            cat.position = SCNVector3(0, -0.46, 0)
            stageNode.addChildNode(cat)
        }
    }
}

struct InteractiveHomeScene3DView: UIViewRepresentable {
    let cat: CatProfile
    let onTapTarget: (HomeInteractionTarget) -> Void

    func makeCoordinator() -> HomeCoordinator {
        HomeCoordinator(onTapTarget: onTapTarget)
    }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.scene = context.coordinator.scene
        view.antialiasingMode = .multisampling4X
        view.autoenablesDefaultLighting = false
        view.allowsCameraControl = false
        view.isPlaying = true

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(HomeCoordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

        context.coordinator.view = view
        context.coordinator.configureScene()
        context.coordinator.update(cat: cat)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.onTapTarget = onTapTarget
        context.coordinator.update(cat: cat)
    }

    final class HomeCoordinator: NSObject {
        let scene = SCNScene()
        weak var view: SCNView?
        var onTapTarget: (HomeInteractionTarget) -> Void

        private let dynamicRoot = SCNNode()

        init(onTapTarget: @escaping (HomeInteractionTarget) -> Void) {
            self.onTapTarget = onTapTarget
        }

        func configureScene() {
            scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }

            let target = SCNNode()
            target.position = SCNVector3(0.1, 0.2, 0.2)
            scene.rootNode.addChildNode(target)

            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.fieldOfView = 41
            cameraNode.camera?.wantsHDR = true
            cameraNode.camera?.zFar = 60
            cameraNode.position = SCNVector3(0.3, 2.6, 7.8)
            let constraint = SCNLookAtConstraint(target: target)
            constraint.isGimbalLockEnabled = true
            cameraNode.constraints = [constraint]
            scene.rootNode.addChildNode(cameraNode)

            let keyLight = SCNNode()
            keyLight.light = SCNLight()
            keyLight.light?.type = .directional
            keyLight.light?.intensity = 1480
            keyLight.light?.color = UIColor(red: 1.0, green: 0.95, blue: 0.90, alpha: 1)
            keyLight.light?.castsShadow = true
            keyLight.light?.shadowRadius = 10
            keyLight.light?.shadowMode = .deferred
            keyLight.eulerAngles = SCNVector3(-0.9, 0.95, 0)
            scene.rootNode.addChildNode(keyLight)

            let fillLight = SCNNode()
            fillLight.light = SCNLight()
            fillLight.light?.type = .omni
            fillLight.light?.intensity = 540
            fillLight.light?.color = UIColor(red: 0.90, green: 0.94, blue: 1.0, alpha: 1)
            fillLight.position = SCNVector3(-3.8, 2.4, 4.6)
            scene.rootNode.addChildNode(fillLight)

            let ambient = SCNNode()
            ambient.light = SCNLight()
            ambient.light?.type = .ambient
            ambient.light?.intensity = 220
            ambient.light?.color = UIColor(red: 0.84, green: 0.82, blue: 0.84, alpha: 1)
            scene.rootNode.addChildNode(ambient)

            scene.rootNode.addChildNode(dynamicRoot)
        }

        func update(cat: CatProfile) {
            dynamicRoot.childNodes.forEach { $0.removeFromParentNode() }
            dynamicRoot.addChildNode(LowPolySceneFactory.makeHomeRoomNode(cat: cat))
        }

        @MainActor
        @objc
        func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view else { return }
            let point = gesture.location(in: view)
            let results = view.hitTest(point, options: nil)
            guard let hit = results.first else { return }

            var currentNode: SCNNode? = hit.node
            while let node = currentNode {
                switch node.name {
                case "cat-interaction":
                    animateBounce(node, amount: 0.12)
                    onTapTarget(.cat)
                    return
                case "bowl-interaction":
                    animateWiggle(node)
                    onTapTarget(.bowl)
                    return
                case "toy-interaction":
                    animateBounce(node, amount: 0.08)
                    onTapTarget(.toy)
                    return
                default:
                    currentNode = node.parent
                }
            }
        }

        private func animateBounce(_ node: SCNNode, amount: CGFloat) {
            node.removeAction(forKey: "bounce")
            let up = SCNAction.moveBy(x: 0, y: amount, z: 0, duration: 0.13)
            up.timingMode = .easeOut
            let down = SCNAction.moveBy(x: 0, y: -amount, z: 0, duration: 0.18)
            down.timingMode = .easeInEaseOut
            node.runAction(.sequence([up, down]), forKey: "bounce")
        }

        private func animateWiggle(_ node: SCNNode) {
            node.removeAction(forKey: "wiggle")
            let left = SCNAction.rotateBy(x: 0, y: 0, z: 0.12, duration: 0.08)
            let right = SCNAction.rotateBy(x: 0, y: 0, z: -0.24, duration: 0.16)
            let reset = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.08)
            node.runAction(.sequence([left, right, reset]), forKey: "wiggle")
        }
    }
}

private enum CoordinatePalette {
    static let stageTop = UIColor(red: 0.98, green: 0.92, blue: 0.82, alpha: 1)
    static let stageShadow = UIColor(red: 0.96, green: 0.88, blue: 0.74, alpha: 1)
    static let roomFloor = UIColor(red: 0.95, green: 0.87, blue: 0.76, alpha: 1)
    static let roomTrim = UIColor(red: 0.88, green: 0.75, blue: 0.60, alpha: 1)
    static let cozyShadow = UIColor(red: 0.78, green: 0.67, blue: 0.54, alpha: 1)
    static let paper = UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1)
    static let blush = UIColor(red: 0.95, green: 0.71, blue: 0.66, alpha: 1)
    static let nose = UIColor(red: 0.84, green: 0.54, blue: 0.48, alpha: 1)
    static let charcoal = UIColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1)
}

private enum LowPolySceneFactory {
    static func makeHomeRoomNode(cat: CatProfile) -> SCNNode {
        let root = SCNNode()

        let wallpaper = wallpaperColor(cat.homeState.wallpaper)
        let wallpaperShade = wallpaperSecondaryColor(cat.homeState.wallpaper)

        let floor = SCNNode(geometry: SCNBox(width: 8.6, height: 0.18, length: 6.3, chamferRadius: 0.08))
        floor.geometry?.firstMaterial = softMaterial(CoordinatePalette.roomFloor)
        floor.position = SCNVector3(0, -1.2, 0)
        root.addChildNode(floor)

        let floorShadow = SCNNode(geometry: SCNFloor())
        floorShadow.geometry?.firstMaterial = shadowReceiverMaterial()
        floorShadow.position = SCNVector3(0, -1.11, 0)
        root.addChildNode(floorShadow)

        let backWall = SCNNode(geometry: SCNBox(width: 8.5, height: 4.7, length: 0.14, chamferRadius: 0.04))
        backWall.geometry?.firstMaterial = softMaterial(wallpaper)
        backWall.position = SCNVector3(0, 1.06, -2.88)
        root.addChildNode(backWall)

        let sideWall = SCNNode(geometry: SCNBox(width: 0.14, height: 4.7, length: 6.2, chamferRadius: 0.04))
        sideWall.geometry?.firstMaterial = softMaterial(wallpaperShade)
        sideWall.position = SCNVector3(-4.25, 1.06, 0)
        root.addChildNode(sideWall)

        let baseboard = SCNNode(geometry: SCNBox(width: 8.55, height: 0.2, length: 0.14, chamferRadius: 0.02))
        baseboard.geometry?.firstMaterial = softMaterial(CoordinatePalette.roomTrim)
        baseboard.position = SCNVector3(0, -1.02, -2.82)
        root.addChildNode(baseboard)

        let sideTrim = SCNNode(geometry: SCNBox(width: 0.14, height: 0.2, length: 6.16, chamferRadius: 0.02))
        sideTrim.geometry?.firstMaterial = softMaterial(CoordinatePalette.roomTrim)
        sideTrim.position = SCNVector3(-4.18, -1.02, 0)
        root.addChildNode(sideTrim)

        let window = makeWindowNode(colorKey: GameContent.furniture(id: cat.homeState.placements[HomeSlot.window.rawValue])?.accentKey ?? "sky")
        window.position = SCNVector3(2.5, 0.95, -2.8)
        root.addChildNode(window)

        let art = makeWallDecorNode(colorKey: GameContent.furniture(id: cat.homeState.placements[HomeSlot.wall.rawValue])?.accentKey ?? "peach")
        art.position = SCNVector3(-2.25, 1.2, -2.81)
        root.addChildNode(art)

        let rug = makeRugNode(colorKey: GameContent.furniture(id: cat.homeState.placements[HomeSlot.rug.rawValue])?.accentKey ?? "pearl")
        rug.position = SCNVector3(0.35, -1.08, 0.38)
        root.addChildNode(rug)

        let bed = makeBedNode(colorKey: GameContent.furniture(id: cat.homeState.placements[HomeSlot.bed.rawValue])?.accentKey ?? "butter")
        bed.position = SCNVector3(-2.85, -0.98, 0.95)
        root.addChildNode(bed)

        let plant = makePlantNode()
        plant.position = SCNVector3(3.42, -0.96, -1.65)
        root.addChildNode(plant)

        let bowl = makeFoodBowlNode()
        bowl.name = "bowl-interaction"
        bowl.position = SCNVector3(1.86, -0.98, 1.55)
        root.addChildNode(bowl)

        let toy = makeToyNode()
        toy.name = "toy-interaction"
        toy.position = SCNVector3(2.55, -0.98, 0.68)
        root.addChildNode(toy)

        let catNode = makeCatNode(
            appearance: cat.appearance,
            outfit: GameContent.outfit(id: cat.wardrobeState.equippedOutfitID),
            accessory: GameContent.accessory(id: cat.activeAccessoryID),
            mood: cat.mood,
            name: "cat-interaction"
        )
        catNode.position = SCNVector3(-0.18, -0.22, 0.38)
        root.addChildNode(catNode)

        return root
    }

    static func makeCatNode(
        appearance: CatAppearance,
        outfit: OutfitDefinition?,
        accessory: AccessoryDefinition?,
        mood: MoodPreset,
        name: String?
    ) -> SCNNode {
        let catRoot = SCNNode()
        catRoot.name = name

        let bodyScale: CGFloat = switch appearance.bodyType {
        case .tiny: 0.9
        case .balanced: 1.0
        case .chonky: 1.15
        }

        let furMain = furColor(appearance.primaryFur)
        let furAlt = furColor(appearance.secondaryFur)
        let accessoryColor = accessory.map { accentColor($0.accentKey) }

        let bodyPivot = SCNNode()
        bodyPivot.name = name
        catRoot.addChildNode(bodyPivot)

        let backBody = facetSphere(radius: 0.74 * bodyScale, color: furMain)
        backBody.scale = SCNVector3(1.22, 0.94, 1.22)
        backBody.position = SCNVector3(0, 0.02, -0.05)
        bodyPivot.addChildNode(backBody)

        let chest = facetSphere(radius: 0.54 * bodyScale, color: furMain)
        chest.scale = SCNVector3(1.0, 1.08, 0.94)
        chest.position = SCNVector3(0, 0.30, 0.46)
        bodyPivot.addChildNode(chest)

        let belly = facetSphere(radius: 0.44 * bodyScale, color: furMain)
        belly.scale = SCNVector3(1.06, 0.86, 0.84)
        belly.position = SCNVector3(0, -0.18, 0.38)
        bodyPivot.addChildNode(belly)

        let headPivot = SCNNode()
        headPivot.position = SCNVector3(0.02, 0.92, 0.62)
        headPivot.scale = SCNVector3(appearance.headScale, appearance.headScale, appearance.headScale)
        bodyPivot.addChildNode(headPivot)

        let head = facetSphere(radius: 0.62, color: furMain)
        head.scale = SCNVector3(1.02, 0.92, 0.98)
        headPivot.addChildNode(head)

        let cheekLeft = facetSphere(radius: 0.18, color: furMain)
        cheekLeft.position = SCNVector3(-0.24, -0.16, 0.42)
        cheekLeft.scale = SCNVector3(1.0, 0.78, 0.88)
        headPivot.addChildNode(cheekLeft)

        let cheekRight = facetSphere(radius: 0.18, color: furMain)
        cheekRight.position = SCNVector3(0.24, -0.16, 0.42)
        cheekRight.scale = SCNVector3(1.0, 0.78, 0.88)
        headPivot.addChildNode(cheekRight)

        let muzzle = facetSphere(radius: 0.21, color: CoordinatePalette.paper)
        muzzle.scale = SCNVector3(1.35, 0.8, 0.9)
        muzzle.position = SCNVector3(0, -0.18, 0.5)
        headPivot.addChildNode(muzzle)

        let nose = facetPyramid(width: 0.12, height: 0.10, length: 0.08, color: CoordinatePalette.nose)
        nose.position = SCNVector3(0, -0.13, 0.68)
        nose.eulerAngles = SCNVector3(Float.pi, 0, 0)
        headPivot.addChildNode(nose)

        let mouthLeft = facetCapsule(radius: 0.022, height: 0.16, color: CoordinatePalette.charcoal)
        mouthLeft.position = SCNVector3(-0.06, -0.23, 0.66)
        mouthLeft.eulerAngles = SCNVector3(0.04, 0, 0.92)
        headPivot.addChildNode(mouthLeft)

        let mouthRight = facetCapsule(radius: 0.022, height: 0.16, color: CoordinatePalette.charcoal)
        mouthRight.position = SCNVector3(0.06, -0.23, 0.66)
        mouthRight.eulerAngles = SCNVector3(0.04, 0, -0.92)
        headPivot.addChildNode(mouthRight)

        let eyeX = CGFloat(0.18 * appearance.eyeSpacing)
        let eyeY: CGFloat = 0.02
        let eyeZ: CGFloat = 0.55
        headPivot.addChildNode(makeEyeNode(color: eyeColor(appearance.eyeColor), x: -eyeX, y: eyeY, z: eyeZ))
        headPivot.addChildNode(makeEyeNode(color: eyeColor(appearance.eyeColor), x: eyeX, y: eyeY, z: eyeZ))

        let earHeight: CGFloat = switch appearance.earShape {
        case .round: 0.34
        case .pointy: 0.52
        case .fluffy: 0.44
        }
        let earWidth: CGFloat = switch appearance.earShape {
        case .round: 0.28
        case .pointy: 0.24
        case .fluffy: 0.34
        }
        let earDepth: CGFloat = switch appearance.earShape {
        case .round: 0.24
        case .pointy: 0.18
        case .fluffy: 0.26
        }

        let earLeft = makeEarNode(
            outerColor: furMain,
            innerColor: CoordinatePalette.blush.withAlphaComponent(0.82),
            width: earWidth * appearance.earScale,
            height: earHeight * appearance.earScale,
            depth: earDepth * appearance.earScale,
            mirrored: false
        )
        earLeft.position = SCNVector3(-0.34, 0.5, 0.03)
        headPivot.addChildNode(earLeft)

        let earRight = makeEarNode(
            outerColor: furMain,
            innerColor: CoordinatePalette.blush.withAlphaComponent(0.82),
            width: earWidth * appearance.earScale,
            height: earHeight * appearance.earScale,
            depth: earDepth * appearance.earScale,
            mirrored: true
        )
        earRight.position = SCNVector3(0.34, 0.5, 0.03)
        headPivot.addChildNode(earRight)

        makePatternNodes(for: appearance, mainColor: furMain, altColor: furAlt).forEach { bodyPivot.addChildNode($0) }

        makeLegNodes(pattern: appearance.pattern, furMain: furMain).forEach { bodyPivot.addChildNode($0) }

        let tailPivot = SCNNode()
        tailPivot.name = "tail-pivot"
        tailPivot.position = SCNVector3(-0.66 * bodyScale, 0.15, -0.52)
        bodyPivot.addChildNode(tailPivot)
        tailPivot.addChildNode(makeTailNode(shape: appearance.tailShape, primary: furMain, secondary: furAlt, lengthScale: appearance.tailLength))

        if let accessoryColor {
            let collar = SCNNode(geometry: SCNTorus(ringRadius: 0.32 * appearance.headScale, pipeRadius: 0.055))
            collar.geometry?.firstMaterial = softMaterial(accessoryColor)
            collar.position = SCNVector3(0, 0.57, 0.42)
            collar.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
            bodyPivot.addChildNode(collar)

            let bell = facetSphere(radius: 0.07, color: accessoryColor)
            bell.position = SCNVector3(0, 0.46, 0.72)
            bodyPivot.addChildNode(bell)
        }

        if let outfit {
            let cape = facetSphere(radius: 0.46, color: accentColor(outfit.accentKey))
            cape.scale = SCNVector3(1.48, 0.56, 1.08)
            cape.position = SCNVector3(0, 0.34, 0.08)
            bodyPivot.addChildNode(cape)
        }

        applyMoodPose(to: catRoot, mood: mood)
        return catRoot
    }

    private static func makeEyeNode(color: UIColor, x: CGFloat, y: CGFloat, z: CGFloat) -> SCNNode {
        let root = SCNNode()

        let sclera = facetSphere(radius: 0.10, color: CoordinatePalette.paper)
        sclera.scale = SCNVector3(1.15, 0.82, 0.36)
        sclera.position = SCNVector3(x, y, z)
        root.addChildNode(sclera)

        let iris = facetSphere(radius: 0.06, color: color)
        iris.scale = SCNVector3(1.0, 1.0, 0.5)
        iris.position = SCNVector3(x, y - 0.01, z + 0.06)
        root.addChildNode(iris)

        let pupil = facetSphere(radius: 0.028, color: CoordinatePalette.charcoal)
        pupil.scale = SCNVector3(0.9, 1.2, 0.7)
        pupil.position = SCNVector3(x, y - 0.005, z + 0.12)
        root.addChildNode(pupil)

        return root
    }

    private static func makeEarNode(
        outerColor: UIColor,
        innerColor: UIColor,
        width: CGFloat,
        height: CGFloat,
        depth: CGFloat,
        mirrored: Bool
    ) -> SCNNode {
        let root = SCNNode()

        let outer = facetPyramid(width: width, height: height, length: depth, color: outerColor)
        outer.eulerAngles = SCNVector3(-0.12, 0, mirrored ? -0.2 : 0.2)
        root.addChildNode(outer)

        let inner = facetPyramid(width: width * 0.56, height: height * 0.56, length: depth * 0.56, color: innerColor)
        inner.position = SCNVector3(0, height * 0.06, depth * 0.05)
        inner.eulerAngles = SCNVector3(-0.12, 0, mirrored ? -0.2 : 0.2)
        root.addChildNode(inner)

        return root
    }

    private static func makeLegNodes(pattern: CatPatternPreset, furMain: UIColor) -> [SCNNode] {
        let sockColor = pattern == .socks ? CoordinatePalette.paper : furMain

        let frontLeft = facetCapsule(radius: 0.11, height: 0.64, color: sockColor)
        frontLeft.position = SCNVector3(-0.22, -0.52, 0.62)

        let frontRight = facetCapsule(radius: 0.11, height: 0.64, color: sockColor)
        frontRight.position = SCNVector3(0.22, -0.52, 0.62)

        let rearLeft = facetCapsule(radius: 0.13, height: 0.52, color: sockColor)
        rearLeft.position = SCNVector3(-0.38, -0.48, -0.12)
        rearLeft.eulerAngles = SCNVector3(0.10, 0, 0.16)

        let rearRight = facetCapsule(radius: 0.13, height: 0.52, color: sockColor)
        rearRight.position = SCNVector3(0.38, -0.48, -0.12)
        rearRight.eulerAngles = SCNVector3(0.10, 0, -0.16)

        let pawLeft = facetSphere(radius: 0.13, color: sockColor)
        pawLeft.scale = SCNVector3(1.12, 0.7, 1.28)
        pawLeft.position = SCNVector3(-0.22, -0.84, 0.74)

        let pawRight = facetSphere(radius: 0.13, color: sockColor)
        pawRight.scale = SCNVector3(1.12, 0.7, 1.28)
        pawRight.position = SCNVector3(0.22, -0.84, 0.74)

        let hindPawLeft = facetSphere(radius: 0.15, color: sockColor)
        hindPawLeft.scale = SCNVector3(1.2, 0.74, 1.34)
        hindPawLeft.position = SCNVector3(-0.44, -0.8, -0.02)

        let hindPawRight = facetSphere(radius: 0.15, color: sockColor)
        hindPawRight.scale = SCNVector3(1.2, 0.74, 1.34)
        hindPawRight.position = SCNVector3(0.44, -0.8, -0.02)

        return [frontLeft, frontRight, rearLeft, rearRight, pawLeft, pawRight, hindPawLeft, hindPawRight]
    }

    private static func makeTailNode(shape: TailShapePreset, primary: UIColor, secondary: UIColor, lengthScale: Double) -> SCNNode {
        let root = SCNNode()
        let count: Int = switch shape {
        case .plume: 4
        case .ringed: 5
        case .curled: 5
        }

        for index in 0..<count {
            let thickness = CGFloat(max(0.08, 0.17 - Double(index) * 0.016))
            let segmentLength = CGFloat(0.42 * lengthScale)
            let color: UIColor
            switch shape {
            case .plume:
                color = primary
            case .ringed:
                color = index.isMultiple(of: 2) ? secondary : primary
            case .curled:
                color = index == count - 1 ? secondary : primary
            }

            let segment = facetCapsule(radius: thickness, height: segmentLength, color: color)
            let x = Float(index) * 0.14
            let y = Float(index) * (shape == .curled ? 0.18 : 0.23)
            let z = Float(index) * -0.04
            segment.position = SCNVector3(x, y, z)

            switch shape {
            case .plume:
                segment.eulerAngles = SCNVector3(0.28, 0.18, 0.88 - Float(index) * 0.08)
            case .ringed:
                segment.eulerAngles = SCNVector3(0.20, 0.10, 0.82 - Float(index) * 0.05)
            case .curled:
                segment.eulerAngles = SCNVector3(0.08, 0.10, 1.0 - Float(index) * 0.16)
            }
            root.addChildNode(segment)
        }
        return root
    }

    private static func makePatternNodes(for appearance: CatAppearance, mainColor: UIColor, altColor: UIColor) -> [SCNNode] {
        var nodes: [SCNNode] = []

        func patch(position: SCNVector3, scale: SCNVector3, color: UIColor) {
            let node = facetSphere(radius: 0.22, color: color)
            node.scale = scale
            node.position = position
            nodes.append(node)
        }

        switch appearance.pattern {
        case .solid:
            break
        case .striped:
            patch(position: SCNVector3(-0.18, 0.42, 0.56), scale: SCNVector3(0.48, 0.18, 0.8), color: altColor)
            patch(position: SCNVector3(0.14, 0.26, 0.50), scale: SCNVector3(0.52, 0.18, 0.86), color: altColor)
            patch(position: SCNVector3(0, 0.58, 0.08), scale: SCNVector3(0.84, 0.20, 0.40), color: altColor)
        case .patches:
            patch(position: SCNVector3(-0.44, 0.18, 0.08), scale: SCNVector3(0.92, 0.50, 0.54), color: altColor)
            patch(position: SCNVector3(0.36, 0.58, -0.10), scale: SCNVector3(0.66, 0.42, 0.58), color: altColor)
            patch(position: SCNVector3(0.16, 0.00, 0.42), scale: SCNVector3(0.54, 0.28, 0.54), color: altColor)
        case .socks:
            patch(position: SCNVector3(0, 0.18, 0.52), scale: SCNVector3(0.80, 0.30, 0.38), color: CoordinatePalette.paper)
        case .cloudy:
            patch(position: SCNVector3(-0.24, 0.34, 0.30), scale: SCNVector3(0.90, 0.40, 0.64), color: altColor)
            patch(position: SCNVector3(0.30, 0.52, -0.04), scale: SCNVector3(0.64, 0.34, 0.50), color: altColor)
        }

        switch appearance.facePattern {
        case .plain:
            break
        case .mask:
            patch(position: SCNVector3(0.02, 0.96, 1.14), scale: SCNVector3(1.12, 0.60, 0.20), color: altColor)
        case .blaze:
            patch(position: SCNVector3(0.02, 0.98, 1.20), scale: SCNVector3(0.20, 0.94, 0.16), color: CoordinatePalette.paper)
        case .noseDot:
            patch(position: SCNVector3(0.02, 0.74, 1.24), scale: SCNVector3(0.14, 0.14, 0.16), color: altColor)
        }

        return nodes
    }

    private static func applyMoodPose(to catNode: SCNNode, mood: MoodPreset) {
        catNode.removeAllActions()
        if let tailPivot = catNode.childNode(withName: "tail-pivot", recursively: true) {
            tailPivot.removeAllActions()
            let swish = SCNAction.sequence([
                .rotateTo(x: 0.18, y: 0.10, z: 0.18, duration: 0.9),
                .rotateTo(x: 0.04, y: -0.06, z: -0.18, duration: 0.9)
            ])
            tailPivot.runAction(.repeatForever(swish))
        }

        switch mood {
        case .playful:
            let bounce = SCNAction.sequence([
                .moveBy(x: 0, y: 0.05, z: 0, duration: 0.45),
                .moveBy(x: 0, y: -0.05, z: 0, duration: 0.45)
            ])
            catNode.runAction(.repeatForever(bounce))
        case .sleepy:
            catNode.eulerAngles = SCNVector3(0, -0.18, 0.06)
        case .proud:
            catNode.eulerAngles = SCNVector3(0, 0.16, 0)
        case .relaxed:
            let breathe = SCNAction.sequence([
                .scale(to: 1.02, duration: 1.4),
                .scale(to: 1.0, duration: 1.4)
            ])
            catNode.runAction(.repeatForever(breathe))
        }
    }

    private static func makeWindowNode(colorKey: String) -> SCNNode {
        let root = SCNNode()

        let frame = SCNNode(geometry: SCNBox(width: 2.0, height: 1.56, length: 0.12, chamferRadius: 0.03))
        frame.geometry?.firstMaterial = softMaterial(CoordinatePalette.roomTrim)
        root.addChildNode(frame)

        let glass = SCNNode(geometry: SCNBox(width: 1.62, height: 1.20, length: 0.05, chamferRadius: 0.03))
        glass.geometry?.firstMaterial = softMaterial(accentColor(colorKey).withAlphaComponent(0.9))
        glass.position = SCNVector3(0, 0, 0.05)
        root.addChildNode(glass)

        let mullion = SCNNode(geometry: SCNBox(width: 0.08, height: 1.20, length: 0.06, chamferRadius: 0.02))
        mullion.geometry?.firstMaterial = softMaterial(CoordinatePalette.roomTrim)
        mullion.position = SCNVector3(0, 0, 0.07)
        root.addChildNode(mullion)

        let curtainLeft = SCNNode(geometry: SCNBox(width: 0.28, height: 1.34, length: 0.08, chamferRadius: 0.04))
        curtainLeft.geometry?.firstMaterial = softMaterial(UIColor(red: 0.98, green: 0.95, blue: 0.90, alpha: 1))
        curtainLeft.position = SCNVector3(-0.92, 0.02, 0.02)
        curtainLeft.eulerAngles = SCNVector3(0, 0, 0.08)
        root.addChildNode(curtainLeft)

        let curtainRight = SCNNode(geometry: SCNBox(width: 0.28, height: 1.34, length: 0.08, chamferRadius: 0.04))
        curtainRight.geometry?.firstMaterial = softMaterial(UIColor(red: 0.98, green: 0.95, blue: 0.90, alpha: 1))
        curtainRight.position = SCNVector3(0.92, 0.02, 0.02)
        curtainRight.eulerAngles = SCNVector3(0, 0, -0.08)
        root.addChildNode(curtainRight)

        return root
    }

    private static func makeRugNode(colorKey: String) -> SCNNode {
        let rug = SCNNode(geometry: SCNCylinder(radius: 1.36, height: 0.05))
        rug.geometry?.firstMaterial = softMaterial(accentColor(colorKey))
        rug.scale = SCNVector3(1.20, 1, 0.88)

        let trim = SCNNode(geometry: SCNCylinder(radius: 1.22, height: 0.02))
        trim.geometry?.firstMaterial = softMaterial(UIColor.white.withAlphaComponent(0.7))
        trim.position = SCNVector3(0, 0.03, 0)
        trim.scale = SCNVector3(1.16, 1, 0.84)
        rug.addChildNode(trim)
        return rug
    }

    private static func makeBedNode(colorKey: String) -> SCNNode {
        let root = SCNNode()

        let base = SCNNode(geometry: SCNBox(width: 2.05, height: 0.26, length: 1.48, chamferRadius: 0.12))
        base.geometry?.firstMaterial = softMaterial(accentColor(colorKey))
        root.addChildNode(base)

        let mattress = SCNNode(geometry: SCNBox(width: 1.72, height: 0.20, length: 1.18, chamferRadius: 0.12))
        mattress.geometry?.firstMaterial = softMaterial(CoordinatePalette.paper)
        mattress.position = SCNVector3(0, 0.18, 0.02)
        root.addChildNode(mattress)

        let pillow = SCNNode(geometry: SCNBox(width: 0.66, height: 0.12, length: 0.36, chamferRadius: 0.08))
        pillow.geometry?.firstMaterial = softMaterial(UIColor(red: 1.0, green: 0.98, blue: 0.95, alpha: 1))
        pillow.position = SCNVector3(-0.34, 0.28, -0.28)
        root.addChildNode(pillow)

        return root
    }

    private static func makeWallDecorNode(colorKey: String) -> SCNNode {
        let root = SCNNode()

        let frame = SCNNode(geometry: SCNBox(width: 1.42, height: 0.94, length: 0.06, chamferRadius: 0.04))
        frame.geometry?.firstMaterial = softMaterial(CoordinatePalette.roomTrim)
        root.addChildNode(frame)

        let art = SCNNode(geometry: SCNBox(width: 1.16, height: 0.72, length: 0.03, chamferRadius: 0.03))
        art.geometry?.firstMaterial = softMaterial(accentColor(colorKey))
        art.position = SCNVector3(0, 0, 0.03)
        root.addChildNode(art)

        return root
    }

    private static func makeFoodBowlNode() -> SCNNode {
        let root = SCNNode()

        let bowl = SCNNode(geometry: SCNTube(innerRadius: 0.18, outerRadius: 0.38, height: 0.18))
        bowl.geometry?.firstMaterial = softMaterial(UIColor(red: 0.93, green: 0.66, blue: 0.55, alpha: 1))
        bowl.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        root.addChildNode(bowl)

        let food = facetSphere(radius: 0.17, color: UIColor(red: 0.77, green: 0.56, blue: 0.31, alpha: 1))
        food.scale = SCNVector3(1.24, 0.42, 1.24)
        food.position = SCNVector3(0, 0.06, 0)
        root.addChildNode(food)

        return root
    }

    private static func makeToyNode() -> SCNNode {
        let root = SCNNode()

        let yarn = facetSphere(radius: 0.24, color: UIColor(red: 0.68, green: 0.83, blue: 0.95, alpha: 1))
        yarn.scale = SCNVector3(1.0, 0.9, 1.0)
        root.addChildNode(yarn)

        let feather = SCNNode(geometry: SCNCone(topRadius: 0.02, bottomRadius: 0.08, height: 0.34))
        feather.geometry?.firstMaterial = softMaterial(UIColor(red: 0.99, green: 0.90, blue: 0.74, alpha: 1))
        feather.position = SCNVector3(-0.05, 0.26, 0)
        feather.eulerAngles = SCNVector3(0, 0, 0.42)
        root.addChildNode(feather)

        return root
    }

    private static func makePlantNode() -> SCNNode {
        let root = SCNNode()

        let pot = SCNNode(geometry: SCNCylinder(radius: 0.34, height: 0.44))
        pot.geometry?.firstMaterial = softMaterial(UIColor(red: 0.90, green: 0.73, blue: 0.59, alpha: 1))
        root.addChildNode(pot)

        for index in 0..<4 {
            let leaf = SCNNode(geometry: SCNCone(topRadius: 0.02, bottomRadius: 0.16, height: 0.80))
            leaf.geometry?.firstMaterial = softMaterial(UIColor(red: 0.57, green: 0.80, blue: 0.60, alpha: 1))
            leaf.position = SCNVector3(Float(index % 2 == 0 ? -0.08 : 0.08), 0.44, Float(index) * 0.05 - 0.08)
            leaf.eulerAngles = SCNVector3(-0.42, Float(index) * 0.42, index.isMultiple(of: 2) ? -0.34 : 0.34)
            root.addChildNode(leaf)
        }
        return root
    }

    static func softMaterial(_ color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.94
        material.metalness.contents = 0.0
        return material
    }

    static func shadowReceiverMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.colorBufferWriteMask = []
        material.writesToDepthBuffer = true
        material.readsFromDepthBuffer = true
        return material
    }

    private static func facetSphere(radius: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        geometry.segmentCount = 18
        geometry.firstMaterial = softMaterial(color)
        return SCNNode(geometry: geometry)
    }

    private static func facetCapsule(radius: CGFloat, height: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNCapsule(capRadius: radius, height: height)
        geometry.capSegmentCount = 8
        geometry.radialSegmentCount = 12
        geometry.firstMaterial = softMaterial(color)
        return SCNNode(geometry: geometry)
    }

    private static func facetPyramid(width: CGFloat, height: CGFloat, length: CGFloat, color: UIColor) -> SCNNode {
        let geometry = SCNPyramid(width: width, height: height, length: length)
        geometry.firstMaterial = softMaterial(color)
        return SCNNode(geometry: geometry)
    }

    private static func wallpaperColor(_ wallpaper: WallpaperStyle) -> UIColor {
        switch wallpaper {
        case .sunny:
            UIColor(red: 0.99, green: 0.96, blue: 0.88, alpha: 1)
        case .mint:
            UIColor(red: 0.89, green: 0.97, blue: 0.92, alpha: 1)
        case .berry:
            UIColor(red: 0.94, green: 0.89, blue: 0.95, alpha: 1)
        }
    }

    private static func wallpaperSecondaryColor(_ wallpaper: WallpaperStyle) -> UIColor {
        switch wallpaper {
        case .sunny:
            UIColor(red: 0.98, green: 0.91, blue: 0.82, alpha: 1)
        case .mint:
            UIColor(red: 0.83, green: 0.93, blue: 0.88, alpha: 1)
        case .berry:
            UIColor(red: 0.88, green: 0.82, blue: 0.91, alpha: 1)
        }
    }

    private static func accentColor(_ key: String?) -> UIColor {
        switch key {
        case "mint":
            UIColor(red: 0.71, green: 0.86, blue: 0.78, alpha: 1)
        case "berry":
            UIColor(red: 0.79, green: 0.62, blue: 0.75, alpha: 1)
        case "sky":
            UIColor(red: 0.62, green: 0.80, blue: 0.96, alpha: 1)
        case "butter":
            UIColor(red: 0.98, green: 0.89, blue: 0.62, alpha: 1)
        case "pearl":
            UIColor(red: 0.90, green: 0.89, blue: 0.95, alpha: 1)
        case "indigo":
            UIColor(red: 0.53, green: 0.56, blue: 0.78, alpha: 1)
        case "gold":
            UIColor(red: 0.89, green: 0.75, blue: 0.38, alpha: 1)
        default:
            UIColor(red: 0.96, green: 0.76, blue: 0.64, alpha: 1)
        }
    }

    private static func furColor(_ preset: FurColorPreset) -> UIColor {
        switch preset {
        case .cream:
            UIColor(red: 0.96, green: 0.90, blue: 0.78, alpha: 1)
        case .ginger:
            UIColor(red: 0.92, green: 0.61, blue: 0.33, alpha: 1)
        case .cocoa:
            UIColor(red: 0.56, green: 0.39, blue: 0.30, alpha: 1)
        case .charcoal:
            UIColor(red: 0.34, green: 0.34, blue: 0.39, alpha: 1)
        case .snow:
            UIColor(red: 0.99, green: 0.99, blue: 0.98, alpha: 1)
        case .calico:
            UIColor(red: 0.87, green: 0.69, blue: 0.48, alpha: 1)
        }
    }

    private static func eyeColor(_ preset: EyeColorPreset) -> UIColor {
        switch preset {
        case .jade:
            UIColor(red: 0.30, green: 0.67, blue: 0.47, alpha: 1)
        case .amber:
            UIColor(red: 0.86, green: 0.63, blue: 0.18, alpha: 1)
        case .sky:
            UIColor(red: 0.42, green: 0.72, blue: 0.92, alpha: 1)
        case .coffee:
            UIColor(red: 0.42, green: 0.29, blue: 0.21, alpha: 1)
        }
    }
}
