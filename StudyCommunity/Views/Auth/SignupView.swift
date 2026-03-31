import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var passwordsMatch: Bool { password == confirmPassword || confirmPassword.isEmpty }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("アカウント作成")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("無料で始められます")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)

                VStack(spacing: 16) {
                    formField(label: "お名前", placeholder: "山田 太郎", text: $name)
                    formField(label: "メールアドレス", placeholder: "example@email.com", text: $email, isEmail: true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("パスワード")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        SecureField("8文字以上", text: $password)
                            .textFieldStyle(.plain)
                            .padding(14)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("パスワード確認")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        SecureField("パスワードを再入力", text: $confirmPassword)
                            .textFieldStyle(.plain)
                            .padding(14)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(passwordsMatch ? Color.clear : Color.red, lineWidth: 1)
                            )
                        if !passwordsMatch {
                            Text("パスワードが一致しません")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    if let error = authViewModel.errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(error).font(.caption)
                        }
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.red.opacity(0.08))
                        .cornerRadius(8)
                    }

                    Button {
                        guard passwordsMatch else { return }
                        authViewModel.signup(name: name, email: email, password: password)
                    } label: {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView().tint(.white).scaleEffect(0.9)
                            } else {
                                Text("登録する").fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.appPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(authViewModel.isLoading || !passwordsMatch)
                }
                .padding(.horizontal, 24)

                Text("登録することで、利用規約とプライバシーポリシーに同意したことになります。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("新規登録")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func formField(label: String, placeholder: String, text: Binding<String>, isEmail: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .keyboardType(isEmail ? .emailAddress : .default)
                .autocapitalization(isEmail ? .none : .words)
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationStack { SignupView().environmentObject(AuthViewModel()) }
}
