import SwiftUI
#if os(iOS)
import UIKit
#endif

private enum CreatureKind {
    case kitsune
    case wolpertinger
    case pinkMothman
    case leviathan
    case starryChimera
    case pinkChimera
    case sakuraBakeneko
    case nessie
    case yeti
    case kappa
    case pegasus
    case deerDragon
    case moonBatCat
    case roundPet

    init(spriteID: String) {
        switch spriteID {
        case "flame-fox": self = .kitsune
        case "wolpertinger": self = .wolpertinger
        case "pink-mothman": self = .pinkMothman
        case "leviathan": self = .leviathan
        case "starry-chimera": self = .starryChimera
        case "pink-chimera": self = .pinkChimera
        case "sakura-bakeneko": self = .sakuraBakeneko
        case "nessie": self = .nessie
        case "yeti": self = .yeti
        case "kappa": self = .kappa
        case "pastel-pegasus": self = .pegasus
        case "deer-dragon": self = .deerDragon
        case "moon-bat-cat": self = .moonBatCat
        default: self = .roundPet
        }
    }
}

struct SpriteArtView: View {
    let sprite: SpriteDefinition
    var effects: Set<ItemEffect> = []
    var salonEffects = SalonEffects()
    var size: CGFloat = 180

    @State private var bob = false

