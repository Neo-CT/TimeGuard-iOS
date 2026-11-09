import SwiftUI

/// 日历：月视图网格 + 选中某天的日程列表；点某天可添加/删除日程。
struct CalendarView: View {
    @EnvironmentObject private var store: Store

    @State private var monthAnchor = Date()
    @State private var selectedDay = Date()
    @State private var newTitle = ""
    @State private var showAdd = false

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy 年 M 月"
        return f.string(from: monthAnchor)
    }

    /// 月网格：前面补空白 + 当月天数
    private var days: [Date?] {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: monthAnchor))!
        let weekday = cal.component(.weekday, from: start) // 1=周日
        let leading = (weekday + 6) % 7                    // 周一起
        let range = cal.range(of: .day, in: .month, for: start)!
        var result: [Date?] = Array(repeating: nil, count: leading)
        for d in 0..<range.count {
            result.append(cal.date(byAdding: .day, value: d, to: start))
        }
        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                monthSwitcher
                weekdayHeader
                dayGrid
                dayEvents
            }
            .background(TG.bg)
            .navigationTitle("日历")
        }
    }

    private var monthSwitcher: some View {
        HStack {
            Button { shiftMonth(-1) } label: { Image(systemName: "chevron.left") }
            Spacer()
            Text(monthTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(TG.textPrimary)
            Spacer()
            Button { shiftMonth(1) } label: { Image(systemName: "chevron.right") }
        }
        .foregroundColor(TG.brandDark)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { d in
                Text(d).font(.system(size: 12)).foregroundColor(TG.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }

    private var dayGrid: some View {
        let cal = Calendar.current
        let todayKey = Store.dayFmt.string(from: Date())
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                if let day {
                    let key = Store.dayFmt.string(from: day)
                    let hasEvents = !store.events(on: day).isEmpty
                    let selected = cal.isDate(day, inSameDayAs: selectedDay)
                    Button {
                        selectedDay = day
                    } label: {
                        VStack(spacing: 3) {
                            Text("\(cal.component(.day, from: day))")
                                .font(.system(size: 14, weight: key == todayKey ? .bold : .regular))
                                .foregroundColor(selected ? .white
                                                : key == todayKey ? TG.brandDark
                                                : TG.textPrimary)
                                .frame(width: 34, height: 34)
                                .background(selected ? TG.brand : Color.clear)
                                .clipShape(Circle())
                            Circle()
                                .fill(hasEvents ? TG.brand : Color.clear)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
        .padding(.horizontal, 8)
    }

    private var dayEvents: some View {
        let items = store.events(on: selectedDay)
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M 月 d 日"
        return List {
            Section {
                Button {
                    newTitle = ""
                    showAdd = true
                } label: {
                    Label("添加日程", systemImage: "plus.circle.fill")
                        .foregroundColor(TG.brandDark)
                }
                ForEach(items) { e in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(e.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(TG.textPrimary)
                        Text("\(Self.time(e.startAt)) - \(Self.time(e.endAt))")
                            .font(.system(size: 12))
                            .foregroundColor(TG.textTertiary)
                    }
                }
                .onDelete { offsets in
                    for i in offsets { store.deleteEvent(items[i].id) }
                }
            } header: {
                Text("\(f.string(from: selectedDay)) 的日程")
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .alert("添加日程", isPresented: $showAdd) {
            TextField("日程标题", text: $newTitle)
            Button("保存") {
                let cal = Calendar.current
                let start = cal.startOfDay(for: selectedDay).addingTimeInterval(9 * 3600)
                store.addEvent(title: newTitle, startAt: start,
                               endAt: start.addingTimeInterval(3600), note: "")
                showAdd = false
            }
            Button("取消", role: .cancel) { showAdd = false }
        }
    }

    private func shiftMonth(_ delta: Int) {
        monthAnchor = Calendar.current.date(byAdding: .month, value: delta, to: monthAnchor) ?? monthAnchor
    }

    private static func time(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "HH:mm"
        return f.string(from: d)
    }
}
