import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#endif

@MainActor
final class GameStore: ObservableObject {
    @Published var screen: Screen = .home
    @Published private(set) var state: GameState

    private let saveKey = "SpritesGO.GameState.v1"

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(GameState.self, from: data) {
            state = decoded
        } else {
            state = GameState()
        }

        if ProcessInfo.processInfo.arguments.contains("-openSalon") {
            screen = .salon
        } else if ProcessInfo.processInfo.arguments.contains("-openShop") {
            screen = .shop
        } else if ProcessInfo.processInfo.arguments.contains("-openPlay") {
            screen = .arCamera
        }
    }

    var moneyText: String {
        let value = NSDecimalNumber(decimal: state.money).doubleValue
        return String(format: "$%.2f", value)
    }

    var activeSprite: SpriteDefinition {
        SpriteCatalog.sprite(id: state.activeSpriteID)
    }

    var ownedSprites: [SpriteDefinition] {
        SpriteCatalog.sprites.filter { state.ownedSpriteIDs.contains($0.id) }
    }

    var shopSprites: [SpriteDefinition] {
        SpriteCatalog.sprites.filter { !state.ownedSpriteIDs.contains($0.id) }
    }

    func goHome() {
        screen = .home
    }

    func navigate(to screen: Screen) {
        self.screen = screen
    }

    func buy(item: InventoryItem) {
        guard spend(10) else { return }
        state.ownedItems.append(item)
        SpriteAudio.shared.play(.item, volume: state.settings.volume)
        persistAndCelebrate()
    }

    func buy(sprite: SpriteDefinition) {
        guard !state.ownedSpriteIDs.contains(sprite.id), spend(50) else { return }
        state.ownedSpriteIDs.append(sprite.id)
        SpriteAudio.shared.play(.item, volume: state.settings.volume)
        persistAndCelebrate()
    }

    func select(sprite: SpriteDefinition) {
        guard state.ownedSpriteIDs.contains(sprite.id) else { return }
        state.activeSpriteID = sprite.id
        persist()
    }

    func apply(item: InventoryItem) {
        if !item.isConsumable || item.category == .food {
            toggle(item: item)
            return
        }

        var effects = state.appliedEffectsBySpriteID[state.activeSpriteID] ?? []
        effects.insert(item.effect)
        state.appliedEffectsBySpriteID[state.activeSpriteID] = effects

        if let index = state.ownedItems.firstIndex(where: { $0.id == item.id }) {
            state.ownedItems.remove(at: index)
            addMoney(2)
        }
        SpriteAudio.shared.play(.treat, volume: state.settings.volume)
        persistAndCelebrate()
    }

    func toggle(item: InventoryItem) {
        var effects = state.appliedEffectsBySpriteID[state.activeSpriteID] ?? []
        if effects.contains(item.effect) {
            effects.remove(item.effect)
        } else {
            effects.insert(item.effect)
        }
        state.appliedEffectsBySpriteID[state.activeSpriteID] = effects
        SpriteAudio.shared.play(sound(for: item.effect), volume: state.settings.volume)
        persistAndCelebrate()
    }

    func isApplied(_ item: InventoryItem) -> Bool {
        effects(for: activeSprite).contains(item.effect)
    }

    func completeSalonSession() {
        addMoney(10)
        persistAndCelebrate()
    }

    func updateSettings(_ settings: AppSettings) {
        state.settings = settings
        SpriteAudio.shared.updateMusicVolume(settings.volume)
        persist()
    }

    func effects(for sprite: SpriteDefinition) -> Set<ItemEffect> {
        state.appliedEffectsBySpriteID[sprite.id] ?? []
    }

    private func spend(_ amount: Decimal) -> Bool {
        guard state.money >= amount else { return false }
        state.money -= amount
        return true
    }

    private func addMoney(_ amount: Decimal) {
        state.money += amount
    }

    private func persistAndCelebrate() {
        persist()
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        #endif
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    func text(_ key: String) -> String {
        LocalizedStrings.text(key, language: state.settings.language)
    }

    private func sound(for effect: ItemEffect) -> SpriteSound {
        switch effect {
        case .food, .caviar: return .treat
        case .darkCloak, .lightDress, .crown, .collar: return .equip
        }
    }
}

enum LocalizedStrings {
    static func text(_ key: String, language: Language) -> String {
        guard language != .english else { return english[key] ?? key }
        return tables[language]?[key] ?? english[key] ?? key
    }

    private static let english: [String: String] = [
        "app_title": "Sprites GO",
        "settings": "Settings",
        "backpack": "Backpack",
        "shop": "Shop",
        "salon": "Salon",
        "play_with": "Play with",
        "dollars": "Dollars",
        "consumable_items": "Consumable Items",
        "pet_store": "Pet Store",
        "buy_pet": "Buy pet",
        "owned": "Owned",
        "sprites": "Sprites",
        "active": "Active",
        "use_once": "Use once",
        "reusable": "Reusable",
        "equip": "Equip",
        "unequip": "Unequip",
        "no_items": "No items yet.",
        "clothing": "Clothing",
        "food": "Food",
        "accessories": "Accessories",
        "volume": "Volume",
        "language": "Language",
        "brightness": "Brightness",
        "creators": "Creators",
        "tap_brush": "Tap or brush with the",
        "brush": "Brush",
        "hair_dryer": "Hair Dryer",
        "shampoo": "Shampoo",
        "shower": "Shower",
        "tap_sprite": "Tap your sprite or choose an action!",
        "pet": "Pet",
        "treat": "Treat",
        "jump": "Jump",
        "spin": "Spin",
        "purr": "Purr... your pet loves that! 💕",
        "yum": "Yum! Your pet ate the treat! ✨",
        "boing": "Boing! A real happy jump!",
        "twirl": "A sparkly victory twirl!"
    ]