    var body: some View {
        ZStack {
            if let imageName = sprite.imageName {
                imageBackedCreature(imageName: imageName)
                cosmetics
                salonOverlay
            } else if creatureKind == .roundPet {
                shadow
                aura
                wings
                tail
                bodyShape
                ears
                fantasyDetails
                paws
                face
                markings
                ribbon
                cosmetics
                salonOverlay
            } else {
                referenceCreature
                cosmetics
                salonOverlay
            }
            effectVisualOverlay
        }
        .frame(width: size, height: size)
        .colorMultiply(effects.contains(.darkCloak) ? Color(hex: "#75647F") : .white)
        .brightness(effects.contains(.lightDress) ? 0.11 : (effects.contains(.darkCloak) ? -0.08 : 0))
        .saturation(effects.contains(.darkCloak) ? 0.66 : (effects.contains(.lightDress) ? 1.12 : 1))
        .hueRotation(effects.contains(.crown) ? .degrees(bob ? 16 : -16) : .zero)
        .offset(y: bob ? -6 : 4)
        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: bob)
        .onAppear { bob = true }
    }

    private func imageBackedCreature(imageName: String) -> some View {
        ZStack {
            shadow
            aura
            SpriteImage(name: imageName)
                .frame(width: size * 1.05, height: size * 1.05)
                .shadow(color: detailColor.opacity(0.28), radius: size * 0.05, y: size * 0.025)
                .overlay(alignment: .top) {
                    if salonEffects.showered {
                        wetHair
                    }
                }
            heartDetails
        }
    }

    private var wetHair: some View {
        HStack(spacing: size * 0.018) {
            ForEach(0..<6, id: \.self) { index in
                Capsule()
                    .fill(Theme.sky.opacity(0.55))
                    .frame(width: size * 0.024, height: size * CGFloat([0.18, 0.24, 0.15, 0.28, 0.2, 0.16][index]))
                    .rotationEffect(.degrees(Double([-8, 3, 11, -4, 7, -12][index])))
            }
        }
        .offset(y: size * 0.08)
    }

    private var baseColor: Color {
        let color = Color(hex: sprite.bodyHex)
        return effects.contains(.darkCloak) ? color.opacity(0.62) : color
    }

    private var accentColor: Color {
        effects.contains(.darkCloak) ? Color(hex: "#6E6074") : Color(hex: sprite.accentHex)
    }

    private var detailColor: Color {
        Color(hex: sprite.detailHex)
    }

    @ViewBuilder
    private var effectVisualOverlay: some View {
        if effects.contains(.collar) || effects.contains(.crown) {
            ForEach(0..<10, id: \.self) { index in
                Image(systemName: index.isMultiple(of: 2) ? "sparkle" : "star.fill")
                    .font(.system(size: size * CGFloat([0.05, 0.035, 0.045, 0.03][index % 4]), weight: .bold))
                    .foregroundStyle(effects.contains(.crown) ? holographicGradient : AnyShapeStyle(Theme.lemon.opacity(0.9)))
                    .offset(
                        x: size * CGFloat([-0.38, -0.24, -0.08, 0.14, 0.3, 0.4, -0.34, 0.24, -0.02, 0.08][index]),
                        y: size * CGFloat([-0.28, -0.08, -0.34, -0.18, -0.3, 0.02, 0.16, 0.2, 0.32, 0.06][index])
                    )
                    .opacity(bob ? 0.95 : 0.45)
            }
        }

        if effects.contains(.crown) {
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [Theme.sky, Theme.pink, Theme.lemon, Theme.mint, Theme.lavender, Theme.sky],
                        center: .center
                    ),
                    lineWidth: size * 0.025
                )
                .frame(width: size * 0.9, height: size * 0.9)
                .opacity(0.42)
                .rotationEffect(.degrees(bob ? 18 : -18))
        }
    }

    private var holographicGradient: AnyShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                colors: [Theme.sky, Theme.pink, Theme.lemon, Theme.mint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var variant: Int {
        abs(sprite.id.hashValue) % 5
    }

    private var creatureKind: CreatureKind {
        CreatureKind(spriteID: sprite.id)
    }

    private var shadow: some View {
        Ellipse()
            .fill(.black.opacity(0.12))
            .frame(width: size * 0.72, height: size * 0.13)
            .offset(y: size * 0.38)
    }

    private var aura: some View {
        ZStack {
            Circle()
                .fill(detailColor.opacity(0.12))
                .frame(width: size * 0.9, height: size * 0.9)
            ForEach(0..<6, id: \.self) { index in
                Image(systemName: index.isMultiple(of: 2) ? "sparkle" : "heart.fill")
                    .font(.system(size: size * 0.055, weight: .bold))
                    .foregroundStyle(index.isMultiple(of: 2) ? Theme.lemon : Theme.pink)
                    .offset(x: cos(Double(index) * .pi / 3) * size * 0.43,
                            y: sin(Double(index) * .pi / 3) * size * 0.4)
            }
        }
    }

    private var bodyShape: some View {
        ZStack {
            Circle()
                .fill(baseColor)
                .frame(width: size * 0.68, height: size * 0.68)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.34), lineWidth: size * 0.025)
                        .padding(size * 0.035)
                )
            Circle()
                .fill(accentColor)
                .frame(width: size * 0.36, height: size * 0.28)
                .offset(y: size * 0.14)
            ForEach(0..<9, id: \.self) { index in
                Circle()
                    .fill(.white.opacity(0.34))
                    .frame(width: size * CGFloat([0.026, 0.018, 0.022][index % 3]))
                    .offset(
                        x: CGFloat([-0.18, -0.04, 0.14, 0.22, -0.24, 0.04, 0.18, -0.12, 0.0][index]) * size,
                        y: CGFloat([-0.2, -0.27, -0.18, 0.0, 0.08, 0.2, 0.14, 0.23, -0.08][index]) * size
                    )
            }
        }
    }

    private var ears: some View {
        ZStack {
            Triangle()
                .fill(baseColor)
                .frame(width: size * 0.28, height: size * 0.28)
                .rotationEffect(.degrees(-24))
                .offset(x: -size * 0.22, y: -size * 0.31)
            Triangle()
                .fill(baseColor)
                .frame(width: size * 0.28, height: size * 0.28)
                .rotationEffect(.degrees(24))
                .offset(x: size * 0.22, y: -size * 0.31)
            Triangle()
                .fill(detailColor.opacity(0.55))
                .frame(width: size * 0.13, height: size * 0.14)
                .rotationEffect(.degrees(-24))
                .offset(x: -size * 0.22, y: -size * 0.31)
            Triangle()
                .fill(detailColor.opacity(0.55))
                .frame(width: size * 0.13, height: size * 0.14)
                .rotationEffect(.degrees(24))
                .offset(x: size * 0.22, y: -size * 0.31)
            if variant == 0 || sprite.id == "flame-fox" {
                Circle().fill(detailColor).frame(width: size * 0.08).offset(x: -size * 0.34, y: -size * 0.18)
                Circle().fill(detailColor).frame(width: size * 0.08).offset(x: size * 0.34, y: -size * 0.18)
            }
        }
    }

    @ViewBuilder
    private var wings: some View {
        if variant == 1 || variant == 3 {
            ZStack {
                WingShape()
                    .fill(LinearGradient(colors: [accentColor.opacity(0.92), detailColor.opacity(0.42)], startPoint: .top, endPoint: .bottom))
                    .frame(width: size * 0.42, height: size * 0.44)
                    .rotationEffect(.degrees(-18))
                    .offset(x: -size * 0.32, y: -size * 0.01)
                    .overlay(wingVeins.offset(x: -size * 0.32, y: -size * 0.01).rotationEffect(.degrees(-18)))
                WingShape()
                    .fill(LinearGradient(colors: [accentColor.opacity(0.92), detailColor.opacity(0.42)], startPoint: .top, endPoint: .bottom))
                    .frame(width: size * 0.42, height: size * 0.44)
                    .rotationEffect(.degrees(18))
                    .scaleEffect(x: -1, y: 1)
                    .offset(x: size * 0.32, y: -size * 0.01)
                    .overlay(wingVeins.offset(x: size * 0.32, y: -size * 0.01).rotationEffect(.degrees(18)).scaleEffect(x: -1, y: 1))
            }
        }
    }

    private var wingVeins: some View {
        ZStack {
            Capsule().fill(.white.opacity(0.55)).frame(width: size * 0.02, height: size * 0.28)
            Capsule().fill(.white.opacity(0.45)).frame(width: size * 0.016, height: size * 0.19).rotationEffect(.degrees(34)).offset(x: size * 0.055, y: size * 0.035)
            Capsule().fill(.white.opacity(0.45)).frame(width: size * 0.016, height: size * 0.16).rotationEffect(.degrees(-34)).offset(x: -size * 0.055, y: size * 0.055)
        }
        .frame(width: size * 0.42, height: size * 0.44)
    }

    @ViewBuilder
    private var fantasyDetails: some View {
        if variant == 2 {
            antlers
        } else if variant == 4 {
            horn
        }
    }

    private var horn: some View {
        Triangle()
            .fill(LinearGradient(colors: [Theme.lemon, detailColor.opacity(0.72)], startPoint: .top, endPoint: .bottom))
            .frame(width: size * 0.14, height: size * 0.2)
            .offset(y: -size * 0.43)
            .overlay(
                Capsule()
                    .fill(.white.opacity(0.55))
                    .frame(width: size * 0.018, height: size * 0.13)
                    .rotationEffect(.degrees(20))
                    .offset(y: -size * 0.42)
            )
    }

    private var antlers: some View {
        ZStack {
            antlerSide(rotation: -18).offset(x: -size * 0.14, y: -size * 0.39)
            antlerSide(rotation: 18).scaleEffect(x: -1, y: 1).offset(x: size * 0.14, y: -size * 0.39)
        }
    }

    private func antlerSide(rotation: Double) -> some View {
        ZStack {
            Capsule().fill(Theme.peach).frame(width: size * 0.035, height: size * 0.22)
            Capsule().fill(Theme.peach).frame(width: size * 0.028, height: size * 0.1).rotationEffect(.degrees(-42)).offset(x: -size * 0.04, y: -size * 0.045)
            Capsule().fill(Theme.peach).frame(width: size * 0.028, height: size * 0.1).rotationEffect(.degrees(42)).offset(x: size * 0.04, y: -size * 0.02)
        }
        .rotationEffect(.degrees(rotation))
    }

    private var face: some View {
        ZStack {
            eye(x: -size * 0.13)
            eye(x: size * 0.13).scaleEffect(x: -1, y: 1)
            Circle().fill(Theme.pink.opacity(0.85)).frame(width: size * 0.09, height: size * 0.045).offset(x: -size * 0.22, y: size * 0.075)
            Circle().fill(Theme.pink.opacity(0.85)).frame(width: size * 0.09, height: size * 0.045).offset(x: size * 0.22, y: size * 0.075)
            Triangle().fill(Theme.coral).frame(width: size * 0.055, height: size * 0.04).rotationEffect(.degrees(180)).offset(y: size * 0.055)
            Path { path in
                path.move(to: CGPoint(x: size * 0.47, y: size * 0.56))
                path.addQuadCurve(to: CGPoint(x: size * 0.5, y: size * 0.59), control: CGPoint(x: size * 0.48, y: size * 0.59))
                path.addQuadCurve(to: CGPoint(x: size * 0.53, y: size * 0.56), control: CGPoint(x: size * 0.52, y: size * 0.59))
            }
            .stroke(Theme.ink, style: StrokeStyle(lineWidth: max(1.5, size * 0.01), lineCap: .round))
        }
    }

    private func eye(x: CGFloat) -> some View {
        ZStack {
            Capsule().fill(Theme.ink).frame(width: size * 0.09, height: size * 0.12)
            Capsule().fill(LinearGradient(colors: [Theme.sky.opacity(0.95), detailColor.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.047, height: size * 0.06)
                .offset(y: size * 0.02)
            Circle().fill(.white).frame(width: size * 0.032).offset(x: -size * 0.012, y: -size * 0.034)
            Circle().fill(.white.opacity(0.78)).frame(width: size * 0.016).offset(x: size * 0.017, y: -size * 0.006)
        }
        .offset(x: x, y: -size * 0.025)
    }

    private var paws: some View {
        ZStack {
            paw.offset(x: -size * 0.2, y: size * 0.29)
            paw.offset(x: size * 0.2, y: size * 0.29)
        }
    }

    private var paw: some View {
        Capsule()
            .fill(accentColor)
            .frame(width: size * 0.2, height: size * 0.13)
            .overlay(HStack(spacing: size * 0.018) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(Theme.pink.opacity(0.75)).frame(width: size * 0.025)
                }
            })
    }

    private var markings: some View {
        ZStack {
            Capsule().fill(detailColor.opacity(0.35)).frame(width: size * 0.08, height: size * 0.025).rotationEffect(.degrees(-18)).offset(x: -size * 0.1, y: -size * 0.18)
            Capsule().fill(detailColor.opacity(0.35)).frame(width: size * 0.08, height: size * 0.025).rotationEffect(.degrees(18)).offset(x: size * 0.1, y: -size * 0.18)
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.08, weight: .bold))
                .foregroundStyle(detailColor)
                .offset(y: size * 0.19)
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "heart.fill")
                    .font(.system(size: size * CGFloat([0.045, 0.032, 0.026][index]), weight: .bold))
                    .foregroundStyle(Theme.pink.opacity(0.72))
                    .offset(
                        x: CGFloat([-0.3, 0.29, 0.0][index]) * size,
                        y: CGFloat([-0.3, -0.26, -0.36][index]) * size
                    )
            }
        }
    }

    private var tail: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index == 3 ? detailColor.opacity(0.86) : baseColor)
                    .frame(width: size * CGFloat(0.23 - Double(index) * 0.02), height: size * CGFloat(0.35 - Double(index) * 0.028))
                    .rotationEffect(.degrees(-45 + Double(index) * 8))
                    .offset(
                        x: size * CGFloat(0.29 + Double(index) * 0.07),
                        y: size * CGFloat(0.14 - Double(index) * 0.065)
                    )
            }
        }
    }

    private var ribbon: some View {
        ZStack {
            Circle().fill(Theme.lemon).frame(width: size * 0.085)
            BowLoop().fill(detailColor.opacity(0.92)).frame(width: size * 0.16, height: size * 0.12).offset(x: -size * 0.075)
            BowLoop().fill(detailColor.opacity(0.92)).frame(width: size * 0.16, height: size * 0.12).scaleEffect(x: -1, y: 1).offset(x: size * 0.075)
            Circle().fill(.white.opacity(0.75)).frame(width: size * 0.035)
        }
        .offset(x: size * 0.33, y: -size * 0.3)
    }

    @ViewBuilder
    private var cosmetics: some View {
        if effects.contains(.lightDress) {
            Capsule()
                .fill(Color(hex: "#FFF8D6"))
                .frame(width: size * 0.5, height: size * 0.18)
                .offset(y: size * 0.22)
        }
        if effects.contains(.crown) {
            CrownShape()
                .fill(Color(hex: "#FFD166"))
                .frame(width: size * 0.32, height: size * 0.18)
                .offset(y: -size * 0.42)
        }
        if effects.contains(.collar) {
            Capsule()
                .stroke(Color(hex: "#63D2FF"), lineWidth: max(4, size * 0.03))
                .frame(width: size * 0.44, height: size * 0.12)
                .offset(y: size * 0.18)
        }
        if effects.contains(.darkCloak) {
            Capsule()
                .fill(Color(hex: "#3D314A").opacity(0.35))
                .frame(width: size * 0.62, height: size * 0.36)
                .offset(y: size * 0.19)
        }
        if effects.contains(.food) {
            heldFood(imageName: "food-mochi")
        }
        if effects.contains(.caviar) {
            heldFood(imageName: "golden-caviar")
        }
    }

    private func heldFood(imageName: String) -> some View {
        SpriteImage(name: imageName)
            .frame(width: size * 0.3, height: size * 0.3)
            .rotationEffect(.degrees(-10))
            .offset(x: -size * 0.27, y: size * 0.2)
            .shadow(color: .black.opacity(0.12), radius: size * 0.02, y: size * 0.015)
    }

    @ViewBuilder
    private var salonOverlay: some View {
        if salonEffects.shampooed {
            BubbleCluster(size: size)
        }
        if salonEffects.dried {
            Image(systemName: "wind")
                .font(.system(size: size * 0.22, weight: .bold))
                .foregroundStyle(Theme.sky)
                .offset(x: -size * 0.42, y: -size * 0.08)
        }
        if salonEffects.brushed {
            Image(systemName: "sparkles")
                .font(.system(size: size * 0.2, weight: .bold))
                .foregroundStyle(Theme.lemon)
                .offset(x: size * 0.35, y: -size * 0.16)
        }
        if salonEffects.showered {
            wetHair
            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .fill(Theme.sky.opacity(0.58))
                    .frame(width: size * 0.025, height: size * CGFloat([0.12, 0.18, 0.15, 0.22][index % 4]))
                    .offset(x: size * CGFloat([-0.22, -0.14, -0.06, 0.03, 0.11, 0.19, 0.26, -0.29][index]),
                            y: size * CGFloat([-0.21, -0.18, -0.2, -0.16, -0.2, -0.18, -0.15, -0.12][index]))
            }
        }
    }
}

