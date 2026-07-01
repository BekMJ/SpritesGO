import SwiftUI

@main
struct SpritesGOApp: App {
    @StateObject private var store = GameStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.background.ignoresSafeArea())
        }
    }
}
