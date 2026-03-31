import Foundation

struct StudyGroup: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var category: StudyCategory
    var memberCount: Int
    var isPublic: Bool
    var iconEmoji: String
    var colorHex: String
    var creatorId: String
    var postCount: Int
    var createdAt: Date

    enum StudyCategory: String, Codable, CaseIterable {
        case language = "語学"
        case programming = "プログラミング"
        case exam = "資格試験"
        case science = "理系"
        case humanities = "文系"
        case business = "ビジネス"
        case art = "芸術"
        case other = "その他"

        var emoji: String {
            switch self {
            case .language: return "🌐"
            case .programming: return "💻"
            case .exam: return "📝"
            case .science: return "🔬"
            case .humanities: return "📚"
            case .business: return "💼"
            case .art: return "🎨"
            case .other: return "✨"
            }
        }
    }

    static let samples: [StudyGroup] = [
        StudyGroup(
            id: "group-1",
            name: "TOEIC 900点チャレンジ",
            description: "TOEIC 900点を目指す仲間のグループです。一緒に頑張りましょう！毎週模試を共有し、弱点を克服していきます。",
            category: .language,
            memberCount: 128,
            isPublic: true,
            iconEmoji: "🌐",
            colorHex: "#4F46E5",
            creatorId: "user-1",
            postCount: 342,
            createdAt: Date().addingTimeInterval(-86400 * 30)
        ),
        StudyGroup(
            id: "group-2",
            name: "Swift/iOS開発",
            description: "iOSアプリ開発を学ぶグループ。初心者歓迎！Swiftの基礎からアプリリリースまでサポートします。",
            category: .programming,
            memberCount: 89,
            isPublic: true,
            iconEmoji: "💻",
            colorHex: "#0EA5E9",
            creatorId: "user-2",
            postCount: 215,
            createdAt: Date().addingTimeInterval(-86400 * 60)
        ),
        StudyGroup(
            id: "group-3",
            name: "応用情報技術者試験",
            description: "応用情報技術者試験の合格を目指すグループです。過去問や参考書の情報を共有します。",
            category: .exam,
            memberCount: 256,
            isPublic: true,
            iconEmoji: "📝",
            colorHex: "#10B981",
            creatorId: "user-3",
            postCount: 892,
            createdAt: Date().addingTimeInterval(-86400 * 90)
        ),
        StudyGroup(
            id: "group-4",
            name: "数学の基礎から",
            description: "中学・高校数学をやり直したい社会人向けグループ。焦らずゆっくり学んでいきましょう。",
            category: .science,
            memberCount: 45,
            isPublic: true,
            iconEmoji: "🔢",
            colorHex: "#F59E0B",
            creatorId: "user-4",
            postCount: 98,
            createdAt: Date().addingTimeInterval(-86400 * 14)
        ),
        StudyGroup(
            id: "group-5",
            name: "中国語マスター",
            description: "中国語ゼロから始めるグループ。ネイティブスピーカーも参加しています！",
            category: .language,
            memberCount: 67,
            isPublic: true,
            iconEmoji: "🇨🇳",
            colorHex: "#EF4444",
            creatorId: "user-5",
            postCount: 178,
            createdAt: Date().addingTimeInterval(-86400 * 45)
        )
    ]
}
