# TimeGuard 苹果版安装指南（手把手）

## 你需要准备什么

| 条件 | 说明 |
|------|------|
| 一台 Mac 电脑 | Xcode 只能运行在 macOS 上，Windows 装不了 |
| Xcode 15 或更新 | App Store 免费下载（约 10GB，留够磁盘空间） |
| 一个 Apple ID | 免费账号就能真机安装；付费开发者账号（¥688/年）不是必需的 |

> 没有 Mac 的话，这台 Windows 上无论用什么办法（虚拟机、黑苹果、在线编译）都又慢又不稳，不建议折腾。借一台 Mac 一小时内能搞定。

## 第一步：新建工程

1. 打开 Xcode → 菜单栏 **File → New → Project…**
2. 选 **iOS → App** → Next
3. 填写：
   - Product Name：`TimeGuard`
   - Interface：**SwiftUI**
   - Language：**Swift**
   - Bundle Identifier：`com.neo.timeguard`（改成你自己的倒域名也行，记住它，后面要用）
   - Storage：**None**
   - 取消勾选 Core Data、Include Tests
4. 保存位置随意（比如桌面）

## 第二步：放入源码

1. 在 Finder 中打开 `TimeGuard/ios/TimeGuard/` 文件夹（9 个 .swift 文件）
2. 全选，**拖进 Xcode 左侧的项目导航栏**（拖到黄色文件夹图标 TimeGuard 上）
3. 弹出对话框务必勾选：
   - ✅ **Copy items if needed**
   - ✅ **TimeGuard**（加到当前 target）
4. Xcode 会自动识别出多个文件里有 `App` 入口——新建的工程自带一个 `TimeGuardApp.swift`，会和我们源码包里的 `TimeGuardApp.swift` 冲突：
   - **删除工程自带的** `TimeGuardApp.swift`（右键 → Delete → Move to Trash）
   - **删除工程自带的** `ContentView.swift`（我们的源码包里已包含）
   - Preview 相关的 `#Preview` 报错不影响真机运行，可忽略或删掉
5. 此时工程里应只有我们源码包的 9 个文件 + `Assets.xcassets`

## 第三步：选设备运行

### 方式 A：真机 iPhone（推荐）

1. iPhone 用数据线连 Mac；iPhone 上：**设置 → 通用 → VPN与设备管理** 先放着不动
2. Xcode 顶部设备栏选你的 iPhone（第一次会提示 "Trust this computer"，两边都点信任）
3. 点 ▶ 运行。第一次会报签名错误，点 fix：
   - **Signing & Capabilities** 标签 → Team 选你的 Apple ID（免费账号就选 Personal Team）
   - Bundle Identifier 若提示被占用，改个后缀如 `com.neo.timeguard.ios`
4. 再次 ▶ 运行，等编译完 App 就装进手机了
5. **最后一步（必做）**：iPhone 上 **设置 → 通用 → VPN与设备管理 → 开发者 App** → 信任你的 Apple ID。不点信任的话 App 一打开就闪退

> 免费账号签名的 App **7 天会过期**，过期后重新连 Mac 在 Xcode 里 ▶ 跑一次即可续期，数据不会丢（存在本机 Documents）。想永久不过期需要付费开发者账号。

### 方式 B：模拟器（最快看到效果）

1. Xcode 顶部设备栏选 **iPhone 15**（或任意模拟器）
2. 点 ▶，几十秒就能看到 App 跑起来。模拟器不能装到你手机上，只适合先预览

## 常见问题

| 问题 | 解决 |
|------|------|
| 编译报 "Multiple commands produce…" | 工程自带的旧文件没删干净，删掉自带的 App/ContentView swift |
| 真机打开闪退 | 忘了在 设置→通用→VPN与设备管理 里信任开发者证书 |
| "Unable to install" | Bundle ID 与别人重复，改后缀；或手机存储空间不足 |
| 7 天后 App 打不开 | 免费签名的限制，连回 Mac 在 Xcode 再运行一次即可 |
| 想发给别人安装 | 免费账号不行。需要付费开发者账号走 TestFlight（或对方也有 Mac 按本指南自己装） |

## 装完之后

界面和安卓版一致：底部 6 个标签（待办/日历/四象限/番茄钟/习惯/监控），待办里点 ＋ 新建清单。数据只存在手机本地，卸载 App 会清空。
