import SwiftUI

#if os(iOS)
import ARKit
import RealityKit
import UIKit
#endif

private enum CreatureAction: Int {
    case idle, pet, treat, jump, spin
}

struct ARCameraView: View {
    @EnvironmentObject private var store: GameStore
    @State private var action: CreatureAction = .idle
    @State private var actionID = 0
    @State private var message = ""

    var body: some View {
        ZStack {
            #if os(iOS)
            #if targetEnvironment(simulator)
            fallback
            #else
            if ARWorldTrackingConfiguration.isSupported {
                ARSpriteContainer(sprite: store.activeSprite, effects: store.effects(for: store.activeSprite), action: action, actionID: actionID)
                    .ignoresSafeArea()
            } else {
                fallback
            }
            #endif
            #else
            fallback
            #endif

            VStack(spacing: 0) {
                HStack {
                    CloseButton { store.goHome() }
                    Spacer()
                    Text(store.activeSprite.name)
                        .font(.system(.headline, design: .rounded).weight(.black))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Capsule().fill(.white.opacity(0.88)))
                }
                .padding()

                Spacer()

                VStack(spacing: 10) {
                    Text(message.isEmpty ? store.text("tap_sprite") : message)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .multilineTextAlignment(.center)

                    HStack(spacing: 8) {
                        actionButton("heart.fill", store.text("pet"), .pet, Theme.pink)
                        actionButton("carrot.fill", store.text("treat"), .treat, Theme.peach)
                        actionButton("arrow.up", store.text("jump"), .jump, Theme.mint)
                        actionButton("arrow.triangle.2.circlepath", store.text("spin"), .spin, Theme.lavender)
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }

            CameraFoodDragLayer(effects: store.effects(for: store.activeSprite)) {
                perform(.treat)
            }
        }
    }

    private var fallback: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            PlayCreatureStage(sprite: store.activeSprite, effects: store.effects(for: store.activeSprite), action: action, actionID: actionID)
                .onTapGesture { perform(.pet) }
        }
    }

    private func actionButton(_ symbol: String, _ label: String, _ newAction: CreatureAction, _ color: Color) -> some View {
        Button { perform(newAction) } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol).font(.title3.bold())
                Text(label).font(.system(.caption2, design: .rounded).weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(RoundedRectangle(cornerRadius: 20).fill(color))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func perform(_ newAction: CreatureAction) {
        action = newAction
        actionID += 1
        switch newAction {
        case .pet:
            message = store.text("purr")
            SpriteAudio.shared.play(.equip, volume: store.state.settings.volume)
        case .treat:
            message = store.text("yum")
            SpriteAudio.shared.play(.treat, volume: store.state.settings.volume)
        case .jump:
            message = store.text("boing")
            SpriteAudio.shared.play(.jump, volume: store.state.settings.volume)
        case .spin:
            message = store.text("twirl")
            SpriteAudio.shared.play(.spin, volume: store.state.settings.volume)
        case .idle: break
        }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}

private struct PlayCreatureStage: View {
    let sprite: SpriteDefinition
    let effects: Set<ItemEffect>
    let action: CreatureAction
    let actionID: Int

    @State private var jump = false
    @State private var spinDegrees: Double = 0
    @State private var squash = false
    @State private var foodOffset: CGFloat = -170
    @State private var showFood = false
    @State private var nibble = false

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                Image(systemName: index.isMultiple(of: 2) ? "sparkle" : "heart.fill")
                    .font(.system(size: CGFloat([18, 13, 16, 11][index % 4]), weight: .bold))
                    .foregroundStyle(index.isMultiple(of: 2) ? Theme.lemon : Theme.pink)
                    .offset(x: CGFloat([-145, 132, -80, 92, 12, -126, 154, -26, 56, -166][index]),
                            y: CGFloat([-190, -152, -82, 52, -232, 126, 170, 214, -20, 14][index]))
                    .opacity(0.75)
            }

            if showFood {
                CameraItemImage(name: foodImageName)
                    .frame(width: 66, height: 66)
                    .offset(x: foodOffset, y: nibble ? -10 : -84)
                    .scaleEffect(nibble ? 0.2 : 1.0)
                    .opacity(nibble ? 0.0 : 1.0)
            }

            SpriteArtView(sprite: sprite, effects: effects, size: 250)
                .offset(y: jump ? -120 : 0)
                .rotationEffect(.degrees(spinDegrees))
                .scaleEffect(x: squash ? 1.18 : 1, y: squash ? 0.82 : 1)
                .animation(.spring(response: 0.32, dampingFraction: 0.48), value: jump)
                .animation(.easeInOut(duration: 0.65), value: spinDegrees)
                .animation(.spring(response: 0.22, dampingFraction: 0.45), value: squash)
        }
        .onChange(of: actionID) { _, _ in runAction() }
    }

    private func runAction() {
        switch action {
        case .pet:
            squash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { squash = false }
        case .treat:
            showFood = true
            nibble = false
            foodOffset = -170
            withAnimation(.easeInOut(duration: 0.55)) { foodOffset = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                withAnimation(.easeOut(duration: 0.25)) { nibble = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
                showFood = false
                nibble = false
            }
        case .jump:
            jump = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) { jump = false }
        case .spin:
            spinDegrees += 360
        case .idle:
            break
        }
    }

    private var foodImageName: String {
        effects.contains(.caviar) ? "golden-caviar" : "food-mochi"
    }
}

