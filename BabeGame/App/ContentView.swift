import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if !store.isLoaded {
                ZStack {
                    CozyBackground()
                    ProgressView("正在打开猫咪房间...")
                }
            } else if store.saveState.cats.isEmpty {
                NavigationStack {
                    CatProfilesView()
                }
            } else {
                RootTabView()
            }
        }
        .onAppear {
            store.refreshTripStates()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                store.refreshTripStates()
            }
        }
    }
}