private extension SpriteArtView {
    @ViewBuilder
    var referenceCreature: some View {
        ZStack {
            shadow
            aura
            switch creatureKind {
            case .kitsune: kitsune
            case .wolpertinger: wolpertinger
            case .pinkMothman: mothman(isDark: false)
            case .leviathan: leviathan
            case .starryChimera: chimera(isStarry: true)
            case .pinkChimera: chimera(isStarry: false)
            case .sakuraBakeneko: sakuraBakeneko
            case .nessie: nessie
            case .yeti: yeti
            case .kappa: kappa
            case .pegasus: pegasus
            case .deerDragon: deerDragon
            case .moonBatCat: moonBatCat
            case .roundPet: EmptyView()
            }
        }
    }

    var kitsune: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index == 3 ? accentColor : baseColor)
                    .overlay(Capsule().stroke(detailColor.opacity(0.75), lineWidth: size * 0.018))
                    .frame(width: size * CGFloat(0.16 - Double(index) * 0.01), height: size * CGFloat(0.52 - Double(index) * 0.04))
                    .rotationEffect(.degrees(46 - Double(index) * 18))
                    .offset(x: size * CGFloat(0.22 + Double(index) * 0.07),
                            y: size * CGFloat(0.03 - Double(index) * 0.04))
            }
            Capsule()
                .fill(baseColor)
                .overlay(Capsule().stroke(.white.opacity(0.75), lineWidth: size * 0.018))
                .frame(width: size * 0.58, height: size * 0.48)
                .offset(y: size * 0.12)
            Circle()
                .fill(baseColor)
                .overlay(Circle().stroke(.white.opacity(0.75), lineWidth: size * 0.018))
                .frame(width: size * 0.5)
                .offset(y: -size * 0.06)
            Circle()
                .fill(accentColor)
                .frame(width: size * 0.24, height: size * 0.2)
                .offset(y: size * 0.08)
            foxEars
            blossomCrown
            stickerFace
            ForEach(0..<6, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.035, weight: .bold))
                    .foregroundStyle(detailColor)
                    .offset(x: size * CGFloat([-0.2, -0.08, 0.12, 0.24, -0.3, 0.32][index]),
                            y: size * CGFloat([-0.22, 0.13, -0.26, 0.08, 0.0, -0.08][index]))
            }
        }
    }

    var wolpertinger: some View {
        ZStack {
            smallWings(color: accentColor)
            bunnyBody
            antlers.offset(y: -size * 0.01)
            longBunnyEars
            stickerFace
            starSprinkles
        }
    }

    func mothman(isDark: Bool) -> some View {
        let wingColor = isDark ? Color(hex: "#545057") : baseColor
        let collarColor = isDark ? Color(hex: "#777379") : accentColor
        return ZStack {
            mothWing(side: -1, color: wingColor)
            mothWing(side: 1, color: wingColor)
            Capsule()
                .fill(baseColor)
                .overlay(Capsule().stroke(.white.opacity(0.9), lineWidth: size * 0.025))
                .frame(width: size * 0.34, height: size * 0.42)
                .offset(y: size * 0.08)
            fluffyCollar(color: collarColor)
            longBunnyEars
            stickerFace
            starSprinkles
        }
    }

    var leviathan: some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                Circle()
                    .fill(index == 0 ? accentColor : baseColor)
                    .overlay(Circle().stroke(.white.opacity(0.75), lineWidth: size * 0.012))
                    .frame(width: size * CGFloat(0.28 - Double(index) * 0.014))
                    .offset(x: size * CGFloat(-0.19 + cos(Double(index) * 0.82) * 0.25),
                            y: size * CGFloat(0.1 + sin(Double(index) * 0.82) * 0.22))
            }
            seaHead
            finFan
            horn.offset(y: -size * 0.05)
            stickerFace.offset(x: -size * 0.03, y: -size * 0.09)
            starSprinkles
        }
    }

    func chimera(isStarry: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isStarry ? detailColor : accentColor)
                .frame(width: size * 0.82)
                .overlay(Circle().stroke(.white, lineWidth: size * 0.035))
            ForEach(0..<12, id: \.self) { index in
                Image(systemName: index.isMultiple(of: 3) ? "sparkle" : "star.fill")
                    .font(.system(size: size * 0.026, weight: .bold))
                    .foregroundStyle(isStarry ? .white : detailColor.opacity(0.9))
                    .offset(x: cos(Double(index) * .pi / 6) * size * 0.34,
                            y: sin(Double(index) * .pi / 6) * size * 0.34)
            }
            roundHeadBody(bodyScale: 0.5, headYOffset: -0.02, bodyColor: isStarry ? Color(hex: "#56545B") : baseColor, bellyColor: isStarry ? Color(hex: "#56545B") : baseColor)
            foxEars.scaleEffect(0.72).offset(y: size * 0.03)
            snakeTail(color: isStarry ? Color(hex: "#AFC4FF") : detailColor)
            stickerFace
        }
    }

    var sakuraBakeneko: some View {
        ZStack {
            twinTail(side: -1)
            twinTail(side: 1)
            roundHeadBody(bodyScale: 0.68, headYOffset: -0.03)
            foxEars
            flower(offsetX: -0.22, offsetY: -0.23)
            flower(offsetX: 0.22, offsetY: -0.23)
            stickerFace
            heartDetails
        }
    }

    var nessie: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Capsule()
                    .fill(index == 4 ? accentColor : baseColor)
                    .frame(width: size * 0.28, height: size * 0.16)
                    .rotationEffect(.degrees(-12 + Double(index) * 8))
                    .offset(x: size * CGFloat(-0.25 + Double(index) * 0.14),
                            y: size * CGFloat(0.14 - Double(index) * 0.02))
            }
            Capsule()
                .fill(baseColor)
                .frame(width: size * 0.16, height: size * 0.42)
                .rotationEffect(.degrees(-28))
                .offset(x: size * 0.15, y: -size * 0.04)
            Circle().fill(baseColor).frame(width: size * 0.22).offset(x: size * 0.25, y: -size * 0.2)
            finRow
            stickerFace.offset(x: size * 0.24, y: -size * 0.2).scaleEffect(0.7)
            Image(systemName: "star.fill").foregroundStyle(Theme.lemon).font(.system(size: size * 0.16)).offset(x: size * 0.36, y: -size * 0.38)
            starSprinkles
        }
    }

    var yeti: some View {
        ZStack {
            Capsule()
                .fill(baseColor)
                .overlay(Capsule().stroke(detailColor, lineWidth: size * 0.018))
                .frame(width: size * 0.56, height: size * 0.7)
            fluffyHair
            hornPair
            stickerFace.offset(y: -size * 0.02)
            Capsule().fill(accentColor).frame(width: size * 0.34, height: size * 0.18).offset(y: size * 0.17)
            starSprinkles
        }
    }

    var kappa: some View {
        ZStack {
            Circle().fill(Color(hex: "#87CB83")).frame(width: size * 0.68).offset(y: size * 0.12)
            Circle().fill(baseColor).frame(width: size * 0.48).offset(y: -size * 0.04)
            leafHat
            Capsule().fill(Color(hex: "#6DBB74")).frame(width: size * 0.22, height: size * 0.5).rotationEffect(.degrees(36)).offset(x: size * 0.2, y: size * 0.16)
            cucumber
            stickerFace.offset(y: -size * 0.06).scaleEffect(0.8)
            starSprinkles
        }
    }

    var pegasus: some View {
        ZStack {
            smallWings(color: accentColor).scaleEffect(1.25).offset(x: -size * 0.05)
            Capsule().fill(baseColor).frame(width: size * 0.6, height: size * 0.28).offset(y: size * 0.12)
            Circle().fill(baseColor).frame(width: size * 0.25).offset(x: size * 0.25, y: -size * 0.04)
            Capsule().fill(detailColor.opacity(0.45)).frame(width: size * 0.15, height: size * 0.32).rotationEffect(.degrees(30)).offset(x: size * 0.37, y: -size * 0.05)
            horn.offset(x: size * 0.27, y: -size * 0.15).scaleEffect(0.7)
            stickerFace.offset(x: size * 0.25, y: -size * 0.05).scaleEffect(0.55)
            heartDetails
        }
    }

    var deerDragon: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index == 3 ? detailColor.opacity(0.45) : baseColor)
                    .frame(width: size * 0.22, height: size * 0.36)
                    .rotationEffect(.degrees(-38 + Double(index) * 12))
                    .offset(x: size * CGFloat(0.27 + Double(index) * 0.08), y: size * CGFloat(0.12 - Double(index) * 0.06))
            }
            Capsule().fill(baseColor).frame(width: size * 0.55, height: size * 0.34).offset(y: size * 0.1)
            Circle().fill(baseColor).frame(width: size * 0.3).offset(x: -size * 0.23, y: -size * 0.08)
            antlers.offset(x: -size * 0.23, y: -size * 0.1).scaleEffect(0.9)
            stickerFace.offset(x: -size * 0.23, y: -size * 0.08).scaleEffect(0.62)
            starSprinkles
        }
    }

    var moonBatCat: some View {
        ZStack {
            BatWingShape().fill(detailColor.opacity(0.85)).frame(width: size * 0.42, height: size * 0.34).offset(x: -size * 0.25, y: size * 0.02)
            BatWingShape().fill(detailColor.opacity(0.85)).frame(width: size * 0.42, height: size * 0.34).scaleEffect(x: -1, y: 1).offset(x: size * 0.25, y: size * 0.02)
            roundHeadBody(bodyScale: 0.66, headYOffset: -0.04)
            foxEars
            stickerFace
            heartDetails
        }
    }

    func roundHeadBody(bodyScale: CGFloat, headYOffset: CGFloat, bodyColor: Color? = nil, bellyColor: Color? = nil) -> some View {
        ZStack {
            Circle().fill(bodyColor ?? baseColor).frame(width: size * bodyScale).offset(y: size * 0.08)
            Circle().fill(bodyColor ?? baseColor).frame(width: size * 0.48).offset(y: size * headYOffset)
            Circle().fill(bellyColor ?? accentColor).frame(width: size * 0.28, height: size * 0.22).offset(y: size * 0.15)
        }
        .overlay(Circle().stroke(.white.opacity(0.72), lineWidth: size * 0.018).frame(width: size * bodyScale).offset(y: size * 0.08))
    }

    var bunnyBody: some View {
        ZStack {
            Circle().fill(baseColor).frame(width: size * 0.58).offset(y: size * 0.12)
            Circle().fill(accentColor).frame(width: size * 0.38).offset(y: size * 0.04)
            paw.offset(x: -size * 0.16, y: size * 0.3).scaleEffect(0.72)
            paw.offset(x: size * 0.16, y: size * 0.3).scaleEffect(0.72)
        }
    }

    var foxEars: some View {
        ZStack {
            Triangle().fill(baseColor).frame(width: size * 0.2, height: size * 0.24).rotationEffect(.degrees(-18)).offset(x: -size * 0.17, y: -size * 0.25)
            Triangle().fill(baseColor).frame(width: size * 0.2, height: size * 0.24).rotationEffect(.degrees(18)).offset(x: size * 0.17, y: -size * 0.25)
            Triangle().fill(detailColor.opacity(0.55)).frame(width: size * 0.09, height: size * 0.11).rotationEffect(.degrees(-18)).offset(x: -size * 0.17, y: -size * 0.23)
            Triangle().fill(detailColor.opacity(0.55)).frame(width: size * 0.09, height: size * 0.11).rotationEffect(.degrees(18)).offset(x: size * 0.17, y: -size * 0.23)
        }
    }

    var longBunnyEars: some View {
        ZStack {
            Capsule().fill(baseColor).frame(width: size * 0.13, height: size * 0.44).rotationEffect(.degrees(-18)).offset(x: -size * 0.14, y: -size * 0.29)
            Capsule().fill(baseColor).frame(width: size * 0.13, height: size * 0.44).rotationEffect(.degrees(18)).offset(x: size * 0.14, y: -size * 0.29)
            Capsule().fill(detailColor.opacity(0.35)).frame(width: size * 0.06, height: size * 0.31).rotationEffect(.degrees(-18)).offset(x: -size * 0.14, y: -size * 0.29)
            Capsule().fill(detailColor.opacity(0.35)).frame(width: size * 0.06, height: size * 0.31).rotationEffect(.degrees(18)).offset(x: size * 0.14, y: -size * 0.29)
        }
    }

    var stickerFace: some View {
        ZStack {
            Circle().fill(Theme.ink).frame(width: size * 0.045).offset(x: -size * 0.09, y: -size * 0.02)
            Circle().fill(Theme.ink).frame(width: size * 0.045).offset(x: size * 0.09, y: -size * 0.02)
            Circle().fill(.white.opacity(0.85)).frame(width: size * 0.014).offset(x: -size * 0.1, y: -size * 0.03)
            Circle().fill(.white.opacity(0.85)).frame(width: size * 0.014).offset(x: size * 0.08, y: -size * 0.03)
            Circle().fill(Theme.pink.opacity(0.85)).frame(width: size * 0.055).offset(x: -size * 0.16, y: size * 0.05)
            Circle().fill(Theme.pink.opacity(0.85)).frame(width: size * 0.055).offset(x: size * 0.16, y: size * 0.05)
            Path { path in
                path.move(to: CGPoint(x: size * 0.47, y: size * 0.53))
                path.addQuadCurve(to: CGPoint(x: size * 0.5, y: size * 0.56), control: CGPoint(x: size * 0.485, y: size * 0.56))
                path.addQuadCurve(to: CGPoint(x: size * 0.53, y: size * 0.53), control: CGPoint(x: size * 0.515, y: size * 0.56))
            }
            .stroke(Theme.ink, style: StrokeStyle(lineWidth: max(1.4, size * 0.01), lineCap: .round))
        }
    }

    func smallWings(color: Color) -> some View {
        ZStack {
            WingShape().fill(color.opacity(0.92)).frame(width: size * 0.36, height: size * 0.36).rotationEffect(.degrees(-25)).offset(x: -size * 0.24, y: size * 0.05)
            WingShape().fill(color.opacity(0.92)).frame(width: size * 0.36, height: size * 0.36).rotationEffect(.degrees(25)).scaleEffect(x: -1, y: 1).offset(x: size * 0.24, y: size * 0.05)
        }
    }

    func mothWing(side: CGFloat, color: Color) -> some View {
        WingShape()
            .fill(color)
            .overlay(WingShape().stroke(detailColor.opacity(0.7), lineWidth: size * 0.018))
            .frame(width: size * 0.5, height: size * 0.48)
            .scaleEffect(x: side, y: 1)
            .rotationEffect(.degrees(Double(side) * -12))
            .offset(x: side * size * 0.25, y: size * 0.05)
    }

    func fluffyCollar(color: Color) -> some View {
        ZStack {
            ForEach(0..<7, id: \.self) { index in
                Circle().fill(color).frame(width: size * 0.16)
                    .offset(x: size * CGFloat(-0.24 + Double(index) * 0.08), y: size * CGFloat(0.03 + abs(Double(index) - 3) * 0.018))
            }
        }
    }

    var hornPair: some View {
        ZStack {
            horn.offset(x: -size * 0.14, y: -size * 0.04).scaleEffect(0.58)
            horn.offset(x: size * 0.14, y: -size * 0.04).scaleEffect(0.58)
        }
    }

    var blossomCrown: some View {
        ZStack {
            flower(offsetX: -0.18, offsetY: -0.26)
            flower(offsetX: 0.18, offsetY: -0.26)
            flower(offsetX: 0.0, offsetY: -0.3).scaleEffect(0.8)
        }
    }

    func flower(offsetX: CGFloat, offsetY: CGFloat) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(Theme.pink)
                    .frame(width: size * 0.045)
                    .offset(x: cos(Double(index) * .pi * 2 / 5) * size * 0.03,
                            y: sin(Double(index) * .pi * 2 / 5) * size * 0.03)
            }
            Circle().fill(Theme.lemon).frame(width: size * 0.028)
        }
        .offset(x: size * offsetX, y: size * offsetY)
    }

    var heartDetails: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: "heart.fill")
                    .font(.system(size: size * CGFloat([0.04, 0.032, 0.028, 0.035, 0.025][index]), weight: .bold))
                    .foregroundStyle(Theme.pink.opacity(0.75))
                    .offset(x: size * CGFloat([-0.27, 0.31, -0.1, 0.17, 0.02][index]),
                            y: size * CGFloat([-0.2, -0.16, 0.21, 0.25, -0.33][index]))
            }
        }
    }

    var starSprinkles: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: index.isMultiple(of: 2) ? "sparkle" : "star.fill")
                    .font(.system(size: size * CGFloat([0.038, 0.026, 0.032, 0.025][index % 4]), weight: .bold))
                    .foregroundStyle(index.isMultiple(of: 2) ? .white : detailColor)
                    .offset(x: size * CGFloat([-0.3, 0.29, -0.18, 0.12, 0.0, 0.34, -0.34, 0.21][index]),
                            y: size * CGFloat([-0.25, -0.23, 0.18, 0.26, -0.36, 0.02, 0.03, -0.06][index]))
            }
        }
    }

    var seaHead: some View {
        ZStack {
            Circle().fill(baseColor).frame(width: size * 0.3).offset(x: -size * 0.2, y: -size * 0.1)
            Triangle().fill(detailColor.opacity(0.55)).frame(width: size * 0.18, height: size * 0.14).rotationEffect(.degrees(-55)).offset(x: -size * 0.06, y: -size * 0.23)
        }
    }

    var finFan: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Triangle()
                    .fill(detailColor.opacity(0.45))
                    .frame(width: size * 0.12, height: size * 0.16)
                    .rotationEffect(.degrees(-40 + Double(index) * 22))
                    .offset(x: size * CGFloat(-0.02 + Double(index) * 0.06), y: -size * 0.22)
            }
        }
    }

    var snakeTail: some View {
        snakeTail(color: detailColor)
    }

    func snakeTail(color: Color) -> some View {
        ZStack {
            Capsule().fill(color).frame(width: size * 0.12, height: size * 0.42).rotationEffect(.degrees(-48)).offset(x: size * 0.33, y: size * 0.1)
            Circle().fill(color).frame(width: size * 0.13).offset(x: size * 0.44, y: -size * 0.04)
            Circle().fill(Theme.ink).frame(width: size * 0.018).offset(x: size * 0.41, y: -size * 0.06)
        }
    }

    func twinTail(side: CGFloat) -> some View {
        Capsule()
            .fill(baseColor)
            .overlay(Capsule().stroke(detailColor.opacity(0.75), lineWidth: size * 0.016))
            .frame(width: size * 0.13, height: size * 0.56)
            .rotationEffect(.degrees(Double(side) * -35))
            .offset(x: side * size * 0.26, y: -size * 0.02)
    }

    var finRow: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Triangle().fill(detailColor.opacity(0.55)).frame(width: size * 0.11, height: size * 0.12)
                    .offset(x: size * CGFloat(-0.12 + Double(index) * 0.12), y: size * CGFloat(0.0 - Double(index) * 0.03))
            }
        }
    }

    var fluffyHair: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Circle().fill(baseColor).frame(width: size * 0.16)
                    .offset(x: size * CGFloat(-0.16 + Double(index) * 0.08), y: -size * CGFloat(0.28 + Double(index % 2) * 0.04))
            }
        }
    }

    var leafHat: some View {
        ZStack {
            Capsule().fill(Color(hex: "#5BAB60")).frame(width: size * 0.46, height: size * 0.12).offset(y: -size * 0.3)
            LeafShape().fill(Color(hex: "#5BAB60")).frame(width: size * 0.2, height: size * 0.13).rotationEffect(.degrees(-20)).offset(y: -size * 0.39)
        }
    }

    var cucumber: some View {
        Capsule()
            .fill(Color(hex: "#78C874"))
            .overlay(Capsule().stroke(Color(hex: "#3F9653"), lineWidth: size * 0.012))
            .frame(width: size * 0.18, height: size * 0.4)
            .rotationEffect(.degrees(-12))
            .offset(y: size * 0.19)
    }
}

