import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch store.screen {
            case .home:
                HomeView()
            case .settings:
                SettingsView()
            case .backpack:
                BackpackView()
            case .shop:
                ShopView()
            case .salon:
                SalonView()
            case .arCamera:
                ARCameraView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
        .font(Theme.roundedFont)
        .foregroundStyle(Theme.ink)
        .onAppear {
            SpriteAudio.shared.startMusic(volume: store.state.settings.volume)
        }
        .onChange(of: store.state.settings.volume) { _, newValue in
            SpriteAudio.shared.updateMusicVolume(newValue)
        }
    }
}
