import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: GameStore
    @State private var settings = AppSettings()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                CloseButton { store.goHome() }
                Spacer()
                Text(store.text("settings")).font(.system(.title, design: .rounded).weight(.black))
                Spacer()
                Color.clear.frame(width: 46, height: 46)
            }
            .padding()

            ScrollView {
                VStack(spacing: 18) {
                    sectionTitle(store.text("settings").uppercased())
                    picker(store.text("volume"), selection: $settings.volume)
                    picker(store.text("language"), selection: $settings.language)
                    picker(store.text("brightness"), selection: $settings.brightness)

                    sectionTitle(store.text("creators").uppercased())
                    creatorCard(name: "Ericcopter", role: "Creator", description: "Shapes the cozy creature world and playful pet experience.")
                    creatorCard(name: "Shima", role: "Creator", description: "Guides the cute sprite style, mood, and game feel.")
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .onAppear { settings = store.state.settings }
        .onChange(of: settings) { _, newValue in store.updateSettings(newValue) }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(.title3, design: .rounded).weight(.black))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }

    private func creatorCard(name: String, role: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name).font(.system(.headline, design: .rounded).weight(.black))
            Text(role).font(.system(.subheadline, design: .rounded).weight(.bold)).foregroundStyle(Theme.coral)
            Text(description).font(.system(.footnote, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(.white.opacity(0.72)))
    }

    private func picker<Value: CaseIterable & Identifiable & RawRepresentable & Hashable>(_ title: String, selection: Binding<Value>) -> some View where Value.RawValue == String, Value.AllCases: RandomAccessCollection {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.system(.headline, design: .rounded).weight(.bold))
            Picker(title, selection: selection) {
                ForEach(Value.allCases) { value in Text(displayValue(value.rawValue)).tag(value) }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 16).fill(.white.opacity(0.76)))
        }
    }

    private func displayValue(_ rawValue: String) -> String {
        switch rawValue {
        case "Quiet": return translated(["English": "Quiet", "Spanish": "Bajo", "Chinese": "安静", "Japanese": "小さい", "French": "Faible"])
        case "Moderate": return translated(["English": "Moderate", "Spanish": "Medio", "Chinese": "中等", "Japanese": "ふつう", "French": "Modéré"])
        case "Loud": return translated(["English": "Loud", "Spanish": "Alto", "Chinese": "响亮", "Japanese": "大きい", "French": "Fort"])
        case "Faint": return translated(["English": "Faint", "Spanish": "Suave", "Chinese": "柔和", "Japanese": "淡い", "French": "Doux"])
        case "Normal": return translated(["English": "Normal", "Spanish": "Normal", "Chinese": "普通", "Japanese": "普通", "French": "Normal"])
        case "Bright": return translated(["English": "Bright", "Spanish": "Brillante", "Chinese": "明亮", "Japanese": "明るい", "French": "Clair"])
        case "English": return "English"
        case "Spanish": return "Español"
        case "Chinese": return "中文"
        case "Japanese": return "日本語"
        case "French": return "Français"
        default: return rawValue
        }
    }

    private func translated(_ values: [String: String]) -> String {
        values[store.state.settings.language.rawValue] ?? values["English"] ?? ""
    }
}
