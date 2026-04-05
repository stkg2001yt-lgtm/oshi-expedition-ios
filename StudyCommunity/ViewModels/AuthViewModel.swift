import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func login(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "メールアドレスとパスワードを入力してください"
            return
        }
        isLoading = true
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
            self?.currentUser = User.sample
            self?.isAuthenticated = true
        }
    }

    func signup(name: String, email: String, password: String) {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "すべての項目を入力してください"
            return
        }
        guard password.count >= 8 else {
            errorMessage = "パスワードは8文字以上にしてください"
            return
        }
        isLoading = true
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
            let initials = String(name.prefix(1))
            let colors = ["#4F46E5", "#0EA5E9", "#10B981", "#F59E0B", "#EF4444"]
            let newUser = User(
                id: UUID().uuidString,
                name: name,
                username: email.components(separatedBy: "@").first ?? name,
                email: email,
                avatarInitials: initials,
                avatarColor: colors.randomElement()!,
                bio: "",
                totalStudyMinutes: 0,
                currentStreak: 0,
                longestStreak: 0,
                joinedGroupIds: [],
                createdAt: Date()
            )
            self?.currentUser = newUser
            self?.isAuthenticated = true
        }
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}
