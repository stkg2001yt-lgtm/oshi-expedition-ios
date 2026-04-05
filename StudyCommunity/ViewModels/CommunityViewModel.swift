import Foundation
import Combine

class CommunityViewModel: ObservableObject {
    @Published var groups: [StudyGroup] = StudyGroup.samples
    @Published var posts: [Post] = Post.samples
    @Published var comments: [Comment] = Comment.samples
    @Published var searchText: String = ""
    @Published var selectedCategory: StudyGroup.StudyCategory? = nil

    var filteredGroups: [StudyGroup] {
        var result = groups
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    func posts(for groupId: String) -> [Post] {
        posts.filter { $0.groupId == groupId }.sorted { $0.createdAt > $1.createdAt }
    }

    func comments(for postId: String) -> [Comment] {
        comments.filter { $0.postId == postId }.sorted { $0.createdAt < $1.createdAt }
    }

    func toggleLike(postId: String) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].isLiked.toggle()
            posts[index].likes += posts[index].isLiked ? 1 : -1
        }
    }

    func joinGroup(groupId: String, user: User) -> User {
        var updatedUser = user
        if !updatedUser.joinedGroupIds.contains(groupId) {
            updatedUser.joinedGroupIds.append(groupId)
            if let index = groups.firstIndex(where: { $0.id == groupId }) {
                groups[index].memberCount += 1
            }
        }
        return updatedUser
    }

    func leaveGroup(groupId: String, user: User) -> User {
        var updatedUser = user
        updatedUser.joinedGroupIds.removeAll { $0 == groupId }
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].memberCount = max(0, groups[index].memberCount - 1)
        }
        return updatedUser
    }

    func createPost(groupId: String, content: String, tags: [String], studyMinutes: Int?, author: User) {
        let post = Post(
            id: UUID().uuidString,
            groupId: groupId,
            authorId: author.id,
            authorName: author.name,
            authorInitials: author.avatarInitials,
            authorColorHex: author.avatarColor,
            content: content,
            likes: 0,
            commentCount: 0,
            isLiked: false,
            tags: tags,
            studyMinutes: studyMinutes,
            createdAt: Date()
        )
        posts.insert(post, at: 0)
        if let index = groups.firstIndex(where: { $0.id == groupId }) {
            groups[index].postCount += 1
        }
    }

    func addComment(postId: String, content: String, author: User) {
        let comment = Comment(
            id: UUID().uuidString,
            postId: postId,
            authorId: author.id,
            authorName: author.name,
            authorInitials: author.avatarInitials,
            authorColorHex: author.avatarColor,
            content: content,
            likes: 0,
            createdAt: Date()
        )
        comments.append(comment)
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].commentCount += 1
        }
    }

    func createGroup(name: String, description: String, category: StudyGroup.StudyCategory, isPublic: Bool, iconEmoji: String, creator: User) {
        let colors = ["#4F46E5", "#0EA5E9", "#10B981", "#F59E0B", "#EF4444", "#8B5CF6"]
        let group = StudyGroup(
            id: UUID().uuidString,
            name: name,
            description: description,
            category: category,
            memberCount: 1,
            isPublic: isPublic,
            iconEmoji: iconEmoji,
            colorHex: colors.randomElement()!,
            creatorId: creator.id,
            postCount: 0,
            createdAt: Date()
        )
        groups.insert(group, at: 0)
    }

    var feedPosts: [Post] {
        posts.sorted { $0.createdAt > $1.createdAt }
    }
}
