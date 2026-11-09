# GitHub 是什么？零基础手把手教程

> 目标：不用 Mac，把 TimeGuard 苹果版编译成 IPA，再装到 iPhone。

## 一、先用大白话解释几个词

| 词 | 你可以理解成 | 在这件事里的作用 |
|---|---|---|
| GitHub | 一个免费的"代码网盘"，额外附带云端电脑 | 存放我们写好的 Swift 源码，并借它的 Mac 来编译 |
| 仓库（Repository） | 网盘里的一个文件夹/一个项目 | 新建一个叫 `TimeGuard-iOS` 的文件夹，把源码放进去 |
| Actions | 网盘附带的"自动任务按钮" | 点一下，云端 Mac 就开始编译 |
| workflow 文件 | 写给云端 Mac 的一张"操作清单" | 已经放在 `.github/workflows/ios-build.yml`，你不用改 |
| Artifact（产物） | 云端电脑做完之后交给你的文件 | 就是编译出来的 `TimeGuard-unsigned-ipa.zip` |
| IPA | iPhone 的安装包（类似安卓的 APK） | 下载后用 Sideloadly 装进手机 |

### 那个以点开头的 `.github` 文件夹到底是什么？

它**不是 App 的代码**，也不是要装到你电脑上的东西。它只是 GitHub 规定的一个**固定名字的配置文件夹**：

- GitHub 会自动去仓库里找 `.github/workflows/` 这个位置
- 里面放一个 `.yml` 文本文件（我们的是 `ios-build.yml`），内容就是写给云端 Mac 的一张「操作清单」：装工具 → 生成 Xcode 工程 → 编译 → 打包成 IPA
- 只要这个文件在，仓库顶部的 **Actions** 里才会出现 **Build TimeGuard iOS IPA** 这个能点的运行按钮
- 名字必须一字不差：开头那个**点**、中间的**斜杠**都不能改（不能叫 `github`，也不能放进 `ios` 文件夹里面）

开头带点的文件夹在 Windows 上常被当成「隐藏项目」，网页拖文件夹上传时也容易被浏览器跳过 —— **解压后找不到它、或传完仓库里看不到它，都是正常现象**。所以第四步推荐：只拖 `ios` 文件夹，`.github` 用「新建文件」的方式手动补，一次就成。

**一句话流程**：注册账号 → 上传源码 → 点运行 → 下载 IPA → Windows 上装进手机。

GitHub 账号是**免费的**。公共仓库的编译也免费（私有仓库会消耗额度，可能要绑卡，所以建议选 Public）。

---

## 二、第一步：注册 GitHub 账号（约 3 分钟）

1. 打开浏览器，访问：**https://github.com/**
2. 点右上角 **Sign up**（注册）
3. 依次填：
   - **Email**：你的邮箱（QQ 邮箱、163、Outlook 都行）
   - **Password**：设一个密码
   - **Username**：起个英文用户名，比如 `neo-timeguard`（只能英文/数字/横线）
4. 按提示做一下人机验证、输入邮箱收到的验证码
5. 问你"要付费吗"时选 **Free / 免费** 那一项，跳过问卷即可

> 如果页面是英文，Chrome / Edge 右键 → "翻译成中文" 就能看懂。

---

## 三、第二步：新建仓库（约 1 分钟）

1. 登录后，点右上角 **＋** → **New repository**
2. 填写：
   - **Repository name**：`TimeGuard-iOS`
   - **Description**：可不填
   - **Public / Private**：一定选 **Public**（公共仓库免费编译）
   - **Add a README file**：**不用勾**（我们上传的文件里已有说明）
   - 其他都保持默认
3. 拉到底点绿色按钮 **Create repository**

---

## 四、第三步：上传源码（约 2 分钟）

> **先确认你在哪一页**：`Add file` 按钮只在**有文件的仓库页面**出现（网址长这样：`github.com/你的用户名/TimeGuard-iOS`）。
> - 如果看到的是左侧 Home / Feed 的首页：那里没有这个按钮，请先按第二步新建仓库。
> - 如果看到的是 **"Quick setup — if you've done this kind of thing before"** 引导页（仓库刚建好、一个文件都还没有，**最常见**）：也没有 Add file 按钮。点中间那行小字里的蓝色 **uploading existing files**，就进入上传页了。
> - 也可以直接在浏览器打开：`https://github.com/你的用户名/TimeGuard-iOS/upload/main`（把用户名换成你自己的）

