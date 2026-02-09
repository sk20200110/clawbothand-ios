import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    HStack {
                        Circle()
                            .fill(appState.isConnected ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(appState.isConnected ? "Connected" : "Disconnected")
                    }
                }
                
                Section("Quick Actions") {
                    NavigationLink {
                        Text("Voice Chat")
                    } label: {
                        Label("Start Voice Chat", systemImage: "mic")
                    }
                    
                    NavigationLink {
                        Text("Settings")
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .navigationTitle("Clawhand")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
