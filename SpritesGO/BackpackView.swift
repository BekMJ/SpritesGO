import SwiftUI

struct BackpackView: View {
    @EnvironmentObject private var store: GameStore

    private let columns = [GridItem(.adaptive(minimum: 132), spacing: 14)]

    var body: some View {
        VStack(spacing: 10) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    section(store.text("sprites")) {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(store.ownedSprites) { sprite in
                                Button {
                                    store.select(sprite: sprite)
                                } label: {
                                    VStack(spacing: 8) {
                                        SpriteArtView(sprite: sprite, effects: store.effects(for: sprite), size: 96)
                                        Text(sprite.name)
                                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                                        if sprite.id == store.state.activeSpriteID {
                                            Text(store.text("active")).font(.caption.bold()).foregroundStyle(Theme.coral)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(cardFill(active: sprite.id == store.state.activeSpriteID))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    ForEach(ItemCategory.allCases) { category in
                        section(categoryName(category)) {
                                    let items = store.state.ownedItems.filter { $0.category == category }
                                    if items.isEmpty {
                                emptyText(store.text("no_items"))
                            } else {
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                                        Button {
                                            store.apply(item: item)
                                        } label: {
                                            VStack(spacing: 8) {
                                                itemIcon(item)
                                                Text(item.name)
                                                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                                                    .multilineTextAlignment(.center)
                                                Text(statusText(for: item))
                                                    .font(.caption.bold())
                                                    .foregroundStyle(Theme.coral)
                                            }
                                            .frame(maxWidth: .infinity, minHeight: 130)
                                            .padding(10)
                                            .background(cardFill(active: false))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }

    private var header: some View {
        HStack {
            CloseButton { store.goHome() }
            Spacer()
            Text(store.text("backpack")).font(.system(.largeTitle, design: .rounded).weight(.black))
            Spacer()
            Color.clear.frame(width: 46, height: 46)
        }
        .padding()
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(.title3, design: .rounded).weight(.black))
            content()
        }
    }

    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.system(.subheadline, design: .rounded).weight(.semibold))
            .foregroundStyle(Theme.ink.opacity(0.68))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.46)))
    }

    private func cardFill(active: Bool) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(active ? Theme.lemon.opacity(0.9) : .white.opacity(0.68))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(active ? Theme.coral : .white.opacity(0.5), lineWidth: active ? 3 : 1))
    }

    private func itemIcon(_ item: InventoryItem) -> some View {
        ItemArtView(effect: item.effect, size: 62)
    }

    private func statusText(for item: InventoryItem) -> String {
        if item.isConsumable && item.category != .food {
            return store.text("use_once")
        }
        return store.isApplied(item) ? store.text("unequip") : store.text("equip")
    }

    private func categoryName(_ category: ItemCategory) -> String {
        switch category {
        case .clothing: return store.text("clothing")
        case .food: return store.text("food")
        case .accessory: return store.text("accessories")
        }
    }
}
