import SwiftUI

struct SalonView: View {
    @EnvironmentObject private var store: GameStore
    @State private var selectedTool: SalonTool = .brush
    @State private var effects = SalonEffects()
    @State private var didReward = false
    @State private var waterPhase = false

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                HStack {
                    CloseButton { finishAndLeave() }
                    Spacer()
                    Text(store.text("salon")).font(.system(.title, design: .rounded).weight(.black))
                    Spacer()
                    Color.clear.frame(width: 46, height: 46)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                ScrollView {
                    VStack(spacing: 12) {
                        ZStack {
                            SalonRoomBackground(waterOn: effects.showered, waterPhase: waterPhase)

                            SpriteArtView(sprite: store.activeSprite, effects: store.effects(for: store.activeSprite), salonEffects: effects, size: min(210, proxy.size.width * 0.5))
                                .gesture(DragGesture(minimumDistance: 8).onChanged { _ in applySelectedTool() })
                                .onTapGesture { applySelectedTool() }
                                .accessibilityLabel("Salon creature")
                        }
                        .frame(height: min(286, proxy.size.height * 0.42))

                        Text("\(store.text("tap_brush")) \(toolName(selectedTool).lowercased())")
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }

                toolTray
            }
            .safeAreaPadding(.bottom, 8)
        }
        .onAppear { waterPhase = true }
        .onDisappear { effects = SalonEffects() }
    }

    private var toolTray: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(SalonTool.allCases) { tool in
                    Button {
                        selectedTool = tool
                        apply(tool)
                    } label: {
                        Label(toolName(tool), systemImage: tool.symbolName)
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, minHeight: 38)
                    }
                    .buttonStyle(PastelButtonStyle(color: selectedTool == tool ? Theme.lemon : Theme.sky))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 4)
        .background(.ultraThinMaterial)
    }

    private func toolName(_ tool: SalonTool) -> String {
        switch tool {
        case .brush: return store.text("brush")
        case .dryer: return store.text("hair_dryer")
        case .shampoo: return store.text("shampoo")
        case .shower: return store.text("shower")
        }
    }

    private func applySelectedTool() {
        apply(selectedTool)
    }

    private func apply(_ tool: SalonTool) {
        SpriteAudio.shared.play(tool == .shower ? .shower : .item, volume: store.state.settings.volume)
        switch tool {
        case .brush: effects.brushed = true
        case .dryer: effects.dried = true
        case .shampoo:
            effects.shampooed = true
            effects.showered = false
        case .shower:
            effects = SalonEffects()
            effects.showered = true
        }
    }

    private func finishAndLeave() {
        if effects.hasProgress && !didReward {
            didReward = true
            store.completeSalonSession()
        }
        effects = SalonEffects()
        store.goHome()
    }
}

private struct SalonRoomBackground: View {
    let waterOn: Bool
    let waterPhase: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(colors: [Color(hex: "#FFF2F7"), Theme.sky.opacity(0.75), Theme.mint.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))

            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.42))
                .frame(width: 190, height: 150)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.lemon.opacity(0.8), lineWidth: 8))
                .offset(y: -34)

            HStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { _ in
                    Circle().fill(Theme.lemon.opacity(0.9)).frame(width: 16)
                }
            }
            .offset(y: -124)

            RoundedRectangle(cornerRadius: 18)
                .fill(Color(hex: "#FFD8C9").opacity(0.85))
                .frame(height: 44)
                .offset(y: 104)

            HStack(spacing: 10) {
                bottle(color: Theme.pink)
                bottle(color: Theme.sky)
                bottle(color: Theme.mint)
                Image(systemName: "scissors")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.ink.opacity(0.55))
            }
            .offset(x: -92, y: 83)

            Image(systemName: "shower.fill")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(Theme.sky)
                .offset(x: 114, y: -84)
                .opacity(waterOn ? 1 : 0.35)

            if waterOn {
                ForEach(0..<7, id: \.self) { index in
                    Capsule()
                        .fill(Theme.sky.opacity(0.75))
                        .frame(width: 5, height: CGFloat([54, 72, 62, 84, 58, 75, 66][index]))
                        .offset(x: CGFloat(index * 10 - 30), y: waterPhase ? 26 : -6)
                        .animation(.easeInOut(duration: 0.55).repeatForever(autoreverses: false).delay(Double(index) * 0.06), value: waterPhase)
                }
                .offset(x: 106, y: -36)
            }
        }
    }

    private func bottle(color: Color) -> some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3).fill(color.opacity(0.9)).frame(width: 14, height: 8)
            RoundedRectangle(cornerRadius: 5).fill(color.opacity(0.82)).frame(width: 24, height: 34)
        }
    }
}
