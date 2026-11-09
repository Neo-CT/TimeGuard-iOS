import SwiftUI

/// 监控页：iOS 无法提供安卓版的应用监控能力，这里如实说明。
/// iOS 没有无障碍服务 / 悬浮窗权限，做不到实时读取其他 App、悬浮胶囊和
/// 微信关键词解锁；Family Controls（iOS 16+）可限制指定 App，但需要苹果
/// 开发者账号申请专用 entitlement，且与微信文本识别无关。
struct MonitorView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("苹果版说明")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(TG.textPrimary)
                    Text("iOS 系统不允许 App 监控其他应用，安卓版的这些能力在苹果设备上无法实现：")
                        .font(.system(size: 13))
                        .foregroundColor(TG.textSecondary)

                    capability("前台应用监听 / 悬浮状态胶囊", available: false,
                               note: "系统没有无障碍服务，也没有悬浮窗权限")
                    capability("哔哩哔哩每日次数 / 25 分钟会话限制", available: false,
                               note: "无法感知其他 App 的使用过程")
                    capability("微信聊天关键词解锁游戏", available: false,
                               note: "任何 App 都读不到微信聊天内容")
                    capability("Family Controls 限制指定 App（iOS 16+）", available: true,
                               note: "可行但需苹果开发者账号申请权限，且做不到关键词条件解锁；如需要可后续开发")

                    Text("上方的待办、日历、四象限、番茄钟和习惯与安卓版功能一致，数据只存在本机。")
                        .font(.system(size: 13))
                        .foregroundColor(TG.textSecondary)
                        .padding(.top, 6)
                }
                .padding(20)
            }
            .background(TG.bg)
            .navigationTitle("监控")
        }
    }

    private func capability(_ name: String, available: Bool, note: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(available ? TG.brand : Color(hex: 0xC4534E))
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(TG.textPrimary)
                Text(note)
                    .font(.system(size: 12))
                    .foregroundColor(TG.textTertiary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TG.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(TG.stroke, lineWidth: 1))
    }
}
