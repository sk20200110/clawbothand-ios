import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case messages
        case profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)
            
            MessagesView()
                .tabItem {
                    Label("Messages", systemImage: "message")
                }
                .tag(Tab.messages)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        .onAppear {
            Task {
                await appState.connect()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
