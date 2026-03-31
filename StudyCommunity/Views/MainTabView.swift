import SwiftUI

struct MainTabView: View {
    @StateObject private var communityVM = CommunityViewModel()
    @StateObject private var studySessionVM = StudySessionViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }

            CommunityListView()
                .tabItem {
                    Label("コミュニティ", systemImage: "person.3.fill")
                }

            StudySessionView()
                .tabItem {
                    Label("学習", systemImage: "timer")
                }

            ProfileView()
                .tabItem {
                    Label("プロフィール", systemImage: "person.fill")
                }
        }
        .tint(Color.appPrimary)
        .environmentObject(communityVM)
        .environmentObject(studySessionVM)
    }
}

#Preview {
    MainTabView().environmentObject(AuthViewModel())
}
