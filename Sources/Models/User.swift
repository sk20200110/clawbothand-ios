import Foundation

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }
}
