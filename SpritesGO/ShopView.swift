import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var store: GameStore
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 14)]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                CloseButton { store.goHome() }
                Spacer()
                VStack {
                    Text(store.text("shop").uppercased()).font(.system(.largeTitle, design: .rounded).weight(.black))
                    Text("\(store.text("dollars")): \(store.moneyText)").font(.headline.bold())
                }
                Spacer()
                Color.clear.frame(width: 46, height: 46)
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    shopSection(store.text("pet_store"), price: "$50.00") {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(store.shopSprites) { sprite in
                                Button {
                                    store.buy(sprite: sprite)
                                } label: {
                                    VStack(spacing: 8) {
                                        SpriteArtView(sprite: sprite, size: 108)
                                        Text(sprite.name).font(.system(.subheadline, design: .rounded).weight(.black))
                                        Text(sprite.personality).font(.caption).multilineTextAlignment(.center).lineLimit(2)
                                        Text("\(store.text("buy_pet")) · $50.00")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Capsule().fill(Theme.lemon))
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 210)
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.68)))
                                }
                                .buttonStyle(.plain)
                                .disabled(store.state.money < 50)
                            }
                        }
                    }

                    shopSection(store.text("consumable_items"), price: "$10.00") {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(SpriteCatalog.shopItems) { item in
                                Button {
                                    store.buy(item: item)
                                } label: {
                                    shopCard(title: item.name, subtitle: item.isConsumable ? store.text("use_once") : store.text("reusable"), effect: item.effect)
                                }
                                .buttonStyle(.plain)
                                .disabled(store.state.money < 10)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func shopSection<Content: View>(_ title: String, price: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title).font(.system(.title3, design: .rounded).weight(.black))
                Spacer()
                Text(price).font(.headline.bold()).padding(.horizontal, 12).padding(.vertical, 6).background(Capsule().fill(Theme.lemon))
            }
            content()
        }
    }

    private func shopCard(title: String, subtitle: String, effect: ItemEffect) -> some View {
        VStack(spacing: 10) {
            ItemArtView(effect: effect, size: 68)
            Text(title).font(.system(.subheadline, design: .rounded).weight(.black)).multilineTextAlignment(.center)
            Text(subtitle).font(.caption.bold()).foregroundStyle(Theme.coral)
        }
        .frame(maxWidth: .infinity, minHeight: 142)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white.opacity(0.68)))
    }

}
