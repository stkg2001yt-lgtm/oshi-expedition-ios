import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var studySessionVM: StudySessionViewModel
    @EnvironmentObject var communityVM: CommunityViewModel
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false

    var user: User { authViewModel.currentUser ?? User.sample }
    var joinedGroups: [StudyGroup] {
        communityVM.groups.filter { user.joinedGroupIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile header
                    profileHeader
                        .padding(.bottom, 20)

                    // Stats grid
                    statsGrid
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)

                    // Streak info
                    streakCard
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)

                    // Joined groups
                    if !joinedGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("参加中のグループ (\(joinedGroups.count))")
                                .font(.headline)
                                .padding(.horizontal, 20)

                            ForEach(joinedGroups) { group in
                                NavigationLink {
                                    CommunityDetailView(group: group)
                                } label: {
                                    GroupListCard(group: group, isJoined: true)
                                        .padding(.horizontal, 16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 20)
                    }

                    // Settings
                    settingsSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("プロフィール")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Text("編集")
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .alert("ログアウト", isPresented: $showLogoutAlert) {
                Button("キャンセル", role: .cancel) {}
                Button("ログアウト", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("ログアウトしますか？")
            }
        }
    }

    var profileHeader: some View {
        VStack(spacing: 14) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                AvatarView(initials: user.avatarInitials, colorHex: user.avatarColor, size: 90)
                Circle()
                    .fill(Color.appPrimary)
                    .frame(width: 26, height: 26)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    )
            }
            .padding(.top, 24)

            VStack(spacing: 4) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 4)
                }
            }
        }
    }

    var statsGrid: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "clock.fill",
                value: user.formattedStudyTime,
                label: "累計学習時間",
                color: Color.appPrimary
            )
            StatCard(
                icon: "person.3.fill",
                value: "\(user.joinedGroupIds.count)",
                label: "参加グループ",
                color: Color(hex: "#0EA5E9")
            )
        }
    }

    var streakCard: some View {
        HStack(spacing: 0) {
            streakItem(emoji: "🔥", value: "\(user.currentStreak)日", label: "現在の連続")
            Divider().frame(height: 40)
            streakItem(emoji: "🏆", value: "\(user.longestStreak)日", label: "最長連続")
            Divider().frame(height: 40)
            streakItem(emoji: "📅", value: "\(studySessionVM.sessions.filter { $0.userId == user.id }.count)", label: "総セッション")
        }
        .padding(.vertical, 16)
        .cardStyle()
    }

    func streakItem(emoji: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(emoji).font(.title3)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    var settingsSection: some View {
        VStack(spacing: 2) {
            Text("設定")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

            settingsRow(icon: "bell.fill", label: "通知設定", color: Color(hex: "#F59E0B"))
            settingsRow(icon: "lock.fill", label: "プライバシー", color: Color(hex: "#6366F1"))
            settingsRow(icon: "questionmark.circle.fill", label: "ヘルプ・お問い合わせ", color: Color(hex: "#10B981"))

            Button {
                showLogoutAlert = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 34, height: 34)
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                            .font(.system(size: 15))
                    }
                    Text("ログアウト")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(14)
                .background(Color.appSurface)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }

    func settingsRow(icon: String, label: String, color: Color) -> some View {
        Button {} label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.15))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 15))
                }
                Text(label)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(14)
            .background(Color.appSurface)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 2)
    }
}

struct StatCard: View {
    var icon: String
    var value: String
    var label: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
            }
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var bio: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("名前", text: $name)
                    TextField("自己紹介", text: $bio, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("プロフィールを編集")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                name = authViewModel.currentUser?.name ?? ""
                bio = authViewModel.currentUser?.bio ?? ""
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        authViewModel.currentUser?.name = name
                        authViewModel.currentUser?.bio = bio
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(StudySessionViewModel())
        .environmentObject(CommunityViewModel())
}
