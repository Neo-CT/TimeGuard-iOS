import SwiftUI

/// 四象限：2×2 网格，每个象限独立添加 / 勾选 / 编辑 / 删除。
struct MatrixView: View {
    @EnvironmentObject private var store: Store

    let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<4, id: \.self) { i in
                        quadrantCard(i)
                    }
                }
                .padding(12)
            }
            .background(TG.bg)
            .navigationTitle("四象限")
        }
    }

    private func quadrantCard(_ index: Int) -> some View {
        let color = TG.quadColors[index]
        let items = store.quadrantTodos(index)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 10, height: 10)
                Text(TG.quadTitles[index])
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(color)
                Spacer()
                Text("\(items.filter { !$0.done }.count)")
                    .font(.system(size: 12))
                    .foregroundColor(TG.textTertiary)
                Button { addTarget = index } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                }
            }
            if items.isEmpty {
                Text("没有任务\n点上面的 ＋ 添加")
                    .font(.system(size: 13))
                    .foregroundColor(TG.textTertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                ForEach(items) { t in
                    HStack(spacing: 8) {
                        Button {
                            withAnimation { store.toggleTodo(t.id) }
                        } label: {
                            Image(systemName: t.done ? "checkmark.square.fill" : "square")
                                .foregroundColor(t.done ? color : TG.stroke)
                        }
                        .buttonStyle(.plain)
                        Text(t.text)
                            .font(.system(size: 14))
                            .strikethrough(t.done)
                            .foregroundColor(t.done ? TG.textTertiary : TG.textPrimary)
                            .lineLimit(2)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editTarget = (t.id, t.text) }
                    .contextMenu {
                        Button("编辑") { editTarget = (t.id, t.text) }
                        Button("删除", role: .destructive) { store.deleteTodo(t.id) }
                    }
                }
            }
        }
        .padding(14)
        .frame(minHeight: 150, alignment: .top)
        .background(TG.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(TG.stroke, lineWidth: 1))
        .alert("添加到「\(TG.quadTitles[addTarget ?? 0])」",
               isPresented: Binding(get: { addTarget != nil },
                                    set: { if !$0 { addTarget = nil } })) {
            TextField("要做什么？", text: $addText)
            Button("添加") {
                if let q = addTarget { store.addQuadrantTodo(addText, quadrant: q) }
                addText = ""; addTarget = nil
            }
            Button("取消", role: .cancel) { addTarget = nil }
        }
        .alert("修改任务", isPresented: Binding(get: { editTarget != nil },
                                               set: { if !$0 { editTarget = nil } })) {
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

    @State private var addTarget: Int?
    @State private var addText = ""
    @State private var editTarget: (Int, String)?
}
