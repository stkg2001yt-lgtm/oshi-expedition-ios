import SwiftUI

struct PostDetailView: View {
    @EnvironmentObject var communityVM: CommunityViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    var post: Post

    @State private var commentText: String = ""
    var user: User { authViewModel.currentUser ?? User.sample }
    var comments: [Comment] { communityVM.comments(for: post.id) }
    var groupName: String {
        communityVM.groups.first(where: { $0.id == post.groupId })?.name ?? "コミュニティ"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Post content
                VStack(alignment: .leading, spacing: 16) {
                    // Author
                    HStack(spacing: 10) {
                        AvatarView(initials: post.authorInitials, colorHex: post.authorColorHex, size: 44)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.authorName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            HStack(spacing: 4) {
                                Text(groupName)
                                    .font(.caption)
                                    .foregroundColor(.appPrimary)
                                Text("·")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(post.timeAgo)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }

                    Text(post.content)
                        .font(.body)
                        .lineSpacing(4)

                    if let mins = post.studyMinutes {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.appPrimary)
                            Text("学習時間: \(mins)分")
                                .font(.subheadline)
                                .foregroundColor(.appPrimary)
                                .fontWeight(.medium)
                        }
                        .padding(10)
                        .background(Color.appPrimary.opacity(0.08))
                        .cornerRadius(8)
                    }

                    if !post.tags.isEmpty {
                        HStack(spacing: 6) {
                            ForEach(post.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .foregroundColor(.appPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.appPrimary.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }

                    Divider()

                    // Actions
                    HStack(spacing: 24) {
                        Button {
                            communityVM.toggleLike(postId: post.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(post.isLiked ? .red : .secondary)
                                Text("\(post.likes) いいね")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 6) {
                            Image(systemName: "bubble.right")
                                .foregroundColor(.secondary)
                            Text("\(post.commentCount) コメント")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                }
                .padding(20)
                .background(Color.appSurface)

                // Comments
                VStack(alignment: .leading, spacing: 0) {
                    Text("コメント")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                    Divider()

                    ForEach(comments) { comment in
                        CommentRowView(comment: comment)
                        Divider().padding(.leading, 66)
                    }

                    if comments.isEmpty {
                        Text("コメントはまだありません。最初のコメントを書いてみましょう！")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(32)
                            .frame(maxWidth: .infinity)
                    }
                }
                .background(Color.appSurface)
                .padding(.top, 8)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("投稿の詳細")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            // Comment input
            HStack(spacing: 10) {
                AvatarView(initials: user.avatarInitials, colorHex: user.avatarColor, size: 32)
                HStack {
                    TextField("コメントを入力...", text: $commentText)
                        .font(.subheadline)
                    if !commentText.isEmpty {
                        Button {
                            communityVM.addComment(postId: post.id, content: commentText, author: user)
                            commentText = ""
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.appPrimary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(22)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
    }
}

struct CommentRowView: View {
    var comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(initials: comment.authorInitials, colorHex: comment.authorColorHex, size: 36)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(comment.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(comment.content)
                    .font(.subheadline)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: Post.samples[0])
            .environmentObject(CommunityViewModel())
            .environmentObject(AuthViewModel())
    }
}
