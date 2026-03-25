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
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.isPlaying = true
        view.allowsCameraControl = false
        context.coordinator.configureStaticScene()
        context.coordinator.update(appearance: appearance, outfit: outfit, accessory: accessory)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.update(appearance: appearance, outfit: outfit, accessory: accessory)
    }

    final class PreviewCoordinator {
        let scene = SCNScene()
        private let catContainer = SCNNode()

        func configureStaticScene() {
            scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }

            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.fieldOfView = 38
            cameraNode.position = SCNVector3(0, 1.4, 7.2)
            scene.rootNode.addChildNode(cameraNode)

            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.light?.intensity = 1100
            lightNode.position = SCNVector3(2.8, 4.6, 6)
            scene.rootNode.addChildNode(lightNode)

            let ambient = SCNNode()
            ambient.light = SCNLight()
            ambient.light?.type = .ambient
            ambient.light?.intensity = 420
            ambient.light?.color = UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1)
            scene.rootNode.addChildNode(ambient)

            let floor = SCNNode(geometry: SCNCylinder(radius: 2.2, height: 0.14))
            floor.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.96, green: 0.89, blue: 0.74, alpha: 1)
            floor.geometry?.firstMaterial?.roughness.contents = 0.95
            floor.position = SCNVector3(0, -1.2, 0)
            scene.rootNode.addChildNode(floor)

            catContainer.runAction(
                .repeatForever(
                    .sequence([
                        .rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 14)
                    ])
                )
            )
            scene.rootNode.addChildNode(catContainer)
        }

        func update(appearance: CatAppearance, outfit: OutfitDefinition?, accessory: AccessoryDefinition?) {
            catContainer.childNodes.forEach { $0.removeFromParentNode() }
            let cat = LowPolySceneFactory.makeCatNode(
                appearance: appearance,
                outfit: outfit,
                accessory: accessory,
                mood: .relaxed,
                name: nil
            )
            cat.position = SCNVector3(0, -0.5, 0)
            catContainer.addChildNode(cat)
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
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.isPlaying = true
        view.allowsCameraControl = false

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(HomeCoordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        context.coordinator.view = view
        context.coordinator.configureStaticScene()
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

        func configureStaticScene() {
            scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }

            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.fieldOfView = 50
            cameraNode.position = SCNVector3(0, 2.3, 8.8)
            scene.rootNode.addChildNode(cameraNode)

            let keyLight = SCNNode()
            keyLight.light = SCNLight()
            keyLight.light?.type = .omni
            keyLight.light?.intensity = 1250
            keyLight.position = SCNVector3(2.6, 4.4, 5.4)
            scene.rootNode.addChildNode(keyLight)

            let fillLight = SCNNode()
            fillLight.light = SCNLight()
            fillLight.light?.type = .ambient
            fillLight.light?.intensity = 520
            fillLight.light?.color = UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1)
            scene.rootNode.addChildNode(fillLight)

            scene.rootNode.addChildNode(dynamicRoot)
        }

        func update(cat: CatProfile) {
            dynamicRoot.childNodes.forEach { $0.removeFromParentNode() }

            let room = LowPolySceneFactory.makeHomeRoomNode(cat: cat)
            dynamicRoot.addChildNode(room)
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
                    animateBounce(node)
                    onTapTarget(.cat)
                    return
                case "bowl-interaction":
                    animateWiggle(node)
                    onTapTarget(.bowl)
                    return
                case "toy-interaction":
                    animateBounce(node)
                    onTapTarget(.toy)
                    return
                default:
                    currentNode = node.parent
                }
            }
        }

        private func animateBounce(_ node: SCNNode) {
            node.removeAction(forKey: "bounce")
            let up = SCNAction.moveBy(x: 0, y: 0.15, z: 0, duration: 0.12)
            up.timingMode = .easeOut
            let down = SCNAction.moveBy(x: 0, y: -0.15, z: 0, duration: 0.16)
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

private enum LowPolySceneFactory {
    static func makeHomeRoomNode(cat: CatProfile) -> SCNNode {
        let root = SCNNode()

        let wallColor = wallpaperColor(cat.homeState.wallpaper)
        let sideWallColor = wallpaperSecondaryColor(cat.homeState.wallpaper)
        let floorColor = UIColor(red: 0.95, green: 0.86, blue: 0.72, alpha: 1)

        let floor = SCNNode(geometry: SCNBox(width: 9, height: 0.24, length: 6.4, chamferRadius: 0.06))
        floor.geometry?.firstMaterial = flatMaterial(floorColor)
        floor.position = SCNVector3(0, -1.2, 0)
        root.addChildNode(floor)

        let backWall = SCNNode(geometry: SCNBox(width: 9, height: 5.2, length: 0.16, chamferRadius: 0.02))
        backWall.geometry?.firstMaterial = flatMaterial(wallColor)
        backWall.position = SCNVector3(0, 1.4, -3.0)
        root.addChildNode(backWall)

        let sideWall = SCNNode(geometry: SCNBox(width: 0.16, height: 5.2, length: 6.4, chamferRadius: 0.02))
        sideWall.geometry?.firstMaterial = flatMaterial(sideWallColor)
        sideWall.position = SCNVector3(-4.4, 1.4, 0)
        root.addChildNode(sideWall)

        let window = makeWindowNode(colorKey: GameContent.furniture(id: cat.homeState.placements[HomeSlot.window.rawValue])?.accentKey ?? "sky")
        window.position = SCNVector3(2.5, 1.05, -2.84)
        root.addChildNode(window)

        let rug = makeRugNode(colorKey: GameContent.furniture(id: cat.homeState.placements[HomeSlot.rug.rawValue])?.accentKey ?? "pearl")
        rug.position = SCNVector3(0.3, -1.08, 0.55)
        root.addChildNode(rug)

        let bed = makeBedNode(colorKey: GameContent.furniture(id: cat.homeState.placements[HomeSlot.bed.rawValue])?.accentKey ?? "butter")
        bed.position = SCNVector3(-2.55, -0.95, 0.6)
        root.addChildNode(bed)

        let wallDecor = makeWallDecorNode(colorKey: GameContent.furniture(id: cat.homeState.placements[HomeSlot.wall.rawValue])?.accentKey ?? "peach")
        wallDecor.position = SCNVector3(-2.15, 1.7, -2.85)
        root.addChildNode(wallDecor)

        let bowl = makeFoodBowlNode()
        bowl.name = "bowl-interaction"
        bowl.position = SCNVector3(1.92, -0.98, 1.55)
        root.addChildNode(bowl)

        let toy = makeToyNode()
        toy.name = "toy-interaction"
        toy.position = SCNVector3(2.7, -0.98, 0.55)
        root.addChildNode(toy)

        let catNode = makeCatNode(
            appearance: cat.appearance,
            outfit: GameContent.outfit(id: cat.wardrobeState.equippedOutfitID),
            accessory: GameContent.accessory(id: cat.activeAccessoryID),
            mood: cat.mood,
            name: "cat-interaction"
        )
        catNode.position = SCNVector3(-0.35, -0.28, 0.45)
        root.addChildNode(catNode)

        let plant = makePlantNode()
        plant.position = SCNVector3(3.65, -0.95, -1.9)
        root.addChildNode(plant)

        return root
    }

    static func makeCatNode(
        appearance: CatAppearance,
        outfit: OutfitDefinition?,
        accessory: AccessoryDefinition?,
        mood: MoodPreset,
        name: String?
    ) -> SCNNode {
        let root = SCNNode()
        root.name = name

        let primary = furColor(appearance.primaryFur)
        let secondary = furColor(appearance.secondaryFur)
        let accessoryAccent = accessory.map { accentColor($0.accentKey) }

        let bodyScale: CGFloat = switch appearance.bodyType {
        case .tiny: 0.88
        case .balanced: 1.0
        case .chonky: 1.18
        }

        let body = SCNNode(geometry: SCNCapsule(capRadius: 0.72 * bodyScale, height: 1.45 * bodyScale))
        body.geometry?.firstMaterial = flatMaterial(primary)
        body.position = SCNVector3(0, 0.15, 0)
        body.eulerAngles = SCNVector3(0, 0, 0.05)
        root.addChildNode(body)

        let head = SCNNode(geometry: SCNSphere(radius: CGFloat(0.62 * appearance.headScale)))
        head.geometry?.firstMaterial = flatMaterial(primary)
        head.position = SCNVector3(0.05, 1.0, 0.12)
        root.addChildNode(head)

        let muzzle = SCNNode(geometry: SCNSphere(radius: 0.21))
        muzzle.geometry?.firstMaterial = flatMaterial(UIColor(red: 0.98, green: 0.92, blue: 0.88, alpha: 1))
        muzzle.position = SCNVector3(0.05, 0.8, 0.56)
        muzzle.scale = SCNVector3(1.18, 0.9, 0.9)
        root.addChildNode(muzzle)

        let earHeight: CGFloat = switch appearance.earShape {
        case .round: 0.38
        case .pointy: 0.56
        case .fluffy: 0.48
        }
        let earGeometry = SCNPyramid(width: 0.36 * appearance.earScale, height: earHeight * appearance.earScale, length: 0.26)
        earGeometry.firstMaterial = flatMaterial(primary)

        let leftEar = SCNNode(geometry: earGeometry.copy() as? SCNGeometry)
        leftEar.position = SCNVector3(-0.36, 1.44, 0.04)
        leftEar.eulerAngles = SCNVector3(0.02, 0, 0.18)
        head.addChildNode(leftEar)

        let rightEar = SCNNode(geometry: earGeometry.copy() as? SCNGeometry)
        rightEar.position = SCNVector3(0.36, 1.44, 0.04)
        rightEar.eulerAngles = SCNVector3(0.02, 0, -0.18)
        head.addChildNode(rightEar)

        let eyeOffset = CGFloat(0.16 * appearance.eyeSpacing)
        let eyeGeometry = SCNSphere(radius: 0.08)
        eyeGeometry.firstMaterial = flatMaterial(eyeColor(appearance.eyeColor))
        let leftEye = SCNNode(geometry: eyeGeometry.copy() as? SCNGeometry)
        leftEye.position = SCNVector3(-eyeOffset, 0.96, 0.52)
        head.addChildNode(leftEye)

        let rightEye = SCNNode(geometry: eyeGeometry.copy() as? SCNGeometry)
        rightEye.position = SCNVector3(eyeOffset, 0.96, 0.52)
        head.addChildNode(rightEye)

        let paws = pawNodes(pattern: appearance.pattern)
        paws.forEach { root.addChildNode($0) }

        let tail = makeTailNode(shape: appearance.tailShape, primary: primary, secondary: secondary, lengthScale: appearance.tailLength)
        tail.position = SCNVector3(-0.82 * bodyScale, 0.2, -0.35)
        root.addChildNode(tail)

        makePatternNodes(for: appearance, primary: primary, secondary: secondary).forEach {
            root.addChildNode($0)
        }

        if let accessoryAccent {
            let collar = SCNNode(geometry: SCNTorus(ringRadius: 0.34, pipeRadius: 0.06))
            collar.geometry?.firstMaterial = flatMaterial(accessoryAccent)
            collar.position = SCNVector3(0.05, 0.8, 0.1)
            collar.eulerAngles = SCNVector3(CGFloat.pi / 2, 0, 0)
            root.addChildNode(collar)
        }

        if let outfit {
            let scarf = SCNNode(geometry: SCNTube(innerRadius: 0.54, outerRadius: 0.7, height: 0.32))
            scarf.geometry?.firstMaterial = flatMaterial(accentColor(outfit.accentKey))
            scarf.position = SCNVector3(0, 0.02, 0)
            scarf.eulerAngles = SCNVector3(CGFloat.pi / 2, 0, 0)
            root.addChildNode(scarf)
        }

        applyMoodPose(root, mood: mood)
        return root
    }

    private static func pawNodes(pattern: CatPatternPreset) -> [SCNNode] {
        let whitePaw = UIColor(red: 0.98, green: 0.97, blue: 0.96, alpha: 1)
        let defaultPaw = UIColor(red: 0.95, green: 0.89, blue: 0.74, alpha: 1)
        let useWhite = pattern == .socks
        let pawColor = useWhite ? whitePaw : defaultPaw

        let positions: [SCNVector3] = [
            SCNVector3(-0.34, -0.72, 0.25),
            SCNVector3(0.36, -0.72, 0.25),
            SCNVector3(-0.3, -0.72, -0.22),
            SCNVector3(0.32, -0.72, -0.22)
        ]

        return positions.map { position in
            let paw = SCNNode(geometry: SCNCapsule(capRadius: 0.14, height: 0.46))
            paw.geometry?.firstMaterial = flatMaterial(pawColor)
            paw.position = position
            return paw
        }
    }

    private static func makeTailNode(shape: TailShapePreset, primary: UIColor, secondary: UIColor, lengthScale: Double) -> SCNNode {
        let tailRoot = SCNNode()
        let segmentCount = shape == .curled ? 4 : 3
        for index in 0..<segmentCount {
            let radius = CGFloat(max(0.08, 0.14 - Double(index) * 0.018))
            let length = CGFloat(0.48 * lengthScale)
            let segment = SCNNode(geometry: SCNCapsule(capRadius: radius, height: length))
            let color: UIColor
            switch shape {
            case .plume:
                color = primary
            case .ringed:
                color = index.isMultiple(of: 2) ? secondary : primary
            case .curled:
                color = index == segmentCount - 1 ? secondary : primary
            }
            segment.geometry?.firstMaterial = flatMaterial(color)
            segment.position = SCNVector3(Float(index) * 0.22, Float(index) * 0.16, Float(-index) * 0.02)
            segment.eulerAngles = SCNVector3(0, 0, shape == .curled ? -0.6 + Float(index) * 0.2 : 0.65 - Float(index) * 0.05)
            tailRoot.addChildNode(segment)
        }
        return tailRoot
    }

    private static func makePatternNodes(for appearance: CatAppearance, primary: UIColor, secondary: UIColor) -> [SCNNode] {
        var nodes: [SCNNode] = []

        func spot(position: SCNVector3, scale: SCNVector3 = SCNVector3(0.3, 0.18, 0.1), color: UIColor) {
            let node = SCNNode(geometry: SCNSphere(radius: 0.24))
            node.geometry?.firstMaterial = flatMaterial(color)
            node.position = position
            node.scale = scale
            nodes.append(node)
        }

        switch appearance.pattern {
        case .solid:
            break
        case .striped:
            spot(position: SCNVector3(-0.3, 0.42, 0.58), color: secondary)
            spot(position: SCNVector3(0, 0.25, 0.62), color: secondary)
            spot(position: SCNVector3(0.28, 0.44, 0.55), color: secondary)
        case .patches:
            spot(position: SCNVector3(-0.35, 0.32, 0.4), scale: SCNVector3(0.48, 0.24, 0.16), color: secondary)
            spot(position: SCNVector3(0.38, 0.58, 0.1), scale: SCNVector3(0.36, 0.24, 0.16), color: secondary)
        case .socks:
            spot(position: SCNVector3(0.1, 0.08, 0.6), scale: SCNVector3(0.42, 0.2, 0.14), color: UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1))
        case .cloudy:
            spot(position: SCNVector3(-0.18, 0.45, 0.44), scale: SCNVector3(0.58, 0.24, 0.18), color: secondary.withAlphaComponent(0.96))
            spot(position: SCNVector3(0.26, 0.33, 0.46), scale: SCNVector3(0.42, 0.22, 0.14), color: secondary.withAlphaComponent(0.9))
        }

        switch appearance.facePattern {
        case .plain:
            break
        case .mask:
            spot(position: SCNVector3(0.02, 1.0, 0.47), scale: SCNVector3(0.85, 0.52, 0.18), color: secondary)
        case .blaze:
            spot(position: SCNVector3(0.02, 1.04, 0.55), scale: SCNVector3(0.22, 0.78, 0.14), color: UIColor(red: 0.99, green: 0.98, blue: 0.96, alpha: 1))
        case .noseDot:
            spot(position: SCNVector3(0.03, 0.82, 0.62), scale: SCNVector3(0.12, 0.12, 0.12), color: secondary)
        }

        return nodes
    }

    private static func applyMoodPose(_ node: SCNNode, mood: MoodPreset) {
        node.removeAllActions()

        switch mood {
        case .playful:
            let bounce = SCNAction.sequence([
                .moveBy(x: 0, y: 0.06, z: 0, duration: 0.5),
                .moveBy(x: 0, y: -0.06, z: 0, duration: 0.5)
            ])
            node.runAction(.repeatForever(bounce))
        case .sleepy:
            node.eulerAngles = SCNVector3(0, -0.16, 0.08)
        case .proud:
            node.eulerAngles = SCNVector3(0, 0.12, 0)
        case .relaxed:
            let sway = SCNAction.sequence([
                .rotateTo(x: 0, y: 0.04, z: 0, duration: 1.4),
                .rotateTo(x: 0, y: -0.04, z: 0, duration: 1.4)
            ])
            node.runAction(.repeatForever(sway))
        }
    }

    private static func makeWindowNode(colorKey: String) -> SCNNode {
        let root = SCNNode()

        let frame = SCNNode(geometry: SCNBox(width: 1.84, height: 1.42, length: 0.1, chamferRadius: 0.02))
        frame.geometry?.firstMaterial = flatMaterial(UIColor(red: 0.88, green: 0.76, blue: 0.60, alpha: 1))
        root.addChildNode(frame)

        let glass = SCNNode(geometry: SCNBox(width: 1.52, height: 1.12, length: 0.06, chamferRadius: 0.02))
        glass.geometry?.firstMaterial = flatMaterial(accentColor(colorKey).withAlphaComponent(0.82))
        glass.position = SCNVector3(0, 0, 0.04)
        root.addChildNode(glass)

        return root
    }

    private static func makeRugNode(colorKey: String) -> SCNNode {
        let rug = SCNNode(geometry: SCNCylinder(radius: 1.1, height: 0.06))
        rug.geometry?.firstMaterial = flatMaterial(accentColor(colorKey))
        rug.scale = SCNVector3(1.2, 1, 0.85)
        return rug
    }

    private static func makeBedNode(colorKey: String) -> SCNNode {
        let root = SCNNode()

        let base = SCNNode(geometry: SCNBox(width: 1.9, height: 0.36, length: 1.3, chamferRadius: 0.1))
        base.geometry?.firstMaterial = flatMaterial(accentColor(colorKey))
        base.position = SCNVector3(0, 0, 0)
        root.addChildNode(base)

        let cushion = SCNNode(geometry: SCNBox(width: 1.54, height: 0.26, length: 1.0, chamferRadius: 0.12))
        cushion.geometry?.firstMaterial = flatMaterial(UIColor(red: 0.99, green: 0.96, blue: 0.92, alpha: 1))
        cushion.position = SCNVector3(0, 0.2, 0)
        root.addChildNode(cushion)

        return root
    }

    private static func makeWallDecorNode(colorKey: String) -> SCNNode {
        let decor = SCNNode(geometry: SCNBox(width: 1.4, height: 0.86, length: 0.08, chamferRadius: 0.04))
        decor.geometry?.firstMaterial = flatMaterial(accentColor(colorKey))
        return decor
    }

    private static func makeFoodBowlNode() -> SCNNode {
        let root = SCNNode()
        let bowl = SCNNode(geometry: SCNTube(innerRadius: 0.18, outerRadius: 0.38, height: 0.16))
        bowl.geometry?.firstMaterial = flatMaterial(UIColor(red: 0.96, green: 0.69, blue: 0.55, alpha: 1))
        bowl.eulerAngles = SCNVector3(CGFloat.pi / 2, 0, 0)
        root.addChildNode(bowl)

        let food = SCNNode(geometry: SCNSphere(radius: 0.17))
        food.geometry?.firstMaterial = flatMaterial(UIColor(red: 0.76, green: 0.54, blue: 0.28, alpha: 1))
        food.scale = SCNVector3(1.3, 0.45, 1.3)
        food.position = SCNVector3(0, 0.05, 0)
        root.addChildNode(food)
        return root
    }

    private static func makeToyNode() -> SCNNode {
        let root = SCNNode()
        let ball = SCNNode(geometry: SCNSphere(radius: 0.24))
        ball.geometry?.firstMaterial = flatMaterial(UIColor(red: 0.70, green: 0.84, blue: 0.98, alpha: 1))
        root.addChildNode(ball)

        let tail = SCNNode(geometry: SCNCylinder(radius: 0.04, height: 0.42))
        tail.geometry?.firstMaterial = flatMaterial(UIColor(red: 0.98, green: 0.90, blue: 0.75, alpha: 1))
        tail.position = SCNVector3(0, 0.28, 0)
        tail.eulerAngles = SCNVector3(0, 0, 0.38)
        root.addChildNode(tail)
        return root
    }

    private static func makePlantNode() -> SCNNode {
        let root = SCNNode()
        let pot = SCNNode(geometry: SCNCylinder(radius: 0.34, height: 0.46))
        pot.geometry?.firstMaterial = flatMaterial(UIColor(red: 0.90, green: 0.73, blue: 0.59, alpha: 1))
        root.addChildNode(pot)

        for index in 0..<4 {
            let leaf = SCNNode(geometry: SCNCone(topRadius: 0.02, bottomRadius: 0.18, height: 0.85))
            leaf.geometry?.firstMaterial = flatMaterial(UIColor(red: 0.55, green: 0.78, blue: 0.57, alpha: 1))
            leaf.position = SCNVector3(Float(index % 2 == 0 ? -0.1 : 0.1), 0.46, Float(index) * 0.06 - 0.08)
            leaf.eulerAngles = SCNVector3(-0.4, Float(index) * 0.45, index.isMultiple(of: 2) ? -0.35 : 0.35)
            root.addChildNode(leaf)
        }
        return root
    }

    private static func flatMaterial(_ color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.lightingModel = .blinn
        material.roughness.contents = 0.92
        material.metalness.contents = 0.02
        return material
    }

    private static func wallpaperColor(_ wallpaper: WallpaperStyle) -> UIColor {
        switch wallpaper {
        case .sunny:
            UIColor(red: 0.99, green: 0.95, blue: 0.84, alpha: 1)
        case .mint:
            UIColor(red: 0.86, green: 0.96, blue: 0.89, alpha: 1)
        case .berry:
            UIColor(red: 0.92, green: 0.86, blue: 0.93, alpha: 1)
        }
    }

    private static func wallpaperSecondaryColor(_ wallpaper: WallpaperStyle) -> UIColor {
        switch wallpaper {
        case .sunny:
            UIColor(red: 0.98, green: 0.89, blue: 0.79, alpha: 1)
        case .mint:
            UIColor(red: 0.80, green: 0.92, blue: 0.87, alpha: 1)
        case .berry:
            UIColor(red: 0.86, green: 0.78, blue: 0.88, alpha: 1)
        }
    }

    private static func accentColor(_ key: String?) -> UIColor {
        switch key {
        case "mint":
            UIColor(red: 0.71, green: 0.86, blue: 0.78, alpha: 1)
        case "berry":
            UIColor(red: 0.77, green: 0.60, blue: 0.73, alpha: 1)
        case "sky":
            UIColor(red: 0.57, green: 0.77, blue: 0.94, alpha: 1)
        case "butter":
            UIColor(red: 0.97, green: 0.88, blue: 0.60, alpha: 1)
        case "pearl":
            UIColor(red: 0.89, green: 0.88, blue: 0.94, alpha: 1)
        case "indigo":
            UIColor(red: 0.49, green: 0.52, blue: 0.74, alpha: 1)
        case "gold":
            UIColor(red: 0.88, green: 0.73, blue: 0.35, alpha: 1)
        default:
            UIColor(red: 0.96, green: 0.76, blue: 0.64, alpha: 1)
        }
    }

    private static func furColor(_ preset: FurColorPreset) -> UIColor {
        switch preset {
        case .cream:
            UIColor(red: 0.95, green: 0.89, blue: 0.76, alpha: 1)
        case .ginger:
            UIColor(red: 0.92, green: 0.60, blue: 0.31, alpha: 1)
        case .cocoa:
            UIColor(red: 0.55, green: 0.39, blue: 0.28, alpha: 1)
        case .charcoal:
            UIColor(red: 0.33, green: 0.34, blue: 0.39, alpha: 1)
        case .snow:
            UIColor(red: 0.99, green: 0.99, blue: 0.98, alpha: 1)
        case .calico:
            UIColor(red: 0.88, green: 0.72, blue: 0.52, alpha: 1)
        }
    }

    private static func eyeColor(_ preset: EyeColorPreset) -> UIColor {
        switch preset {
        case .jade:
            UIColor(red: 0.29, green: 0.67, blue: 0.46, alpha: 1)
        case .amber:
            UIColor(red: 0.85, green: 0.62, blue: 0.18, alpha: 1)
        case .sky:
            UIColor(red: 0.42, green: 0.72, blue: 0.92, alpha: 1)
        case .coffee:
            UIColor(red: 0.37, green: 0.26, blue: 0.18, alpha: 1)
        }
    }
}
