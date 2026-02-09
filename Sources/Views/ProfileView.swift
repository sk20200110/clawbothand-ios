import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 64, height: 64)
                            .overlay(Text("U"))
                            .font(.title)
                        
                        if let user = appState.currentUser {
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            VStack(alignment: .leading) {
                                Text("Guest")
                                    .font(.headline)
                                Text("Not signed in")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Settings") {
                    NavigationLink {
                        Text("Notifications")
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink {
                        Text("Privacy")
                    } label: {
                        Label("Privacy", systemImage: "lock")
                    }
                    
                    Button {
                        appState.disconnect()
                    } label: {
                        Label("Disconnect", systemImage: "wifi.slash")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
