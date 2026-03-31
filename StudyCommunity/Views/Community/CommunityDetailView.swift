import SwiftUI

struct CommunityDetailView: View {
    @EnvironmentObject var communityVM: CommunityViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showCreatePost = false
    var group: StudyGroup

    var user: User { authViewModel.currentUser ?? User.sample }
    var isJoined: Bool { user.joinedGroupIds.contains(group.id) }
    var groupPosts: [Post] { communityVM.posts(for: group.id) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Group header
                groupHeader
                    .padding(.bottom, 16)

                // Posts
                if groupPosts.isEmpty {
                    VStack(spacing: 12) {
                        Text("📝")
                            .font(.system(size: 48))
                        Text("まだ投稿がありません")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if isJoined {
                            Text("最初の投稿をしてみましょう！")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(groupPosts) { post in
                            NavigationLink {
                                PostDetailView(post: post)
                            } label: {
                                PostCardView(post: post)
                                    .padding(.horizontal, 16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isJoined {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreatePost = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView(group: group)
        }
    }

    var groupHeader: some View {
        VStack(spacing: 16) {
            // Icon & title
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: group.colorHex).opacity(0.15))
                    .frame(width: 80, height: 80)
                Text(group.iconEmoji)
                    .font(.system(size: 40))
            }
            .padding(.top, 20)

            VStack(spacing: 6) {
                Text(group.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                HStack(spacing: 8) {
                    Text(group.category.emoji + group.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: group.colorHex).opacity(0.12))
                        .foregroundColor(Color(hex: group.colorHex))
                        .cornerRadius(6)

                    if group.isPublic {
                        Label("公開", systemImage: "globe")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Text(group.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            // Stats
            HStack(spacing: 0) {
                statColumn(value: "\(group.memberCount)", label: "メンバー")
                Divider().frame(height: 32)
                statColumn(value: "\(group.postCount)", label: "投稿")
            }
            .padding(.vertical, 12)
            .cardStyle()
            .padding(.horizontal, 24)

            // Join/Leave button
            Button {
                if isJoined {
                    let updated = communityVM.leaveGroup(groupId: group.id, user: user)
                    authViewModel.currentUser = updated
                } else {
                    let updated = communityVM.joinGroup(groupId: group.id, user: user)
                    authViewModel.currentUser = updated
                }
            } label: {
                Text(isJoined ? "グループを退出" : "グループに参加")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(isJoined ? Color(.secondarySystemBackground) : Color.appPrimary)
                    .foregroundColor(isJoined ? .secondary : .white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
    }

    func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        CommunityDetailView(group: StudyGroup.samples[0])
            .environmentObject(CommunityViewModel())
            .environmentObject(AuthViewModel())
    }
}