    private static let tables: [Language: [String: String]] = [
        .spanish: [
            "app_title": "Sprites GO", "settings": "Ajustes", "backpack": "Mochila", "shop": "Tienda", "salon": "Salón",
            "play_with": "Jugar con", "dollars": "Dólares", "consumable_items": "Consumibles", "pet_store": "Tienda de mascotas",
            "buy_pet": "Comprar mascota", "owned": "Comprado", "sprites": "Sprites", "active": "Activo", "use_once": "Usar una vez",
            "reusable": "Reutilizable", "equip": "Equipar", "unequip": "Quitar", "no_items": "No hay objetos todavía.",
            "clothing": "Ropa", "food": "Comida", "accessories": "Accesorios",
            "volume": "Volumen", "language": "Idioma", "brightness": "Brillo", "creators": "Creadores",
            "tap_brush": "Toca o cepilla con", "brush": "Cepillo", "hair_dryer": "Secador", "shampoo": "Champú", "shower": "Ducha",
            "tap_sprite": "¡Toca tu sprite o elige una acción!", "pet": "Acariciar", "treat": "Premio", "jump": "Saltar", "spin": "Girar",
            "purr": "Ronronea... ¡le encanta! 💕", "yum": "¡Ñam! ¡Se comió el premio! ✨", "boing": "¡Boing! ¡Qué salto feliz!", "twirl": "¡Un giro brillante!"
        ],
        .chinese: [
            "app_title": "精灵 GO", "settings": "设置", "backpack": "背包", "shop": "商店", "salon": "美容屋",
            "play_with": "一起玩", "dollars": "金币", "consumable_items": "消耗品", "pet_store": "宠物商店",
            "buy_pet": "购买宠物", "owned": "已拥有", "sprites": "精灵", "active": "当前", "use_once": "使用一次",
            "reusable": "可重复使用", "equip": "装备", "unequip": "卸下", "no_items": "还没有物品。",
            "clothing": "服装", "food": "食物", "accessories": "配饰",
            "volume": "音量", "language": "语言", "brightness": "亮度", "creators": "创作者",
            "tap_brush": "点击或使用", "brush": "刷子", "hair_dryer": "吹风机", "shampoo": "洗发水", "shower": "淋浴",
            "tap_sprite": "点击精灵或选择动作！", "pet": "抚摸", "treat": "喂食", "jump": "跳跃", "spin": "旋转",
            "purr": "呼噜... 它很喜欢！💕", "yum": "好吃！它吃掉了点心！✨", "boing": "蹦！开心地跳起来！", "twirl": "闪亮转圈！"
        ],
        .japanese: [
            "app_title": "スプライトGO", "settings": "設定", "backpack": "バッグ", "shop": "ショップ", "salon": "サロン",
            "play_with": "あそぶ", "dollars": "ドル", "consumable_items": "消耗品", "pet_store": "ペットショップ",
            "buy_pet": "ペットを買う", "owned": "所持中", "sprites": "スプライト", "active": "選択中", "use_once": "一回使う",
            "reusable": "何度も使える", "equip": "装備", "unequip": "外す", "no_items": "まだアイテムがありません。",
            "clothing": "服", "food": "食べ物", "accessories": "アクセサリー",
            "volume": "音量", "language": "言語", "brightness": "明るさ", "creators": "制作者",
            "tap_brush": "タップ、または使う", "brush": "ブラシ", "hair_dryer": "ドライヤー", "shampoo": "シャンプー", "shower": "シャワー",
            "tap_sprite": "スプライトをタップするか行動を選んで！", "pet": "なでる", "treat": "ごはん", "jump": "ジャンプ", "spin": "回る",
            "purr": "ごろごろ… 喜んでる！💕", "yum": "もぐもぐ！食べたよ！✨", "boing": "ぴょん！元気にジャンプ！", "twirl": "きらきらターン！"
        ],
        .french: [
            "app_title": "Sprites GO", "settings": "Réglages", "backpack": "Sac", "shop": "Boutique", "salon": "Salon",
            "play_with": "Jouer avec", "dollars": "Dollars", "consumable_items": "Objets consommables", "pet_store": "Animalerie",
            "buy_pet": "Acheter animal", "owned": "Possédé", "sprites": "Sprites", "active": "Actif", "use_once": "Usage unique",
            "reusable": "Réutilisable", "equip": "Équiper", "unequip": "Retirer", "no_items": "Aucun objet pour l’instant.",
            "clothing": "Vêtements", "food": "Nourriture", "accessories": "Accessoires",
            "volume": "Volume", "language": "Langue", "brightness": "Luminosité", "creators": "Créateurs",
            "tap_brush": "Touchez ou utilisez", "brush": "Brosse", "hair_dryer": "Sèche-cheveux", "shampoo": "Shampooing", "shower": "Douche",
            "tap_sprite": "Touchez votre sprite ou choisissez une action !", "pet": "Caresser", "treat": "Friandise", "jump": "Sauter", "spin": "Tourner",
            "purr": "Ronron... il adore ça ! 💕", "yum": "Miam ! Il a mangé la friandise ! ✨", "boing": "Boing ! Un vrai saut joyeux !", "twirl": "Une pirouette brillante !"
        ]
    ]
}
