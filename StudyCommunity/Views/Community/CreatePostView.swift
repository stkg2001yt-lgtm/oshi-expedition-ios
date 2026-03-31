import SwiftUI

struct CreatePostView: View {
    @EnvironmentObject var communityVM: CommunityViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var group: StudyGroup
    @State private var content: String = ""
    @State private var tagInput: String = ""
    @State private var tags: [String] = []
    @State private var studyMinutesText: String = ""
    @State private var includeStudyTime: Bool = false

    var user: User { authViewModel.currentUser ?? User.sample }
    var isPostable: Bool { !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Group label
                    HStack(spacing: 8) {
                        Text(group.iconEmoji)
                        Text(group.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.appPrimary)
                    }
                    .padding(.horizontal, 4)

                    // Author
                    HStack(spacing: 10) {
                        AvatarView(initials: user.avatarInitials, colorHex: user.avatarColor, size: 40)
                        Text(user.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    // Content
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .frame(minHeight: 120)
                            .padding(4)
                        if content.isEmpty {
                            Text("学習の報告、質問、アドバイスなど何でも投稿しましょう！")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                    // Study time toggle
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $includeStudyTime) {
                            Label("学習時間を記録", systemImage: "clock")
                                .font(.subheadline)
                        }
                        .tint(Color.appPrimary)

                        if includeStudyTime {
                            HStack {
                                TextField("90", text: $studyMinutesText)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.plain)
                                    .frame(width: 60)
                                    .padding(10)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(8)
                                Text("分")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                    // Tags
                    VStack(alignment: .leading, spacing: 10) {
                        Text("タグ")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack {
                            TextField("タグを入力してEnter", text: $tagInput)
                                .textFieldStyle(.plain)
                                .onSubmit { addTag() }

                            if !tagInput.isEmpty {
                                Button("追加") { addTag() }
                                    .font(.caption)
                                    .foregroundColor(.appPrimary)
                            }
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                        if !tags.isEmpty {
                            FlowLayout(tags: tags) { tag in
                                HStack(spacing: 4) {
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .foregroundColor(.appPrimary)
                                    Button {
                                        tags.removeAll { $0 == tag }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 9))
                                            .foregroundColor(.appPrimary)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.appPrimary.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("投稿を作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("投稿") {
                        let minutes = includeStudyTime ? Int(studyMinutesText) : nil
                        communityVM.createPost(
                            groupId: group.id,
                            content: content,
                            tags: tags,
                            studyMinutes: minutes,
                            author: user
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isPostable)
                }
            }
        }
    }

    func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !tags.contains(trimmed) && tags.count < 5 {
            tags.append(trimmed)
        }
        tagInput = ""
    }
}

struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    var tags: Data
    var content: (Data.Element) -> Content

    var body: some View {
        // Simple horizontal wrapping approximation
        HStack(alignment: .top, spacing: 8) {
            ForEach(Array(tags), id: \.self) { item in
                content(item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CreateGroupView: View {
    @EnvironmentObject var communityVM: CommunityViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: StudyGroup.StudyCategory = .other
    @State private var isPublic: Bool = true
    @State private var iconEmoji: String = "📚"

    let emojiOptions = ["📚", "💻", "🌐", "🔬", "📝", "💼", "🎨", "🧮", "🎵", "🏋️", "🌸", "⭐"]
    var user: User { authViewModel.currentUser ?? User.sample }

    var body: some View {
        NavigationStack {
            Form {
                Section("グループ情報") {
                    TextField("グループ名 (例: TOEIC 900点チャレンジ)", text: $name)
                    TextField("説明", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("アイコン") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            Button {
                                iconEmoji = emoji
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 28))
                                    .frame(width: 44, height: 44)
                                    .background(iconEmoji == emoji ? Color.appPrimary.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $selectedCategory) {
                        ForEach(StudyGroup.StudyCategory.allCases, id: \.self) { cat in
                            Text("\(cat.emoji) \(cat.rawValue)").tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Toggle("公開グループ", isOn: $isPublic)
                } footer: {
                    Text(isPublic ? "誰でもグループを見つけて参加できます" : "招待された人のみ参加できます")
                }
            }
            .navigationTitle("グループを作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("作成") {
                        communityVM.createGroup(
                            name: name,
                            description: description,
                            category: selectedCategory,
                            isPublic: isPublic,
                            iconEmoji: iconEmoji,
                            creator: user
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
}
