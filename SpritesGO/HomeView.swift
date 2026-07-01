import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.height < 850
            ScrollView {
                VStack(spacing: compact ? 10 : 16) {
                    VStack(spacing: 6) {
                        Text(store.text("app_title"))
                            .font(.system(size: compact ? 38 : 46, weight: .black, design: .rounded))
                        Text(store.moneyText)
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(.white.opacity(0.72)))
                    }

                    SpriteArtView(
                        sprite: store.activeSprite,
                        effects: store.effects(for: store.activeSprite),
                        size: min(proxy.size.width * 0.5, compact ? 150 : 205)
                    )

                    Button { store.navigate(to: .arCamera) } label: {
                        Label("\(store.text("play_with").uppercased()) \(store.activeSprite.name.uppercased())", systemImage: "sparkles")
                            .font(.system(.headline, design: .rounded).weight(.black))
                            .frame(maxWidth: .infinity, minHeight: compact ? 38 : 48)
                    }
                    .buttonStyle(PastelButtonStyle(color: Theme.lemon))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        menuButton("gearshape.fill", label: store.text("settings"), color: Theme.lavender) { store.navigate(to: .settings) }
                        menuButton("backpack.fill", label: store.text("backpack"), color: Theme.sky) { store.navigate(to: .backpack) }
                        menuButton("bag.fill", label: store.text("shop"), color: Theme.pink) { store.navigate(to: .shop) }
                        menuButton("wand.and.stars", label: store.text("salon"), color: Theme.mint) { store.navigate(to: .salon) }
                    }
                }
                .frame(minHeight: proxy.size.height - 12, alignment: .center)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func menuButton(_ name: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: name)
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .frame(maxWidth: .infinity, minHeight: 34)
        }
        .buttonStyle(PastelButtonStyle(color: color))
    }
}