private struct CameraFoodDragLayer: View {
    let effects: Set<ItemEffect>
    let onEat: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isEating = false

    var body: some View {
        GeometryReader { proxy in
            if let imageName = equippedFoodImageName {
                CameraItemImage(name: imageName)
                    .frame(width: 72, height: 72)
                    .scaleEffect(isEating ? 0.25 : 1)
                    .opacity(isEating ? 0 : 1)
                    .position(defaultPosition(in: proxy.size))
                    .offset(dragOffset)
                    .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
                    .gesture(
                        DragGesture()
                            .onChanged { value in dragOffset = value.translation }
                            .onEnded { value in
                                let start = defaultPosition(in: proxy.size)
                                let final = CGPoint(x: start.x + value.translation.width, y: start.y + value.translation.height)
                                let mouth = CGPoint(x: proxy.size.width / 2, y: proxy.size.height * 0.46)
                                if distance(final, mouth) < 135 {
                                    eat()
                                } else {
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.68)) {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                    .accessibilityLabel("Drag food to sprite")
            }
        }
        .allowsHitTesting(equippedFoodImageName != nil)
    }

    private var equippedFoodImageName: String? {
        if effects.contains(.caviar) { return "golden-caviar" }
        if effects.contains(.food) { return "food-mochi" }
        return nil
    }

    private func defaultPosition(in size: CGSize) -> CGPoint {
        CGPoint(x: 58, y: max(145, size.height - 190))
    }

    private func eat() {
        withAnimation(.easeOut(duration: 0.25)) { isEating = true }
        onEat()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            dragOffset = .zero
            isEating = false
        }
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
}

private struct CameraItemImage: View {
    let name: String

    var body: some View {
        Group {
            if let image = UIImage.spriteGOImage(named: name) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Theme.peach)
                    .padding(10)
            }
        }
    }
}

