import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var username: String
    var email: String
    var avatarInitials: String
    var avatarColor: String
    var bio: String
    var totalStudyMinutes: Int
    var currentStreak: Int
    var longestStreak: Int
    var joinedGroupIds: [String]
    var createdAt: Date

    var formattedStudyTime: String {
        let hours = totalStudyMinutes / 60
        let minutes = totalStudyMinutes % 60
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        }
        return "\(minutes)分"
    }

    static let sample = User(
        id: "user-1",
        name: "田中 太郎",
        username: "tanaka_taro",
        email: "tanaka@example.com",
        avatarInitials: "田",
        avatarColor: "#4F46E5",
        bio: "毎日コツコツ勉強中！資格取得を目指しています。",
        totalStudyMinutes: 1240,
        currentStreak: 7,
        longestStreak: 21,
        joinedGroupIds: ["group-1", "group-2"],
        createdAt: Date()
    )
}
