import Foundation

struct StudySession: Identifiable, Codable {
    let id: String
    var userId: String
    var groupId: String?
    var subject: String
    var durationMinutes: Int
    var note: String
    var createdAt: Date

    static let samples: [StudySession] = [
        StudySession(id: "session-1", userId: "user-1", groupId: "group-1", subject: "TOEIC リスニング", durationMinutes: 90, note: "Part2,3を中心に練習", createdAt: Date().addingTimeInterval(-86400)),
        StudySession(id: "session-2", userId: "user-1", groupId: "group-2", subject: "SwiftUI", durationMinutes: 120, note: "NavigationStackの学習", createdAt: Date().addingTimeInterval(-86400 * 2)),
        StudySession(id: "session-3", userId: "user-1", groupId: nil, subject: "数学", durationMinutes: 60, note: "微分積分の復習", createdAt: Date().addingTimeInterval(-86400 * 3)),
        StudySession(id: "session-4", userId: "user-1", groupId: "group-1", subject: "TOEIC 単語", durationMinutes: 45, note: "金フレ Unit 5-8", createdAt: Date().addingTimeInterval(-86400 * 4)),
        StudySession(id: "session-5", userId: "user-1", groupId: "group-3", subject: "応用情報 午前", durationMinutes: 75, note: "ネットワーク分野の過去問", createdAt: Date().addingTimeInterval(-86400 * 5)),
        StudySession(id: "session-6", userId: "user-1", groupId: nil, subject: "英語読解", durationMinutes: 50, note: "長文読解練習", createdAt: Date().addingTimeInterval(-86400 * 6)),
        StudySession(id: "session-7", userId: "user-1", groupId: "group-2", subject: "Swift 基礎", durationMinutes: 100, note: "プロトコルとデリゲートパターン", createdAt: Date().addingTimeInterval(-86400 * 7))
    ]
}

struct WeeklyStudyData: Identifiable {
    let id = UUID()
    let dayLabel: String
    let minutes: Int

    static func weekData(from sessions: [StudySession]) -> [WeeklyStudyData] {
        let calendar = Calendar.current
        let today = Date()
        let labels = ["日", "月", "火", "水", "木", "金", "土"]

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -(6 - offset), to: today)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            let dayMinutes = sessions
                .filter { $0.createdAt >= dayStart && $0.createdAt < dayEnd }
                .reduce(0) { $0 + $1.durationMinutes }
            let weekday = calendar.component(.weekday, from: date) - 1
            return WeeklyStudyData(dayLabel: labels[weekday], minutes: dayMinutes)
        }
    }
}
