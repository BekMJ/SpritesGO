import Foundation

enum SpriteCatalog {
    static let flameFox = SpriteDefinition(
        id: "flame-fox",
        name: "Suki Kitsune",
        bodyHex: "#FFF7F2",
        accentHex: "#FFC2CA",
        detailHex: "#FF757E",
        personality: "Rose-bright, loyal, and full of tiny sparks.",
        imageName: "suki-kitsune"
    )

    static let sprites: [SpriteDefinition] = {
        let referenceCreatures = [
            SpriteDefinition(id: "wolpertinger", name: "Wolpertinger", bodyHex: "#FFD6E7", accentHex: "#FFF9F4", detailHex: "#B98FBF", personality: "Tiny, shy, and glitter-winged.", imageName: "wolpertinger"),
            SpriteDefinition(id: "pink-mothman", name: "Pink Mothman", bodyHex: "#FFD2D2", accentHex: "#FFF1F3", detailHex: "#E89AAA", personality: "Soft, watchful, and fond of moonlight.", imageName: "pink-mothman"),
            SpriteDefinition(id: "leviathan", name: "Leviathan", bodyHex: "#B8F5F1", accentHex: "#F4F2FF", detailHex: "#75C7D8", personality: "Flowing, calm, and star-speckled.", imageName: "leviathan"),
            SpriteDefinition(id: "starry-chimera", name: "Starry-Night Chimera", bodyHex: "#E8ECFF", accentHex: "#44435A", detailHex: "#789BFF", personality: "Dreamy, cosmic, and quietly brave.", imageName: "starry-chimera"),
            SpriteDefinition(id: "pink-chimera", name: "Pink Chimera", bodyHex: "#FFF7F1", accentHex: "#FFD5E4", detailHex: "#DF6B70", personality: "Playful, plush, and ribbon-proud.", imageName: "pink-chimera"),
            SpriteDefinition(id: "sakura-bakeneko", name: "Sakura Bakeneko", bodyHex: "#FFF5F5", accentHex: "#FFD5DC", detailHex: "#E56F73", personality: "Sweet, mischievous, and blossom-scented.", imageName: "sakura-bakeneko"),
            SpriteDefinition(id: "nessie", name: "Nessie", bodyHex: "#BFE8C9", accentHex: "#F7F7D8", detailHex: "#4EA36E", personality: "Gentle, splashy, and secretly sparkly.", imageName: "nessie"),
            SpriteDefinition(id: "yeti", name: "Yeti", bodyHex: "#F7FAFF", accentHex: "#D9F5FF", detailHex: "#3C55BF", personality: "Fluffy, bashful, and snow-soft.", imageName: "yeti"),
            SpriteDefinition(id: "kappa", name: "Kappa", bodyHex: "#C8EFC9", accentHex: "#F5F7C8", detailHex: "#4EA35D", personality: "Helpful, leafy, and cucumber-obsessed.", imageName: "kappa"),
            SpriteDefinition(id: "moon-bat-cat", name: "Moon Bat Cat", bodyHex: "#7F688A", accentHex: "#CFC0E8", detailHex: "#F2A7C3", personality: "Sleepy, dramatic, and night-cuddly.", imageName: "black-mothman"),
            SpriteDefinition(id: "photo-kitsune", name: "Kitsune", bodyHex: "#FFFDF8", accentHex: "#E8EDFF", detailHex: "#FF6D72", personality: "Bright, watchful, and nine-tailed.", imageName: "kitsune"),
            SpriteDefinition(id: "enfield", name: "Enfield", bodyHex: "#58EAF2", accentHex: "#D4FCFF", detailHex: "#143A91", personality: "Swift, clever, and cloud-soft.", imageName: "enfield"),
            SpriteDefinition(id: "kelpie", name: "Kelpie", bodyHex: "#75E8C8", accentHex: "#B9F8E9", detailHex: "#14815D", personality: "Leafy, gentle, and water-loving.", imageName: "kelpie"),
            SpriteDefinition(id: "tanuki", name: "Tanuki", bodyHex: "#CA9A6B", accentHex: "#FFE4C7", detailHex: "#8E1717", personality: "Cozy, playful, and snack-seeking.", imageName: "tanuki"),
            SpriteDefinition(id: "deer-monster", name: "Deer Monster", bodyHex: "#6D5149", accentHex: "#FFF8F2", detailHex: "#941816", personality: "Quiet, mysterious, and forest-kind.", imageName: "deer-monster"),
            SpriteDefinition(id: "griffin", name: "Griffin", bodyHex: "#FFFDF8", accentHex: "#D09A48", detailHex: "#8A3A0A", personality: "Loyal, proud, and feather-soft.", imageName: "griffin")
        ]
        return [flameFox] + referenceCreatures
    }()

    static let shopItems: [InventoryItem] = [
        InventoryItem(id: "sprite-food", name: "Sprite Food", category: .food, isConsumable: true, effect: .food),
        InventoryItem(id: "dark-cloak", name: "Dark Cloak", category: .clothing, isConsumable: false, effect: .darkCloak),
        InventoryItem(id: "light-dress", name: "Light Dress", category: .clothing, isConsumable: false, effect: .lightDress),
        InventoryItem(id: "pretty-crown", name: "Pretty Crown", category: .accessory, isConsumable: false, effect: .crown),
        InventoryItem(id: "jeweled-collar", name: "Jeweled Collar", category: .accessory, isConsumable: false, effect: .collar),
        InventoryItem(id: "golden-shrimp-caviar", name: "Golden Shrimp Caviar", category: .food, isConsumable: true, effect: .caviar)
    ]

    static func sprite(id: String) -> SpriteDefinition {
        sprites.first { $0.id == id } ?? flameFox
    }

}