#if os(iOS)
private struct ARSpriteContainer: UIViewRepresentable {
    let sprite: SpriteDefinition
    let effects: Set<ItemEffect>
    let action: CreatureAction
    let actionID: Int

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        view.session.run(configuration)

        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.18, 0.18])
        let creature = makeCreatureEntity(sprite: sprite, effects: effects)
        creature.name = "kawaii-creature"
        anchor.addChild(creature)
        let food = makeFoodEntity(imageName: effects.contains(.caviar) ? "golden-caviar" : "food-mochi")
        food.name = "treat"
        food.position = [-0.16, 0.16, 0.06]
        food.isEnabled = false
        anchor.addChild(food)
        view.scene.addAnchor(anchor)
        context.coordinator.creature = creature
        context.coordinator.food = food
        context.coordinator.baseTransform = creature.transform

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTap))
        view.addGestureRecognizer(tap)
        return view
    }

    func updateUIView(_ view: ARView, context: Context) {
        let renderKey = "\(sprite.id)-\(effects.map(\.rawValue).sorted().joined(separator: ","))"
        if context.coordinator.lastRenderKey != renderKey {
            context.coordinator.lastRenderKey = renderKey
            updateCreatureEntity(context.coordinator.creature, sprite: sprite, effects: effects)
            updateFoodEntity(context.coordinator.food, imageName: effects.contains(.caviar) ? "golden-caviar" : "food-mochi")
        }

        if context.coordinator.lastActionID != actionID {
            context.coordinator.lastActionID = actionID
            context.coordinator.animate(action)
        }
    }

    private func makeCreatureEntity(sprite: SpriteDefinition, effects: Set<ItemEffect>) -> Entity {
        let root = Entity()
        let spritePlane = ModelEntity(mesh: .generatePlane(width: 0.28, height: 0.28),
                                      materials: [spriteMaterial(sprite: sprite, effects: effects)])
        spritePlane.name = "2d-sprite-plane"
        spritePlane.position = [0, 0.16, 0.02]
        root.addChild(spritePlane)

        let shadow = ModelEntity(mesh: .generatePlane(width: 0.22, depth: 0.12),
                                 materials: [SimpleMaterial(color: UIColor.black.withAlphaComponent(0.14), roughness: 1, isMetallic: false)])
        shadow.position = [0, 0.002, 0]
        root.addChild(shadow)
        return root
    }

    private func updateCreatureEntity(_ entity: Entity?, sprite: SpriteDefinition, effects: Set<ItemEffect>) {
        guard let model = entity?.findEntity(named: "2d-sprite-plane") as? ModelEntity else { return }
        model.model?.materials = [spriteMaterial(sprite: sprite, effects: effects)]
    }

    private func makeFoodEntity(imageName: String) -> ModelEntity {
        ModelEntity(mesh: .generatePlane(width: 0.055, height: 0.055),
                    materials: [imageMaterial(named: imageName)])
    }

    private func updateFoodEntity(_ entity: Entity?, imageName: String) {
        guard let model = entity as? ModelEntity else { return }
        model.model?.materials = [imageMaterial(named: imageName)]
    }

    private func spriteMaterial(sprite: SpriteDefinition, effects: Set<ItemEffect>) -> UnlitMaterial {
        imageMaterial(from: renderSprite(sprite: sprite, effects: effects))
    }

    private func imageMaterial(named name: String) -> UnlitMaterial {
        imageMaterial(from: UIImage.spriteGOImage(named: name) ?? UIImage())
    }

    private func imageMaterial(from image: UIImage) -> UnlitMaterial {
        guard let cgImage = image.cgImage,
              let texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color)) else {
            return UnlitMaterial(color: .white)
        }
        var material = UnlitMaterial()
        material.color = .init(texture: .init(texture))
        material.blending = .transparent(opacity: 1.0)
        return material
    }

    private func renderSprite(sprite: SpriteDefinition, effects: Set<ItemEffect>) -> UIImage {
        let view = SpriteArtView(sprite: sprite, effects: effects, size: 420)
            .frame(width: 460, height: 460)
            .background(.clear)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage ?? UIImage()
    }

    final class Coordinator: NSObject {
        weak var creature: Entity?
        weak var food: Entity?
        var baseTransform = Transform.identity
        var lastActionID = 0
        var lastRenderKey = ""

        @objc func didTap() { animate(.pet) }

        func animate(_ action: CreatureAction) {
            guard let creature else { return }
            var target = baseTransform
            let duration: TimeInterval
            switch action {
            case .pet:
                target.scale = [1.12, 0.9, 1.12]
                duration = 0.2
            case .treat:
                target.scale = [1.16, 1.16, 1.16]
                duration = 0.25
                animateTreat()
            case .jump:
                target.translation.y += 0.14
                duration = 0.3
            case .spin:
                spin(creature)
                return
            case .idle:
                return
            }
            creature.move(to: target, relativeTo: creature.parent, duration: duration, timingFunction: .easeInOut)
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self, weak creature] in
                guard let self, let creature else { return }
                creature.move(to: self.baseTransform, relativeTo: creature.parent, duration: 0.28, timingFunction: .easeInOut)
            }
        }

        private func spin(_ creature: Entity) {
            let parent = creature.parent
            for step in 1...12 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.045) { [weak self, weak creature] in
                    guard let self, let creature else { return }
                    var transform = self.baseTransform
                    transform.rotation = simd_quatf(angle: Float(step) * (.pi * 2 / 12), axis: [0, 1, 0])
                    creature.move(to: transform, relativeTo: parent, duration: 0.045, timingFunction: .linear)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) { [weak self, weak creature] in
                guard let self, let creature else { return }
                creature.move(to: self.baseTransform, relativeTo: parent, duration: 0.08, timingFunction: .easeInOut)
            }
        }

        private func animateTreat() {
            guard let food, let parent = food.parent else { return }
            food.isEnabled = true
            var start = food.transform
            start.translation = [-0.16, 0.16, 0.06]
            food.transform = start
            var mouth = start
            mouth.translation = [0, 0.18, 0.08]
            mouth.scale = [0.25, 0.25, 0.25]
            food.move(to: mouth, relativeTo: parent, duration: 0.45, timingFunction: .easeInOut)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) { [weak food] in
                food?.isEnabled = false
            }
        }
    }
}
#endif

#if os(iOS)
private extension UIImage {
    static func spriteGOImage(named name: String) -> UIImage? {
        if let image = UIImage(named: name) {
            return image
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "SpriteImages") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
}
#endif
