import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignup: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Hero
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.appPrimary.opacity(0.15))
                                .frame(width: 100, height: 100)
                            Text("📚")
                                .font(.system(size: 52))
                        }
                        Text("StudyConnect")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        Text("仲間と一緒に学ぼう")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 48)

                    // Form
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("メールアドレス")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            TextField("example@email.com", text: $email)
                                .textFieldStyle(.plain)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(14)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                        }

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

                        if let error = authViewModel.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text(error)
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .padding(10)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(8)
                        }

                        Button {
                            authViewModel.login(email: email, password: password)
                        } label: {
                            HStack {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.9)
                                } else {
                                    Text("ログイン")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.appPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(authViewModel.isLoading)

                        // Demo login
                        Button {
                            email = "demo@example.com"
                            password = "password123"
                            authViewModel.login(email: email, password: password)
                        } label: {
                            Text("デモアカウントでログイン")
                                .font(.footnote)
                                .foregroundColor(.appPrimary)
                        }
                    }
                    .padding(.horizontal, 24)

                    Divider().padding(.horizontal, 40)

                    VStack(spacing: 12) {
                        Text("アカウントをお持ちでない方")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button {
                            showSignup = true
                        } label: {
                            Text("新規登録")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.appPrimary, lineWidth: 1.5)
                                )
                                .foregroundColor(.appPrimary)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationDestination(isPresented: $showSignup) {
                SignupView()
            }
        }
    }
}

#Preview {
    LoginView().environmentObject(AuthViewModel())
}
