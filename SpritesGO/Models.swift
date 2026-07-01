import Foundation
import SwiftUI

enum Screen: String, Codable {
    case home
    case settings
    case backpack
    case shop
    case salon
    case arCamera
}

enum ItemCategory: String, Codable, CaseIterable, Identifiable {
    case clothing = "Clothing"
    case food = "Food"
    case accessory = "Accessories"

    var id: String { rawValue }
}

struct SpriteDefinition: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let bodyHex: String
    let accentHex: String
    let detailHex: String
    let personality: String
    var imageName: String? = nil
}

struct InventoryItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: ItemCategory
    let isConsumable: Bool
    let effect: ItemEffect
}

enum ItemEffect: String, Codable, CaseIterable {
    case food
    case darkCloak
    case lightDress
    case crown
    case collar
    case caviar
}

struct AppSettings: Codable, Equatable {
    var volume: VolumeLevel = .moderate
    var language: Language = .english
    var brightness: Brightness = .normal
}

enum VolumeLevel: String, Codable, CaseIterable, Identifiable {
    case quiet = "Quiet"
    case moderate = "Moderate"
    case loud = "Loud"

    var id: String { rawValue }
}

enum Language: String, Codable, CaseIterable, Identifiable {
    case english = "English"
    case spanish = "Spanish"
    case chinese = "Chinese"
    case japanese = "Japanese"
    case french = "French"

    var id: String { rawValue }
}

enum Brightness: String, Codable, CaseIterable, Identifiable {
    case faint = "Faint"
    case normal = "Normal"
    case bright = "Bright"

    var id: String { rawValue }
}

struct GameState: Codable {
    var money: Decimal = 100
    var ownedSpriteIDs: [String] = ["flame-fox"]
    var activeSpriteID: String = "flame-fox"
    var ownedItems: [InventoryItem] = []
    var appliedEffectsBySpriteID: [String: Set<ItemEffect>] = [:]
    var settings = AppSettings()
}

enum SalonTool: String, CaseIterable, Identifiable {
    case brush = "Brush"
    case dryer = "Hair Dryer"
    case shampoo = "Shampoo"
    case shower = "Shower"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .brush: return "paintbrush.fill"
        case .dryer: return "wind"
        case .shampoo: return "bubbles.and.sparkles.fill"
        case .shower: return "shower.fill"
        }
    }
}

struct SalonEffects: Equatable {
    var brushed = false
    var dried = false
    var shampooed = false
    var showered = false

    var hasProgress: Bool {
        brushed || dried || shampooed || showered
    }
}
