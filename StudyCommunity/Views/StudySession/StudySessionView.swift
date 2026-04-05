import SwiftUI

struct StudySessionView: View {
    @EnvironmentObject var studySessionVM: StudySessionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var communityVM: CommunityViewModel
    @State private var showSaveSheet = false

    var user: User { authViewModel.currentUser ?? User.sample }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Timer card
                    timerCard
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // Weekly bar chart
                    weeklyChartCard
                        .padding(.horizontal, 16)

                    // Recent sessions
                    recentSessionsList
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 32)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("学習タイマー")
            .sheet(isPresented: $showSaveSheet) {
                SaveSessionSheet(groups: communityVM.groups.filter {
                    user.joinedGroupIds.contains($0.id)
                })
            }
        }
    }

    var timerCard: some View {
        VStack(spacing: 24) {
            // Timer display
            ZStack {
                Circle()
                    .stroke(Color.appPrimary.opacity(0.15), lineWidth: 12)
                    .frame(width: 180, height: 180)
                Circle()
                    .trim(from: 0, to: min(CGFloat(studySessionVM.elapsedSeconds) / 3600.0, 1))
                    .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: studySessionVM.elapsedSeconds)

                VStack(spacing: 4) {
                    Text(studySessionVM.elapsedFormatted)
                        .font(.system(size: 38, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    if studySessionVM.elapsedMinutes > 0 {
                        Text("\(studySessionVM.elapsedMinutes)分 達成!")
                            .font(.caption)
                            .foregroundColor(.appPrimary)
                    }
                }
            }

            // Controls
            HStack(spacing: 20) {
                Button {
                    studySessionVM.resetTimer()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20))
                        .frame(width: 52, height: 52)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                        .foregroundColor(.secondary)
                }

                Button {
                    if studySessionVM.isTimerRunning {
                        studySessionVM.pauseTimer()
                    } else {
                        studySessionVM.startTimer()
                    }
                } label: {
                    Image(systemName: studySessionVM.isTimerRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 24))
                        .frame(width: 70, height: 70)
                        .background(Color.appPrimary)
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
                .shadow(color: Color.appPrimary.opacity(0.4), radius: 8)

                Button {
                    studySessionVM.pauseTimer()
                    showSaveSheet = true
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20))
                        .frame(width: 52, height: 52)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                        .foregroundColor(studySessionVM.elapsedMinutes > 0 ? .appPrimary : .secondary)
                }
                .disabled(studySessionVM.elapsedMinutes == 0)
            }

            // Today stats
            HStack(spacing: 0) {
                miniStat(value: "\(studySessionVM.totalMinutesToday(userId: user.id))分", label: "今日")
                Divider().frame(height: 28)
                miniStat(value: "\(studySessionVM.totalMinutesThisWeek(userId: user.id) / 60)h", label: "今週")
                Divider().frame(height: 28)
                miniStat(value: "\(studySessionVM.sessions.filter { $0.userId == user.id }.count)回", label: "総セッション")
            }
        }
        .padding(24)
        .cardStyle()
    }

    func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline).foregroundColor(.appPrimary)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    var weeklyChartCard: some View {
        let data = studySessionVM.weeklyData(userId: user.id)
        let maxMinutes = max(data.map { $0.minutes }.max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 16) {
            Text("今週の学習履歴")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { item in
                    VStack(spacing: 4) {
                        if item.minutes > 0 {
                            Text("\(item.minutes)")
                                .font(.system(size: 9))
                                .foregroundColor(.appPrimary)
                        }
                        RoundedRectangle(cornerRadius: 4)
                            .fill(item.minutes > 0 ? Color.appPrimary : Color(.tertiarySystemFill))
                            .frame(
                                height: item.minutes > 0
                                    ? max(CGFloat(item.minutes) / CGFloat(maxMinutes) * 100, 8)
                                    : 8
                            )
                        Text(item.dayLabel)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 130, alignment: .bottom)
        }
        .padding(20)
        .cardStyle()
    }

    var recentSessionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近の学習記録")
                .font(.headline)

            let recent = studySessionVM.recentSessions(userId: user.id)
            if recent.isEmpty {
                Text("まだ学習記録がありません。タイマーを使って記録してみましょう！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 16)
            } else {
                ForEach(recent) { session in
                    SessionRowView(session: session, groups: communityVM.groups)
                }
            }
        }
    }
}

struct SessionRowView: View {
    var session: StudySession
    var groups: [StudyGroup]

    var groupName: String? {
        guard let gid = session.groupId else { return nil }
        return groups.first(where: { $0.id == gid })?.name
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "clock.fill")
                    .foregroundColor(.appPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(session.subject)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                HStack(spacing: 6) {
                    if let group = groupName {
                        Text(group)
                            .font(.caption)
                            .foregroundColor(.appPrimary)
                    }
                    if !session.note.isEmpty {
                        Text(session.note)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(session.durationMinutes)分")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appPrimary)
                Text(session.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .cardStyle()
    }
}

struct SaveSessionSheet: View {
    @EnvironmentObject var studySessionVM: StudySessionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    var groups: [StudyGroup]

    var user: User { authViewModel.currentUser ?? User.sample }

    var body: some View {
        NavigationStack {
            Form {
                Section("学習内容") {
                    TextField("科目 (例: TOEIC リスニング)", text: $studySessionVM.selectedSubject)
                    TextField("メモ (任意)", text: $studySessionVM.sessionNote, axis: .vertical)
                        .lineLimit(2...4)
                }

                if !groups.isEmpty {
                    Section("グループに記録") {
                        Picker("グループ", selection: $studySessionVM.selectedGroupId) {
                            Text("グループなし").tag(nil as String?)
                            ForEach(groups) { group in
                                Text(group.name).tag(group.id as String?)
                            }
                        }
                    }
                }

                Section {
                    HStack {
                        Text("学習時間")
                        Spacer()
                        Text("\(studySessionVM.elapsedMinutes)分")
                            .fontWeight(.semibold)
                            .foregroundColor(.appPrimary)
                    }
                }
            }
            .navigationTitle("学習を記録する")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        studySessionVM.saveSession(userId: user.id)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(studySessionVM.selectedSubject.isEmpty)
                }
            }
        }
    }
}

#Preview {
    StudySessionView()
        .environmentObject(StudySessionViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(CommunityViewModel())
}
