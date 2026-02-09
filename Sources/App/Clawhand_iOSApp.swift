import SwiftUI

@main
struct Clawhand_iOSApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var currentUser: User?
    @Published var unreadMessages: Int = 0

    private let networkService = NetworkService.shared

    func connect() async {
        do {
            try await networkService.connect()
            isConnected = true
        } catch {
            print("Connection failed: \(error)")
            isConnected = false
        }
    }

    func disconnect() {
        networkService.disconnect()
        isConnected = false
    }
}
