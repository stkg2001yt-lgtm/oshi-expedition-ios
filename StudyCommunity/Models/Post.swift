import Foundation

struct Post: Identifiable, Codable {
    let id: String
    var groupId: String
    var authorId: String
    var authorName: String
    var authorInitials: String
    var authorColorHex: String
    var content: String
    var likes: Int
    var commentCount: Int
    var isLiked: Bool
    var tags: [String]
    var studyMinutes: Int?
    var createdAt: Date

    var timeAgo: String {
        let diff = Date().timeIntervalSince(createdAt)
        if diff < 60 { return "たった今" }
        if diff < 3600 { return "\(Int(diff / 60))分前" }
        if diff < 86400 { return "\(Int(diff / 3600))時間前" }
        return "\(Int(diff / 86400))日前"
    }

    static let samples: [Post] = [
        Post(
            id: "post-1",
            groupId: "group-1",
            authorId: "user-2",
            authorName: "佐藤 花子",
            authorInitials: "佐",
            authorColorHex: "#0EA5E9",
            content: "今日はリスニングパート5セット解きました！スコア 445→460に上がってきた🎉 音読シャドーイングを毎日続けた効果が出てきたかも。みなさんのリスニング対策は何をやってますか？",
            likes: 24,
            commentCount: 8,
            isLiked: false,
            tags: ["リスニング", "シャドーイング"],
            studyMinutes: 90,
            createdAt: Date().addingTimeInterval(-3600 * 2)
        ),
        Post(
            id: "post-2",
            groupId: "group-1",
            authorId: "user-3",
            authorName: "山田 健二",
            authorInitials: "山",
            authorColorHex: "#10B981",
            content: "公式問題集 Vol.9 全部解き終わりました！間違えた問題をまとめたノートを作ると復習しやすいのでおすすめです。次は公式問題集 Vol.10 に挑戦します💪",
            likes: 41,
            commentCount: 15,
            isLiked: true,
            tags: ["公式問題集", "復習法"],
            studyMinutes: 120,
            createdAt: Date().addingTimeInterval(-3600 * 5)
        ),
        Post(
            id: "post-3",
            groupId: "group-2",
            authorId: "user-1",
            authorName: "田中 太郎",
            authorInitials: "田",
            authorColorHex: "#4F46E5",
            content: "SwiftUIのNavigationStackをやっと理解できました！@Bindingと@StateObjectの使い分けが最初は混乱したけど、実際にアプリを作りながら学ぶと身につきますね。サンプルコードをGitHubにアップしました。",
            likes: 18,
            commentCount: 5,
            isLiked: false,
            tags: ["SwiftUI", "NavigationStack"],
            studyMinutes: 180,
            createdAt: Date().addingTimeInterval(-3600 * 8)
        ),
        Post(
            id: "post-4",
            groupId: "group-3",
            authorId: "user-4",
            authorName: "鈴木 美咲",
            authorInitials: "鈴",
            authorColorHex: "#F59E0B",
            content: "令和5年度の過去問を解いてみました。午前は75点、午後は65点でした。ネットワーク分野が弱点だと判明したので、重点的に勉強します。試験まであと2ヶ月、頑張るぞ！",
            likes: 33,
            commentCount: 12,
            isLiked: false,
            tags: ["過去問", "ネットワーク"],
            studyMinutes: 150,
            createdAt: Date().addingTimeInterval(-3600 * 12)
        )
    ]
}

struct Comment: Identifiable, Codable {
    let id: String
    var postId: String
    var authorId: String
    var authorName: String
    var authorInitials: String
    var authorColorHex: String
    var content: String
    var likes: Int
    var createdAt: Date

    var timeAgo: String {
        let diff = Date().timeIntervalSince(createdAt)
        if diff < 60 { return "たった今" }
        if diff < 3600 { return "\(Int(diff / 60))分前" }
        if diff < 86400 { return "\(Int(diff / 3600))時間前" }
        return "\(Int(diff / 86400))日前"
    }

    static let samples: [Comment] = [
        Comment(
            id: "comment-1",
            postId: "post-1",
            authorId: "user-3",
            authorName: "山田 健二",
            authorInitials: "山",
            authorColorHex: "#10B981",
            content: "シャドーイングいいですよね！私はTED Talksを使って練習しています。",
            likes: 5,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        Comment(
            id: "comment-2",
            postId: "post-1",
            authorId: "user-4",
            authorName: "鈴木 美咲",
            authorInitials: "鈴",
            authorColorHex: "#F59E0B",
            content: "私はABCニュースシャワーを毎朝聴くようにしています！効果ありますよ😊",
            likes: 3,
            createdAt: Date().addingTimeInterval(-1800)
        )
    ]
}