1. 先在本机解压 **`TimeGuard-iOS-cloud-build.zip`**，会看到 `README.txt`、`上传-工作流.yml`、`ios` 文件夹、`.github` 文件夹
2. 进入**仓库页面**，点文件列表上方的 **Add file → Upload files**（按钮那一排：左 Go to file、中 Add file、右绿色 <> Code）
3. **只把 `ios` 文件夹**拖进上传框（不用管 `.github`），拉到底点绿色的 **Commit changes / Propose changes**（两个名字是同一个按钮）
4. 接着点 **Add file → Create new file**，文件名一栏**原样填**：`.github/workflows/ios-build.yml`
   （开头有点、中间有斜杠，GitHub 会自动建出这两层文件夹）
5. 用记事本打开解压包里的 **`上传-工作流.yml`**，全选复制，粘贴进编辑框；再点 **Commit changes**

> 也可以把 `.github` 文件夹一起拖进去，但以点开头的文件夹经常被浏览器跳过，**不如上面这样稳**。

### 上传后请核对

- 仓库首页有 `ios` 文件夹，点进去能看到 `TimeGuard` 文件夹和 9 个 `.swift` 文件
- 顶部 **Actions** 里能看到 **Build TimeGuard iOS IPA** —— 如果看不到，说明第 4 步的文件名没写对，回去检查
- 教程末尾「附：工作流文件内容」是同一份内容，包里找不到文件时可以直接从那里复制

只要 `ios` 文件夹和这一个工作流文件都在，就能编译。

### 出现 "This file is hidden." 提示

**这是正常提示，不是错误。** 以点开头的文件/文件夹在 GitHub 眼里就是「隐藏文件」，`.github` 本来就该是隐藏目录；GitHub Actions 照常读取，工作流会正常生效。

- 上传页的文件列表里**已经列出** `ios-build.yml` 或 `.github/workflows/ios-build.yml`：直接点 Commit changes，不用管这句提示
- 列表是空的（部分浏览器拖隐藏文件夹会直接跳过）：改用新建文件，可打开直达链接
  `https://github.com/你的用户名/TimeGuard-iOS/new/main?filename=.github/workflows/ios-build.yml`
  （会自动填好文件名；若框是空的就手动逐字敲一遍），内容从 `WORKFLOW-TO-PASTE.yml` 复制
- 仓库首页看不到 `.github` 文件夹也正常（隐藏目录默认不显示），**以 Actions 里有没有 "Build TimeGuard iOS IPA" 为准**

### 出现 "Add some files to include in this commit."

意思是这次提交里**一个文件都没有**：拖以点开头的 `.github` 文件夹时，GitHub 会把它当隐藏文件整包跳过，所以提交区是空的。

**先别急着重传**：点仓库顶部 **Actions**。如果左侧已经有 **Build TimeGuard iOS IPA**，说明工作流其实早就在仓库里了（隐藏目录在首页不显示），直接 Run workflow 即可。

Actions 里没有，才改用上面的「新建文件 + 直达链接」。注意先 **F5 刷新**仓库首页，打开链接后尽快填内容提交，别让编辑页停留太久（放久了再提交容易报下面的错）。

### 如果提交时弹出红字 "File could not be edited"

这是 GitHub 网页新建文件很常见的抽风（页面会话过期、或文件名里混进了看不见的空格），**不是你填错内容**。按顺序试：

1. 点 **Cancel** → 按 **F5** 刷新仓库首页 → 重新 **Add file → Create new file**，文件名**手动逐字敲** `.github/workflows/ios-build.yml`（不要从别处复制粘贴，容易带上隐藏空格），内容重新粘贴 → 提交
2. 还不行就别用网页新建了：打开 `https://github.com/你的用户名/TimeGuard-iOS/upload/main`，把解压包里现成的 **`.github` 文件夹**整个拖进上传框提交。路径由文件夹结构自动带过去，不用手打，成功率最高。仓库里已有 `ios` 的话**不用再拖一遍**
3. 再不行：换 Edge/Chrome 无痕窗口登录后重试（清掉旧 cookie 常常就好了）

---

## 五、第四步：让云端 Mac 开始编译（约 10～20 分钟）

1. 点仓库顶部的 **Actions** 标签
2. 如果第一次进来提示 "Workflows aren't being run" 或要启用，点 **I understand my workflows, go ahead and enable them**
3. 左侧列表点 **Build TimeGuard iOS IPA**
4. 右侧会出现 **Run workflow** 下拉按钮 → 点它 → 再点绿色的 **Run workflow**
5. 刷新页面，会出现一条正在转圈的运行记录，点进去可以看实时日志
6. 等它变成 ✅ 绿色勾（第一次可能要排队几分钟）

### 如果变成红色 ❌

点进这条失败记录 → 点 `build` 那一步 → 把日志最后 30 行截图发给我，我帮你改代码/config 后你重新上传再跑一次。**不需要你自己看懂报错**。

---

## 六、第五步：下载编译好的 IPA

