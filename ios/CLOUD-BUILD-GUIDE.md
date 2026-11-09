# TimeGuard 苹果版：无 Mac 云端编译与安装指南

这份方案不需要 Mac：用 GitHub Actions 的 macOS 云端环境编译出 IPA，再在你的 Windows 电脑上签名安装到 iPhone。

> 注意：云端编译出来的是**未签名 IPA**。iPhone 不能直接安装未签名应用，需要在你的 Windows 上用 Sideloadly 和 Apple ID 做一次签名安装。

## 你需要准备

- 一个 GitHub 账号
- 一台 Windows 电脑
- 一台 iPhone（iOS 16 或更新）
- 一个 Apple 账户（原 Apple ID）：**免费注册，不需要 Mac、不需要绑卡**；没有的话看 `GitHub新手入门.md` 的"补充：没有 Apple ID？"
- 一条数据线，或让 iPhone 和电脑处于同一 Wi-Fi

## 第一步：上传源码到 GitHub

1. 解压 `TimeGuard-iOS-cloud-build.zip`。
2. 打开 GitHub，新建一个仓库，例如 `TimeGuard-iOS`。
3. 把压缩包解压后的内容上传到仓库根目录，确保最后仓库里有：
   - `ios/TimeGuard/*.swift`
   - `ios/project.yml`
   - `.github/workflows/ios-build.yml`
4. 如果没有 Git 基础，可以在 GitHub 网页点 **Add file → Upload files**，直接拖入解压后的 `ios` 文件夹和 `.github` 文件夹。

### 费用说明

- **公共仓库**：标准 GitHub 托管 runner 免费。
- **私有仓库**：macOS runner 会消耗账号额度，跑完后 GitHub 可能要求绑卡/充值。

建议先用公共仓库测试。

## 第二步：触发云端编译

1. 进入仓库顶部的 **Actions** 标签页。
2. 左侧选择 **Build TimeGuard iOS IPA**。
3. 点右侧 **Run workflow → Run workflow**。
4. 等待约 10～20 分钟。第一次运行可能需要排队。
5. 绿色勾完成后，点进这次运行记录，底部 **Artifacts** 里下载：
   **TimeGuard-unsigned-ipa**

如果失败：点进红色运行记录，把报错日志最后几十行截图发给我，我可以继续修。

## 第三步：在 Windows 上签名安装

1. 在 iPhone 上打开：**设置 → 通用 → VPN与设备管理**，先不用操作。
2. 在 Windows 安装 Sideloadly：  
   https://sideloadly.io/
3. 用数据线连接 iPhone 和 Windows；手机上点“信任此电脑”。
4. 打开 Sideloadly：
   - 把下载到的 `TimeGuard-unsigned-ipa.zip` 解压，得到 `TimeGuard-unsigned.ipa`
   - 将 IPA 拖进 Sideloadly
   - 输入你的 Apple ID
   - 点 **Start / 开始**
5. 如果 Apple ID 开了双重认证，按提示输入验证码。
6. 安装完成后，在 iPhone 上进入：  
   **设置 → 通用 → VPN与设备管理 → 开发者 App**  
   信任刚才用于签名的 Apple ID。

不点“信任”，App 会一打开就闪退。

## 免费签名的限制

- 免费 Apple ID 签名的 App **7 天后会过期**。
- 快到期时，把 iPhone 连回 Windows，用 Sideloadly 重新安装/刷新同一个 IPA。
- 不要先删除旧 App，直接覆盖刷新，本地数据通常能保留。
- Sideloadly 支持自动续签，但不要完全依赖它；App 打不开时重新刷新即可。

## 常见问题

| 问题 | 处理 |
|------|------|
| GitHub Actions 里没有工作流 | 确认 `.github/workflows/ios-build.yml` 在仓库根目录，不是在 `ios` 里面 |
| Actions 被禁用 | 仓库 **Settings → Actions → General → Actions permissions** 选 Allow |
| Sideloadly 识别不到 iPhone | 换数据线/换 USB 口；确认手机点了“信任”；必要时安装苹果官网版 iTunes/iCloud 驱动 |
| 安装时报签名错误 | 换一个 Apple ID 或稍后再试；免费签名有苹果侧限制 |
| App 打开闪退 | 多半是未在 **VPN与设备管理** 里信任开发者 |
| 7 天后打不开 | 免费签名到期，用 Sideloadly 刷新 |
| 想长期使用 | 需要 Apple Developer Program（99 美元/年）或上架 App Store |

## 重要安全提醒

不要把 Apple ID 密码发给任何人，也不要把它发在聊天里。只在你自己下载并信任的 Sideloadly 软件里输入。