private struct BubbleCluster: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .stroke(.white.opacity(0.9), lineWidth: 3)
                    .background(Circle().fill(Theme.sky.opacity(0.18)))
                    .frame(width: size * CGFloat([0.1, 0.08, 0.12, 0.07][index % 4]))
                    .offset(x: xOffset(index), y: yOffset(index))
            }
        }
    }

    private func xOffset(_ index: Int) -> CGFloat {
        [-0.24, 0.25, -0.1, 0.12, -0.32, 0.32, -0.02, 0.22][index] * size
    }

    private func yOffset(_ index: Int) -> CGFloat {
        [0.12, 0.14, 0.28, 0.25, -0.02, 0.0, 0.34, 0.31][index] * size
    }
}

private struct SpriteImage: View {
    let name: String

    var body: some View {
        Group {
            if let uiImage = UIImage.spriteImage(named: name) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Theme.pink)
                    .padding(36)
            }
        }
    }
}

struct ItemArtView: View {
    let effect: ItemEffect
    var size: CGFloat = 68

    var body: some View {
        Group {
            if let imageName {
                SpriteImage(name: imageName)
                    .padding(2)
            } else {
                Image(systemName: symbol)
                    .font(.system(size: size * 0.5, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Circle().fill(Theme.mint.opacity(0.75)))
            }
        }
        .frame(width: size, height: size)
    }

    private var imageName: String? {
        switch effect {
        case .food: return "food-mochi"
        case .caviar: return "golden-caviar"
        case .darkCloak: return "item-dark-cloak"
        case .lightDress: return "item-light-dress"
        case .crown: return "item-pretty-crown"
        case .collar: return "item-jeweled-collar"
        }
    }

    private var symbol: String {
        switch effect {
        case .darkCloak: return "moon.stars.fill"
        case .lightDress: return "tshirt.fill"
        case .crown: return "crown.fill"
        case .collar: return "sparkles"
        case .food: return "takeoutbag.and.cup.and.straw.fill"
        case .caviar: return "birthday.cake.fill"
        }
    }
}

private extension UIImage {
    static func spriteImage(named name: String) -> UIImage? {
        if let image = UIImage(named: name) {
            return image
        }
        guard let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "SpriteImages") else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct WingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.12, y: rect.minY + rect.height * 0.12),
            control1: CGPoint(x: rect.width * 0.78, y: rect.height * 0.05),
            control2: CGPoint(x: rect.width * 0.35, y: rect.height * 0.0)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.maxY - rect.height * 0.16),
            control1: CGPoint(x: rect.width * 0.03, y: rect.height * 0.32),
            control2: CGPoint(x: rect.width * 0.02, y: rect.height * 0.64)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(x: rect.width * 0.43, y: rect.height * 0.96),
            control2: CGPoint(x: rect.width * 0.77, y: rect.height * 0.84)
        )
        path.closeSubpath()
        return path
    }
}

