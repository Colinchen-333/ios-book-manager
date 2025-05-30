import SwiftUI

@main
struct YourApp: App {
    @StateObject private var bookManager = BookManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bookManager) // 注入BookManager
        }
    }
}
