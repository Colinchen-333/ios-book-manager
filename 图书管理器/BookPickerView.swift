import SwiftUI

struct BookPickerView: View {
    @ObservedObject var bookManager: BookManager
    @Binding var selectedBook: Book?
    @Binding var isCountdown: Bool
    @Binding var countdownTime: TimeInterval
    @State private var showGuide: Bool = false
    @State private var actualReadingTime: TimeInterval = 0 // 添加用于存储实际阅读时间的状态变量
    var startReading: (TimeInterval) -> Void // 修改为接受阅读时间的回调

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("选择书籍")) {
                    Picker("书籍", selection: $selectedBook) {
                        ForEach(bookManager.folders.flatMap { $0.books }, id: \.id) { book in
                            Text(book.title).tag(book as Book?)
                        }
                    }
                }

                Section(header: Text("计时模式")) {
                    Toggle("倒计时模式", isOn: $isCountdown)
                    if isCountdown {
                        Slider(value: $countdownTime, in: 300...7200, step: 300) {
                            Text("倒计时时间")
                        }
                        Text("时间: \(countdownTime / 60, specifier: "%.0f") 分钟")
                    } else {
                        Text("正计时模式已选中")
                    }
                }
            }
            .navigationBarItems(trailing: Button("开始阅读") {
                showGuide = true
            })
            .navigationBarTitle("选择书籍", displayMode: .inline)
            .fullScreenCover(isPresented: $showGuide) {
                ReadingModeGuideView {
                    showGuide = false
                    startReadingSession() // 根据选择的模式开始阅读并计算时间
                }
            }
        }
    }
    
    private func startReadingSession() {
        if isCountdown {
            actualReadingTime = countdownTime // 倒计时模式下，直接使用设置的倒计时时间
        } else {
            actualReadingTime = calculateElapsedTime() // 正计时模式下，计算实际的阅读时间
        }
        startReading(actualReadingTime) // 将计算的阅读时间传递给回调
    }

    private func calculateElapsedTime() -> TimeInterval {
        // 在正计时模式下开始时调用，用于启动计时器
        let startTime = Date()
        
        // 返回一个伪代码，实际应用中应该根据阅读结束时的时间减去startTime来计算实际阅读时长
        let endTime = Date() // 在实际场景中，这应该是用户结束阅读的时间
        return endTime.timeIntervalSince(startTime) // 计算时间差（秒）
    }
}
