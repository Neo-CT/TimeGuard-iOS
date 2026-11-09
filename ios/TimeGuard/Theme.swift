import SwiftUI

/// 薄荷绿主题（与安卓版 colors.xml 对齐）
enum TG {
    static let bg = Color(hex: 0xEFF7F4)
    static let surface = Color.white
    static let brand = Color(hex: 0x62BFA4)
    static let brandDark = Color(hex: 0x2F7D68)
    static let brandSoft = Color(hex: 0xE1F3EC)
    static let textPrimary = Color(hex: 0x20312B)
    static let textSecondary = Color(hex: 0x64766F)
    static let textTertiary = Color(hex: 0x96A69F)
    static let stroke = Color(hex: 0xDCEBE5)

    /// 四象限配色（与安卓 MatrixFragment 一致）
    static let quadColors: [Color] = [
        Color(hex: 0xD97975), Color(hex: 0xC59A35),
        Color(hex: 0x7184BD), Color(hex: 0x55A98F)
    ]
    static let quadTitles = ["Ⅰ 重要且紧急", "Ⅱ 重要不紧急", "Ⅲ 不重要但紧急", "Ⅳ 不重要不紧急"]
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
