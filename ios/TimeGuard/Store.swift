import Foundation

/// 数据模型 + JSON 持久化（Documents/timeguard.json），不联网、不上传。
/// 结构对齐安卓 NotesStore：清单 / 待办（quadrant=-1 或 0...3）/ 习惯 / 日程。
final class Store: ObservableObject {

    struct TodoList: Codable, Identifiable {
        var id: Int
        var name: String
        var order: Int
    }

    struct Todo: Codable, Identifiable {
        var id: Int
        var text: String
        var done: Bool = false
        var createdAt: Date = Date()
        /// -1 = 普通待办（归属 listId）；0...3 = 四象限
        var quadrant: Int = -1
        var listId: Int = Store.defaultListId
    }

    struct Habit: Codable, Identifiable {
        var id: Int
        var name: String
        /// "yyyy-MM-dd" 打卡日期集合
        var records: Set<String> = []
    }

    struct EventItem: Codable, Identifiable {
        var id: Int
        var title: String
        var startAt: Date
        var endAt: Date
        var note: String = ""
    }

    static let defaultListId = 0

    @Published var lists: [TodoList] = [TodoList(id: 0, name: "默认清单", order: -1)]
    @Published var todos: [Todo] = []
    @Published var habits: [Habit] = []
    @Published var events: [EventItem] = []
    @Published var currentListId: Int = 0

    private var nextId = 1
    private var saveTimer: Timer?

    private var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("timeguard.json")
    }

    init() { load() }

    // MARK: - 持久化

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let obj = try? JSONDecoder().decode(Root.self, from: data) else { return }
        nextId = obj.nextId
        if !obj.lists.isEmpty { lists = obj.lists }
        todos = obj.todos
        habits = obj.habits
        events = obj.events
    }

    private struct Root: Codable {
        var nextId: Int
        var lists: [TodoList]
        var todos: [Todo]
        var habits: [Habit]
        var events: [EventItem]
    }

    /// 防抖保存：0.3 秒内多次改动合并写一次
    private func save() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let self else { return }
            let root = Root(nextId: nextId, lists: lists, todos: todos,
                            habits: habits, events: events)
            if let data = try? JSONEncoder().encode(root) {
                try? data.write(to: url, options: .atomic)
            }
        }
    }

    private func nid() -> Int { defer { nextId += 1 }; return nextId }

    // MARK: - 清单

    var allLists: [TodoList] {
        lists.sorted { $0.order < $1.order }
    }

    @discardableResult
    func addList(_ name: String) -> TodoList {
        let l = TodoList(id: nid(), name: name.isEmpty ? "新清单" : name,
                         order: (lists.map(\.order).max() ?? 0) + 1)
        lists.append(l)
        currentListId = l.id
        save()
        return l
    }

    func renameList(_ id: Int, name: String) {
        guard id != Store.defaultListId, !name.isEmpty,
              let i = lists.firstIndex(where: { $0.id == id }) else { return }
        lists[i].name = name
        save()
    }

    func deleteList(_ id: Int) {
        guard id != Store.defaultListId else { return }
        lists.removeAll { $0.id == id }
        todos.removeAll { $0.listId == id }
        if currentListId == id { currentListId = Store.defaultListId }
        save()
    }

    // MARK: - 待办

    func todos(in listId: Int) -> [Todo] {
        todos.filter { $0.quadrant < 0 && $0.listId == listId }
            .sorted { ($0.done ? 1 : 0, $0.createdAt) < ($1.done ? 1 : 0, $1.createdAt) }
    }

    func quadrantTodos(_ quadrant: Int) -> [Todo] {
        todos.filter { $0.quadrant == quadrant }
            .sorted { ($0.done ? 1 : 0, $0.createdAt) < ($1.done ? 1 : 0, $1.createdAt) }
    }

    func addTodo(_ text: String, listId: Int) {
        todos.append(Todo(id: nid(), text: text, listId: listId))
        save()
    }

    func addQuadrantTodo(_ text: String, quadrant: Int) {
        todos.append(Todo(id: nid(), text: text, quadrant: quadrant))
        save()
    }

    func toggleTodo(_ id: Int) {
        guard let i = todos.firstIndex(where: { $0.id == id }) else { return }
        todos[i].done.toggle()
        save()
    }

    func updateTodo(_ id: Int, text: String) {
        guard !text.isEmpty, let i = todos.firstIndex(where: { $0.id == id }) else { return }
        todos[i].text = text
        save()
    }

    func deleteTodo(_ id: Int) {
        todos.removeAll { $0.id == id }
        save()
    }

    // MARK: - 习惯

    @discardableResult
    func addHabit(_ name: String) -> Habit {
        let h = Habit(id: nid(), name: name)
        habits.append(h)
        save()
        return h
    }

    func deleteHabit(_ id: Int) {
        habits.removeAll { $0.id == id }
        save()
    }

    func toggleHabitDay(_ id: Int, date: String) {
        guard let i = habits.firstIndex(where: { $0.id == id }) else { return }
        if habits[i].records.contains(date) {
            habits[i].records.remove(date)
        } else {
            habits[i].records.insert(date)
        }
        save()
    }

    /// 连续打卡天数
    func streak(_ habit: Habit) -> Int {
        var streak = 0
        var day = Date()
        let fmt = Self.dayFmt
        if !habit.records.contains(fmt.string(from: day)) {
            day = Calendar.current.date(byAdding: .day, value: -1, to: day) ?? day
        }
        while habit.records.contains(fmt.string(from: day)) {
            streak += 1
            day = Calendar.current.date(byAdding: .day, value: -1, to: day) ?? day
        }
        return streak
    }

    // MARK: - 日程

    func events(on day: Date) -> [EventItem] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return [] }
        return events.filter { $0.startAt < end && $0.endAt > start }
            .sorted { $0.startAt < $1.startAt }
    }

    func addEvent(title: String, startAt: Date, endAt: Date, note: String) {
        events.append(EventItem(id: nid(), title: title.isEmpty ? "（未命名）" : title,
                                startAt: startAt, endAt: endAt, note: note))
        save()
    }

    func deleteEvent(_ id: Int) {
        events.removeAll { $0.id == id }
        save()
    }

    static let dayFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "zh_CN")
        return f
    }()
}
