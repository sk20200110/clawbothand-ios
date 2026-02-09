import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                if appState.unreadMessages > 0 {
                    Section {
                        Text("\(appState.unreadMessages) unread messages")
                            .foregroundStyle(.blue)
                    }
                }
                
                Section("Recent") {
                    ForEach(0..<5) { index in
                        MessageRow(name: "User \(index)", message: "Last message...", time: "2m ago")
                    }
                }
            }
            .navigationTitle("Messages")
        }
    }
}

struct MessageRow: View {
    let name: String
    let message: String
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(Text(String(name.prefix(1))))
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.headline)
                    Spacer()
                    Text(time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MessagesView()
        .environmentObject(AppState())
}
