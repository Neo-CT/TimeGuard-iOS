import SwiftUI

@main
struct TimeGuardApp: App {
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

/// 底部 6 个标签，与安卓底部导航一致
struct ContentView: View {
    var body: some View {
        TabView {
            TodoView().tabItem { Label("待办", systemImage: "checklist") }
            CalendarView().tabItem { Label("日历", systemImage: "calendar") }
            MatrixView().tabItem { Label("四象限", systemImage: "square.grid.2x2") }
            PomodoroView().tabItem { Label("番茄钟", systemImage: "timer") }
            HabitsView().tabItem { Label("习惯", systemImage: "leaf") }
            MonitorView().tabItem { Label("监控", systemImage: "shield.lefthalf.filled") }
        }
        .accentColor(TG.brandDark)
    }
}