private struct BowLoop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.12),
            control1: CGPoint(x: rect.width * 0.74, y: rect.height * 0.02),
            control2: CGPoint(x: rect.width * 0.3, y: rect.height * 0.02)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(x: rect.width * 0.1, y: rect.height * 0.72),
            control2: CGPoint(x: rect.width * 0.62, y: rect.height * 0.98)
        )
        path.closeSubpath()
        return path
    }
}

private struct BatWingShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.3))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.1, y: rect.minY + rect.height * 0.05))
        path.addCurve(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.maxY * 0.95),
                      control1: CGPoint(x: rect.minX - rect.width * 0.05, y: rect.height * 0.45),
                      control2: CGPoint(x: rect.width * 0.08, y: rect.height * 0.78))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.46, y: rect.height * 0.72),
                          control: CGPoint(x: rect.width * 0.32, y: rect.height * 0.9))
        path.addQuadCurve(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.82),
                          control: CGPoint(x: rect.width * 0.57, y: rect.height * 0.98))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.3),
                          control: CGPoint(x: rect.width * 0.78, y: rect.height * 0.46))
        path.closeSubpath()
        return path
    }
}

private struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                      control1: CGPoint(x: rect.width * 0.25, y: rect.minY),
                      control2: CGPoint(x: rect.width * 0.75, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.midY),
                      control1: CGPoint(x: rect.width * 0.75, y: rect.maxY),
                      control2: CGPoint(x: rect.width * 0.25, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct CrownShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width * 0.25, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
