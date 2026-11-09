import SwiftUI

/// 番茄钟：倒计时 / 正计时、暂停继续、15/25/45/60 与自定义分钟。
/// 与安卓版一样：切到别的标签页再回来，按真实经过时间继续走。
struct PomodoroView: View {
    @EnvironmentObject private var store: Store

    private enum Mode: String { case countdown, countup }

    @AppStorage("pomo.mode") private var modeRaw = Mode.countdown.rawValue
    @AppStorage("pomo.minutes") private var totalMinutes = 25
    @AppStorage("pomo.running") private var running = false
    @AppStorage("pomo.baseElapsed") private var baseElapsed: Double = 0
    @AppStorage("pomo.remainAtSegStart") private var remainAtSegStart: Double = 25 * 60
    @AppStorage("pomo.segStart") private var segStart: Double = 0

    @State private var now = Date()
    @State private var finished = false

    private var mode: Mode {
        get { Mode(rawValue: modeRaw) ?? .countdown }
        nonmutating set { modeRaw = newValue.rawValue }
    }

    /// 倒计时 = 剩余秒；正计时 = 已专注秒
    private var currentSeconds: Double {
        let segment = running ? now.timeIntervalSince1970 - segStart : 0
        if mode == .countup { return baseElapsed + segment }
        return max(0, remainAtSegStart - segment)
    }

    private var progress: Double {
        if mode == .countdown {
            return totalMinutes > 0 ? 1 - currentSeconds / Double(totalMinutes * 60) : 0
        }
        return (currentSeconds.truncatingRemainder(dividingBy: 60)) / 60
    }

    private var timeText: String {
        let s = Int(currentSeconds)
        let h = s / 3600, m = s % 3600 / 60, sec = s % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, sec)
                     : String(format: "%02d:%02d", m, sec)
    }

    private var label: String {
        if finished { return "本次专注已完成" }
        if running && mode == .countdown { return "专注中 · 共 \(totalMinutes) 分钟" }
        if running { return "正在记录专注时间" }
        if mode == .countdown && currentSeconds < Double(totalMinutes * 60) { return "已暂停 · 随时继续" }
        if mode == .countdown { return "准备专注 \(totalMinutes) 分钟" }
        return currentSeconds > 0 ? "已暂停 · 随时继续" : "从零开始，记录专注"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                modePicker
                ring
                if mode == .countdown { presets }
                controls
            }
            .padding()
            .background(TG.bg)
            .navigationTitle("番茄钟")
            .onAppear {
                // 跨页面恢复：把离开期间的流逝时间结算进基准值
                settleSegment()
                Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { t in
                    now = Date()
                    if mode == .countdown && running && currentSeconds <= 0 {
                        finish()
                    }
                    // 页面不可见时 timer 可能停走，每次 tick 都校准
                    if running { settleSegment(keepRunning: true) }
                }
            }
        }
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach([Mode.countdown, Mode.countup], id: \.rawValue) { m in
                Button {
                    if running { pause() }
                    mode = m
                    reset()
                } label: {
                    Text(m == .countdown ? "倒计时" : "正计时")
                        .font(.system(size: 14, weight: mode == m ? .bold : .regular))
                        .foregroundColor(mode == m ? TG.brandDark : TG.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(mode == m ? Color.white : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color(hex: 0xE5EEE9))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(TG.stroke, lineWidth: 10)
            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(TG.brand, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: progress)
            VStack(spacing: 6) {
                Text(timeText)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(TG.textPrimary)
                    .monospacedDigit()
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(TG.textSecondary)
            }
        }
        .frame(width: 250, height: 250)
    }

    private var presets: some View {
        let values = [15, 25, 45, 60]
        return HStack(spacing: 8) {
            ForEach(values, id: \.self) { v in
                presetButton("\(v)", selected: totalMinutes == v) { setMinutes(v) }
            }
            presetButton("自定义", selected: !values.contains(totalMinutes)) { showCustom = true }
        }
        .alert("自定义时长（分钟）", isPresented: $showCustom) {
            TextField("输入 1 到 1440", text: $customText)
                .keyboardType(.numberPad)
            Button("确定") {
                if let v = Int(customText), v >= 1, v <= 1440 { setMinutes(v) }
                showCustom = false
            }
            Button("取消", role: .cancel) { showCustom = false }
        }
    }

    @State private var showCustom = false
    @State private var customText = ""

    private func presetButton(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: selected ? .bold : .regular))
                .foregroundColor(selected ? .white : TG.textSecondary)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(selected ? TG.brand : Color.clear)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selected ? Color.clear : TG.stroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var controls: some View {
        HStack(spacing: 14) {
            Button {
                if running { pause() } else { start() }
            } label: {
                Text(running ? "暂停" : (currentSeconds > 0 && currentSeconds < Double(totalMinutes * 60) || mode == .countup && currentSeconds > 0 ? "继续" : "开始"))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 48)
                    .background(TG.brand)
                    .clipShape(Capsule())
            }
            Button(action: reset) {
                Text("重置")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(TG.textPrimary)
                    .frame(width: 96, height: 48)
                    .background(TG.surface)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(TG.stroke, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: 计时逻辑

    private func setMinutes(_ v: Int) {
        totalMinutes = v
        reset()
    }

    private func start() {
        if mode == .countdown && currentSeconds <= 0 {
            remainAtSegStart = Double(totalMinutes * 60)
        }
        running = true
        segStart = Date().timeIntervalSince1970
        finished = false
    }

    private func pause() {
        settleSegment()
        running = false
    }

    private func reset() {
        running = false
        baseElapsed = 0
        remainAtSegStart = Double(totalMinutes * 60)
        segStart = 0
        finished = false
    }

    private func finish() {
        running = false
        remainAtSegStart = 0
        baseElapsed = 0
        segStart = 0
        finished = true
    }

    /// 把当前运行段流逝的时间并入基准值（暂停/页面恢复时调用），
    /// 这样即使 timer 停了再启动，也不会丢时间、不会跳变。
    private func settleSegment(keepRunning: Bool = false) {
        guard running else { return }
        let segment = now.timeIntervalSince1970 - segStart
        guard segment >= 0 else { return }
        if mode == .countup {
            baseElapsed += segment
        } else {
            remainAtSegStart = max(0, remainAtSegStart - segment)
        }
        segStart = now.timeIntervalSince1970
    }
}
