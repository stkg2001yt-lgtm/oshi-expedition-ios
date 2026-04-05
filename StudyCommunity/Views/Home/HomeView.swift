import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var communityVM: CommunityViewModel
    @EnvironmentObject var studySessionVM: StudySessionViewModel

    var user: User { authViewModel.currentUser ?? User.sample }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("こんにちは 👋")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        AvatarView(initials: user.avatarInitials, colorHex: user.avatarColor, size: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    // Today's stats
                    todayStatsCard
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)

                    // Streak banner
                    if user.currentStreak > 0 {
                        streakBanner
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }

                    // Feed
                    VStack(alignment: .leading, spacing: 12) {
                        Text("最新の投稿")
                            .font(.headline)
                            .padding(.horizontal, 20)

                        ForEach(communityVM.feedPosts.prefix(10)) { post in
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
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    var todayStatsCard: some View {
        let todayMinutes = studySessionVM.totalMinutesToday(userId: user.id)
        let weekMinutes = studySessionVM.totalMinutesThisWeek(userId: user.id)

        return HStack(spacing: 0) {
            statItem(value: "\(todayMinutes)分", label: "今日の学習")
            Divider().frame(height: 40)
            statItem(value: "\(weekMinutes / 60)時間\(weekMinutes % 60)分", label: "今週の学習")
            Divider().frame(height: 40)
            statItem(value: "\(user.currentStreak)日", label: "連続学習")
        }
        .padding(.vertical, 16)
        .cardStyle()
    }

    func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.appPrimary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    var streakBanner: some View {
        HStack(spacing: 12) {
            Text("🔥")
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(user.currentStreak)日連続学習中！")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("素晴らしい！この調子で続けましょう")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(hex: "#FEF3C7"), Color(hex: "#FDE68A")],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
    }
}

struct PostCardView: View {
    @EnvironmentObject var communityVM: CommunityViewModel
    var post: Post

    var groupName: String {
        communityVM.groups.first(where: { $0.id == post.groupId })?.name ?? "コミュニティ"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author row
            HStack(spacing: 10) {
                AvatarView(initials: post.authorInitials, colorHex: post.authorColorHex, size: 36)
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
                if let mins = post.studyMinutes {
                    Label("\(mins)分", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(post.content)
                .font(.subheadline)
                .lineLimit(4)
                .foregroundColor(.primary)

            if !post.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(post.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.appPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.appPrimary.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }

            Divider()

            // Actions
            HStack(spacing: 20) {
                Button {
                    communityVM.toggleLike(postId: post.id)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : .secondary)
                        Text("\(post.likes)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                        .foregroundColor(.secondary)
                    Text("\(post.commentCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding(16)
        .cardStyle()
    }
}

struct AvatarView: View {
    var initials: String
    var colorHex: String
    var size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: colorHex))
                .frame(width: size, height: size)
            Text(initials)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(CommunityViewModel())
        .environmentObject(StudySessionViewModel())
}
