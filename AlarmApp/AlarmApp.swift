import SwiftUI

enum SunriseTheme {
    static let tint = Color(red: 1, green: 0.57, blue: 0.22)
    static let symbol = "sunrise.fill"
    static let alarmTitle: LocalizedStringResource = "Rise & shine"
    static let openButtonTitle: LocalizedStringResource = "Open Sunrise"
    static let background = LinearGradient(
        colors: [Color(red: 0.10, green: 0.07, blue: 0.19),
                 Color(red: 0.30, green: 0.12, blue: 0.16)],
        startPoint: .top,
        endPoint: .bottom
    )
}

@main
struct AlarmApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