1. 在这条成功的运行记录页面，拉到最下面 **Artifacts**
2. 点 **TimeGuard-unsigned-ipa** 下载（是个 zip）
3. 解压得到 **`TimeGuard-unsigned.ipa`**

> 它是"未签名"的，iPhone 不能直接装，下一步要在你的 Windows 上签一下名。

---

## 七、第六步：装进 iPhone（Windows 上完成）

1. 下载安装 **Sideloadly**：https://sideloadly.io/ （点 Windows 版）
2. iPhone 用数据线连电脑，手机上点 **信任此电脑**
3. 打开 Sideloadly → 把 `TimeGuard-unsigned.ipa` 拖进去
4. 输入你的 **Apple ID**（免费账号就行）→ 点 **Start**
5. 若弹出双重认证，按提示输入手机收到的验证码
6. 装完后在 iPhone 上：**设置 → 通用 → VPN与设备管理 → 开发者 App** → 点你的 Apple ID → **信任**

⚠️ **不点"信任"，App 一打开就会闪退**，这是最常见的问题。

免费签名 **7 天过期**，到期前连回电脑用 Sideloadly 重新刷一次（别先删 App，数据会保留）。

---

## 八、安全提醒

- Apple ID 密码**只在你自己电脑上的 Sideloadly 里输入**，不要发给任何人、不要发聊天里。
- 上传到 GitHub 的只有程序源码，不含你的任何账号或数据。
- 公共仓库别人能看到源码，但这套代码里没有隐私信息，可以放心。

---

## 补充：没有 Apple ID？免费注册一个（不用 Mac、不用花钱）

> 苹果现在把 "Apple ID" 改叫 **Apple 账户**，界面上看到哪个都指同一个东西。

在 Windows 上用浏览器就能注册，全程免费，**不需要先有苹果电脑**：

1. 打开 **https://account.apple.com/** → 点 **创建你的 Apple 账户**
2. 填一个常用邮箱（QQ / 163 / Outlook 都行）作为账号，设置强密码
3. 地区选 **中国大陆**，按提示填生日和 **+86 手机号**（大陆注册需要验证手机号）
4. 若问付款方式，选 **「无」**：只用来给 App 签名，不用绑卡、不会扣费
5. 去邮箱点验证链接，再输入手机收到的短信验证码

注册完建议多做一步：在**你自己的 iPhone** 上打开 **设置 → 登录 iPhone**，登录一次这个账号并开启**双重认证**。新账号如果从没在苹果设备上登录过，Sideloadly 有时报 "session expired" 或签名失败；登录一次基本就好了。

### 免费账号的已知限制（都是正常现象）

| 限制 | 说明 |
|---|---|
| 签名 7 天过期 | 到期前用 Sideloadly 覆盖刷新，别先删 App |
| 最多同时装 3 个侧载 App | 超了要先删掉一个 |
| 每 7 天最多创建 10 个 App ID | 报这个错就等几天 |
| 不支持 App 内购买 | 本 App 没有内购，无影响 |

如果暂时不想注册：**可以先把 GitHub 云端编译跑完，把 IPA 下载存着**，等账号弄好再装，IPA 不会马上失效。也可以借家人的账号，但建议自己注册一个专用小号，别共用主账号。

---

## 附：工作流文件内容（仅在 `.github` 上传失败时手动粘贴）

```yaml
name: Build TimeGuard iOS IPA

on:
  workflow_dispatch:
  push:
    branches: [main]
    paths:
      - "ios/**"
      - ".github/workflows/ios-build.yml"

jobs:
  build:
    name: Build unsigned IPA on macOS
    runs-on: macos-latest

    steps:
      - name: Checkout source
        uses: actions/checkout@v4

      - name: Install XcodeGen
        run: brew install xcodegen

      - name: Generate Xcode project
        working-directory: ios
        run: xcodegen

      - name: Build unsigned iOS app
        working-directory: ios
        run: |
          set -euo pipefail
          xcodebuild \
            -project TimeGuard.xcodeproj \
            -scheme TimeGuard \
            -configuration Release \
            -destination 'generic/platform=iOS' \
            -derivedDataPath build \
            CODE_SIGNING_ALLOWED=NO

      - name: Package unsigned IPA
        working-directory: ios
        run: |
          set -euo pipefail
          APP_PATH="$PWD/build/Build/Products/Release-iphoneos/TimeGuard.app"
          test -d "$APP_PATH"
          rm -rf Payload TimeGuard-unsigned.ipa
          mkdir Payload
          cp -R "$APP_PATH" Payload/
          ditto -c -k --sequesterRsrc --keepParent Payload TimeGuard-unsigned.ipa

      - name: Upload IPA
        uses: actions/upload-artifact@v4
        with:
          name: TimeGuard-unsigned-ipa
          path: ios/TimeGuard-unsigned.ipa
          retention-days: 7
```
