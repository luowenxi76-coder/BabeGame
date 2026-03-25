import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeRoomView()
            }
            .tabItem {
                Label(GameText.homeTab, systemImage: "house.fill")
            }

            NavigationStack {
                WardrobeView()
            }
            .tabItem {
                Label(GameText.wardrobeTab, systemImage: "tshirt.fill")
            }

            NavigationStack {
                AlbumView()
            }
            .tabItem {
                Label(GameText.albumTab, systemImage: "books.vertical.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(GameText.settingsTab, systemImage: "gearshape.fill")
            }
        }
        .tint(CozyPalette.ink)
    }
}
