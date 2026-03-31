import Foundation
import Combine

class StudySessionViewModel: ObservableObject {
    @Published var sessions: [StudySession] = StudySession.samples
    @Published var isTimerRunning: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var selectedSubject: String = ""
    @Published var selectedGroupId: String? = nil
    @Published var sessionNote: String = ""

    private var timer: Timer? = nil

    var elapsedFormatted: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    var elapsedMinutes: Int { elapsedSeconds / 60 }

    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }

    func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        pauseTimer()
        elapsedSeconds = 0
    }

    func saveSession(userId: String) {
        guard elapsedMinutes > 0, !selectedSubject.isEmpty else { return }
        let session = StudySession(
            id: UUID().uuidString,
            userId: userId,
            groupId: selectedGroupId,
            subject: selectedSubject,
            durationMinutes: elapsedMinutes,
            note: sessionNote,
            createdAt: Date()
        )
        sessions.insert(session, at: 0)
        resetTimer()
        selectedSubject = ""
        sessionNote = ""
        selectedGroupId = nil
    }

    func totalMinutesToday(userId: String) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions
            .filter { $0.userId == userId && $0.createdAt >= today }
            .reduce(0) { $0 + $1.durationMinutes }
    }

    func totalMinutesThisWeek(userId: String) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: today))!
        return sessions
            .filter { $0.userId == userId && $0.createdAt >= weekStart }
            .reduce(0) { $0 + $1.durationMinutes }
    }

    func weeklyData(userId: String) -> [WeeklyStudyData] {
        let userSessions = sessions.filter { $0.userId == userId }
        return WeeklyStudyData.weekData(from: userSessions)
    }

    func recentSessions(userId: String, limit: Int = 5) -> [StudySession] {
        sessions
            .filter { $0.userId == userId }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    deinit {
        timer?.invalidate()
    }
}
