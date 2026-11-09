# TimeGuard 苹果版（iOS / SwiftUI）

与安卓版 TimeGuard v0.7.2 对应的 iOS 版本，界面与交互尽量一致：底部 6 个标签（待办 / 日历 / 四象限 / 番茄钟 / 习惯 / 监控），薄荷绿浅色主题。

## 能力边界（先说清楚）

| 功能 | iOS 上能否实现 | 说明 |
|------|----------------|------|
| 待办多清单 | ✅ 完全支持 | 与安卓一致 |
| 日历（年月周日视图） | ✅ 支持 | 月视图 + 日程，精简实现 |
| 四象限 | ✅ 完全支持 | 与安卓一致 |
| 番茄钟（倒计时/正计时） | ✅ 完全支持 | 与安卓一致 |
| 习惯打卡 | ✅ 完全支持 | 与安卓一致 |
| 应用监控 / 悬浮窗 / 微信关键词解锁 | ❌ 平台不允许 | iOS 无无障碍服务、无悬浮窗权限；Family Controls 需苹果审批且做不到微信文本识别。监控页做成了说明页 |

## 怎么用

### 没有 Mac：云端编译（推荐）

直接查看 **[无Mac云端编译指南.md](./无Mac云端编译指南.md)**。流程是：

1. 把 `ios` 与 `.github/workflows/ios-build.yml` 上传到 GitHub 仓库；
2. 在 Actions 里运行 **Build TimeGuard iOS IPA**；
3. 下载未签名 IPA；
4. 在 Windows 上用 Sideloadly + Apple ID 签名安装到 iPhone。

### 有 Mac：本地 Xcode 运行

1. 在 Mac 上打开 Xcode → 新建 Project → iOS App（SwiftUI，Bundle ID 自取，如 `com.neo.timeguard`）
2. 把本目录 `TimeGuard/` 下的所有 `.swift` 文件拖进工程（勾选 Copy items）
3. 直接 Run（iPhone 真机或模拟器均可）

数据存于 App Documents 目录的 `timeguard.json`，不联网、不上传。

## 文件结构

```
TimeGuard/
├── TimeGuardApp.swift    入口 + TabView 底部导航
├── Theme.swift           薄荷绿配色
├── Store.swift           数据模型 + JSON 持久化（ObservableObject）
├── TodoView.swift        待办多清单
├── CalendarView.swift    月视图日历 + 日程
├── MatrixView.swift      四象限
├── PomodoroView.swift    番茄钟（倒计时/正计时）
├── HabitsView.swift      习惯打卡
└── MonitorView.swift     监控说明页
```
