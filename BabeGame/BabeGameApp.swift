import SwiftUI

@main
struct BabeGameApp: App {
    @StateObject private var session = GameSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
