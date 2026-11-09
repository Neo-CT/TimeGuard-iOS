import SwiftUI

/// 待办：顶部横向清单栏（切换 / ＋新建 / 长按重命名·删除）+ 当前清单的待办列表。
struct TodoView: View {
    @EnvironmentObject private var store: Store
    @State private var draft = ""

    var currentList: Store.TodoList {
        store.allLists.first { $0.id == store.currentListId } ?? store.allLists[0]
    }

    var items: [Store.Todo] { store.todos(in: currentList.id) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                listBar
                todoList
                inputBar
            }
            .background(TG.bg)
            .navigationTitle(currentList.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.currentListId = store.addList("").id
                        renamePrompt = (store.currentListId, "")
                    } label: { Image(systemName: "plus") }
                }
            }
        }
    }

    // MARK: 清单栏

    @State private var renamePrompt: (Int, String)?

    private var listBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.allLists) { list in
                    Button {
                        store.currentListId = list.id
                    } label: {
                        Text(list.name)
                            .font(.system(size: 14, weight: store.currentListId == list.id ? .bold : .regular))
                            .foregroundColor(store.currentListId == list.id ? .white : TG.textSecondary)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(store.currentListId == list.id ? TG.brandDark : TG.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(TG.stroke, lineWidth: store.currentListId == list.id ? 0 : 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .contextMenu {
                        if list.id != Store.defaultListId {
                            Button("重命名") { renamePrompt = (list.id, list.name) }
                            Button("删除清单", role: .destructive) {
                                store.deleteList(list.id)
                            }
                        }
                    }
                }
                Button {
                    let created = store.addList("新清单")
                    renamePrompt = (created.id, "")
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(TG.brandDark)
                        .frame(width: 52, height: 34)
                        .background(TG.brandSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .alert("重命名清单", isPresented: Binding(
            get: { renamePrompt != nil },
            set: { if !$0 { renamePrompt = nil } })
        ) {
            TextField("清单名称", text: Binding(
                get: { renamePrompt?.1 ?? "" },
                set: { newValue in
                    if let p = renamePrompt { renamePrompt = (p.0, newValue) }
                }))
            Button("保存") {
                if let p = renamePrompt { store.renameList(p.0, name: p.1) }
                renamePrompt = nil
            }
            Button("取消", role: .cancel) { renamePrompt = nil }
        }
    }

    // MARK: 列表

    private var todoList: some View {
        List {
            let open = items.filter { !$0.done }
            let done = items.filter { $0.done }
            if !open.isEmpty {
                Section("待完成 \(open.count)") {
                    ForEach(open) { todo in row(todo) }
                }
            }
            if !done.isEmpty {
                Section("已完成 \(done.count)") {
                    ForEach(done) { todo in row(todo) }
                }
            }
            if items.isEmpty {
                Text("这个清单是空的\n在下面输入一条待办开始吧")
                    .foregroundColor(TG.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 60)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(_ todo: Store.Todo) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { store.toggleTodo(todo.id) }
            } label: {
                Image(systemName: todo.done ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.done ? TG.brand : TG.stroke)
                    .font(.system(size: 22))
            }
            .buttonStyle(.plain)
            Text(todo.text)
                .strikethrough(todo.done)
                .foregroundColor(todo.done ? TG.textTertiary : TG.textPrimary)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            editTarget = (todo.id, todo.text)
        }
        .contextMenu {
            Button("编辑") { editTarget = (todo.id, todo.text) }
            Button("删除", role: .destructive) { store.deleteTodo(todo.id) }
        }
        .alert("修改待办", isPresented: Binding(
            get: { editTarget != nil },
            set: { if !$0 { editTarget = nil } })
        ) {
            TextField("要做什么？", text: Binding(
                get: { editTarget?.1 ?? "" },
                set: { newValue in
                    if let e = editTarget { editTarget = (e.0, newValue) }
                }))
            Button("保存") {
                if let e = editTarget { store.updateTodo(e.0, text: e.1) }
                editTarget = nil
            }
            Button("取消", role: .cancel) { editTarget = nil }
        }
    }

    @State private var editTarget: (Int, String)?

    // MARK: 输入栏

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("添加待办…", text: $draft)
                .padding(.horizontal, 16).padding(.vertical, 11)
                .background(TG.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(TG.stroke, lineWidth: 1))
                .submitLabel(.done)
                .onSubmit(commit)
            Button("添加", action: commit)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 18).frame(height: 40)
                .background(TG.brand)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(TG.surface)
    }

    private func commit() {
        let text = draft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        store.addTodo(text, listId: currentList.id)
        draft = ""
    }
}
