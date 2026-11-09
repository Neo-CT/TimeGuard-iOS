import SwiftUI

/// 习惯：今日进度 + 每周七天打卡 + 连续天数，长按删除。
struct HabitsView: View {
    @EnvironmentObject private var store: Store
    @State private var newName = ""
    @State private var showNew = false

    private let labels = ["一", "二", "三", "四", "五", "六", "日"]

    private var week: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today) // 1=周日
        let monday = cal.date(byAdding: .day, value: -(weekday + 5) % 7, to: today) ?? today
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: monday) }
    }

    private var todayKey: String { Store.dayFmt.string(from: Date()) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if store.habits.isEmpty {
                        Text("从小事开始，慢慢变好\n新建一个想坚持的习惯吧")
                            .font(.system(size: 15))
                            .foregroundColor(TG.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 80)
                    } else {
                        summary
                        ForEach(store.habits) { habit in
                            habitCard(habit)
                        }
                    }
                }
                .padding(16)
            }
            .background(TG.bg)
            .navigationTitle("习惯")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showNew = true } label: { Image(systemName: "plus") }
                }
            }
            .alert("新建习惯", isPresented: $showNew) {
                TextField("习惯名称，如喝水、阅读、跑步", text: $newName)
                Button("创建") {
                    let name = newName.trimmingCharacters(in: .whitespaces)
                    if !name.isEmpty { store.addHabit(name) }
                    newName = ""; showNew = false
                }
                Button("取消", role: .cancel) { showNew = false }
            }
        }
    }

    private var summary: some View {
        let todayDone = store.habits.filter { $0.records.contains(todayKey) }.count
        let weekDone = store.habits.reduce(0) { $0 + $1.records.intersection(week.map { Store.dayFmt.string(from: $0) }).count }
        return Text("今天已完成 \(todayDone) / \(store.habits.count) 个习惯\n本周累计打卡 \(weekDone) 次，保持自己的节奏")
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(TG.brandDark)
            .multilineTextAlignment(.center)
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(TG.brandSoft)
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func habitCard(_ habit: Store.Habit) -> some View {
        let streak = store.streak(habit)
        return VStack(spacing: 14) {
            HStack(spacing: 10) {
                Text(habit.name.prefix(1).description)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(TG.brandDark)
                    .frame(width: 38, height: 38)
                    .background(TG.brandSoft)
                    .clipShape(Circle())
                Text(habit.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(TG.textPrimary)
                Spacer()
                Text(streak > 0 ? "连续 \(streak) 天" : "今天待打卡")
                    .font(.system(size: 12))
                    .foregroundColor(streak > 0 ? TG.brandDark : TG.textTertiary)
            }
            HStack {
                ForEach(Array(week.enumerated()), id: \.offset) { i, day in
                    let key = Store.dayFmt.string(from: day)
                    let done = habit.records.contains(key)
                    let isToday = key == todayKey
                    let isFuture = day > Date()
                    VStack(spacing: 4) {
                        Button {
                            if !isFuture { store.toggleHabitDay(habit.id, date: key) }
                        } label: {
                            Text(done ? "✓" : "\(Calendar.current.component(.day, from: day))")
                                .font(.system(size: done ? 14 : 12, weight: done ? .bold : .regular))
                                .foregroundColor(done ? .white : Color(hex: 0x64766F))
                                .frame(width: 32, height: 32)
                                .background(done ? TG.brand : Color(hex: 0xF0F7F4))
                                .clipShape(Circle())
                                .overlay(isToday && !done ? Circle().stroke(TG.brand, lineWidth: 1.5) : nil)
                        }
                        .buttonStyle(.plain)
                        .disabled(isFuture)
                        .opacity(isFuture ? 0.45 : 1)
                        Text(labels[i])
                            .font(.system(size: 10))
                            .foregroundColor(isToday ? TG.brandDark : TG.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(TG.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(TG.stroke, lineWidth: 1))
        .contextMenu {
            Button("删除习惯", role: .destructive) { store.deleteHabit(habit.id) }
        }
    }
}
