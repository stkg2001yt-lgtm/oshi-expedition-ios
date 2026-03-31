import SwiftUI

struct CommunityListView: View {
    @EnvironmentObject var communityVM: CommunityViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showCreateGroup = false
    @State private var selectedCategory: StudyGroup.StudyCategory? = nil

    var user: User { authViewModel.currentUser ?? User.sample }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("グループを検索...", text: $communityVM.searchText)
                        .font(.subheadline)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(title: "すべて", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                            communityVM.selectedCategory = nil
                        }
                        ForEach(StudyGroup.StudyCategory.allCases, id: \.self) { cat in
                            CategoryChip(
                                title: "\(cat.emoji) \(cat.rawValue)",
                                isSelected: selectedCategory == cat
                            ) {
                                selectedCategory = cat
                                communityVM.selectedCategory = cat
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 12)

                // My groups section
                let myGroups = communityVM.groups.filter { user.joinedGroupIds.contains($0.id) }
                if !myGroups.isEmpty && communityVM.searchText.isEmpty && selectedCategory == nil {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("参加中のグループ")
                            .font(.headline)
                            .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(myGroups) { group in
                                    NavigationLink {
                                        CommunityDetailView(group: group)
                                    } label: {
                                        MyGroupCard(group: group)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 16)
                }

                // All groups
                ScrollView {
                    LazyVStack(spacing: 12) {
                        Text(communityVM.searchText.isEmpty && selectedCategory == nil ? "おすすめのグループ" : "検索結果")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)

                        ForEach(communityVM.filteredGroups) { group in
                            NavigationLink {
                                CommunityDetailView(group: group)
                            } label: {
                                GroupListCard(group: group, isJoined: user.joinedGroupIds.contains(group.id))
                                    .padding(.horizontal, 16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("コミュニティ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateGroup = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView()
            }
        }
    }
}

struct CategoryChip: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? Color.appPrimary : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

struct MyGroupCard: View {
    var group: StudyGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: group.colorHex).opacity(0.15))
                    .frame(width: 80, height: 80)
                Text(group.iconEmoji)
                    .font(.system(size: 36))
            }
            Text(group.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 80, alignment: .leading)
        }
    }
}

struct GroupListCard: View {
    var group: StudyGroup
    var isJoined: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: group.colorHex).opacity(0.15))
                    .frame(width: 56, height: 56)
                Text(group.iconEmoji)
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(group.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Spacer()
                    if isJoined {
                        Text("参加中")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.appPrimary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.appPrimary.opacity(0.1))
                            .cornerRadius(5)
                    }
                }
                Text(group.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                HStack(spacing: 12) {
                    Label("\(group.memberCount)人", systemImage: "person.2")
                    Label("\(group.postCount)投稿", systemImage: "doc.text")
                    Text(group.category.rawValue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: group.colorHex).opacity(0.12))
                        .foregroundColor(Color(hex: group.colorHex))
                        .cornerRadius(4)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .cardStyle()
    }
}

#Preview {
    CommunityListView()
        .environmentObject(CommunityViewModel())
        .environmentObject(AuthViewModel())
}
