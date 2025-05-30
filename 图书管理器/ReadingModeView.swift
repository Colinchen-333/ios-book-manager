import SwiftUI
import UIKit

struct ReadingModeView: View {
    @ObservedObject var bookManager: BookManager
    @Binding var selectedBook: Book?
    @Binding var selectedFolder: Folder?
    var onEndReading: ((Book, ReadingLog) -> Void)? // 可选的回调函数
    var onSave: ((Book, ReadingLog) -> Void)?
    
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var isTimerRunning = false
    @State private var isCountdown = false
    @State private var countdownTime: TimeInterval = 3600 // 默认倒计时1小时
    @State private var showBookPicker = false
    @Environment(\.presentationMode) var presentationMode
    
    private let currentDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.6, blue: 0.8),  // 深蓝灰色
                        Color(red: 0.7, green: 0.7, blue: 0.8)   // 浅蓝灰色
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 修改为横向布局
                HStack(spacing: 20) {
                    if let book = selectedBook {
                        // 左侧：书籍信息
                        VStack(alignment: .leading, spacing: 15) {
                            if let coverImage = book.coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(book.title)
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text(book.author)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.4)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        
                        // 右侧：阅读信息和控制
                        VStack(spacing: 20) {
                            Text("当前时间: \(Date(), formatter: currentDateFormatter)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            // 阅读时间显示
                            VStack(spacing: 15) {
                                if isCountdown {
                                    Text(countdownDisplay())
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    CountdownProgressBar(progress: CGFloat(elapsedTime / countdownTime))
                                        .frame(height: 20)
                                } else {
                                    Text(elapsedTimeDisplay())
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    ElapsedTimeProgressBar(progress: CGFloat(elapsedTime / countdownTime))
                                        .frame(height: 20)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            
                            // 控制按钮
                            Button(action: {
                                endReading(for: selectedBook)
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "stop.circle.fill")
                                    Text("结束阅读")
                                }
                                .font(.headline)
                                .padding()
                                .frame(width: 200)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                    } else {
                        Text("请选择一本书开始阅读")
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .navigationBarTitle("阅读模式", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showBookPicker) {
            BookPickerView(bookManager: bookManager, selectedBook: $selectedBook, isCountdown: $isCountdown, countdownTime: $countdownTime) {_ in 
                startReading() // 这里不需要传递参数，因为您没有使用参数
                showBookPicker = false
            }
        }
        .onAppear {
            // 设置导航栏样式
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            if isTimerRunning {
                enterLandscapeMode()
            } else {
                showBookPicker = true
            }
        }
        .onDisappear {
            exitLandscapeMode()
        }
    }
    
    private func startReading() {
        startTime = Date()
        isTimerRunning = true
        elapsedTime = 0
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if !self.isTimerRunning {
                timer.invalidate()
            } else {
                self.elapsedTime += 1 // 这里的单位是秒
            }
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if !self.isTimerRunning || self.elapsedTime >= self.countdownTime {
                timer.invalidate()
                self.endReading(for: self.selectedBook)
                self.presentationMode.wrappedValue.dismiss() // 返回主界面
            } else {
                self.elapsedTime += 1
            }
        }
    }
    
    private func endReading(for book: Book?) {
        guard let startTime = startTime, let book = book else { return }
        
        let logDuration = elapsedTime // 使用实际的阅读时间
        let log = ReadingLog(
            date: Date(), // 使用当前时间作为结束时间
            duration: logDuration
        )

        if let folder = selectedFolder,
           let folderIndex = bookManager.folders.firstIndex(where: { $0.id == folder.id }),
           let bookIndex = bookManager.folders[folderIndex].books.firstIndex(where: { $0.id == book.id }) {
            
            var updatedBook = bookManager.folders[folderIndex].books[bookIndex]
            updatedBook.readingLogs.append(log)
            updatedBook.lastReadDate = Date() // 更新最后阅读时间
            
            bookManager.folders[folderIndex].books[bookIndex] = updatedBook
            bookManager.saveFolders()
            
            selectedBook = updatedBook
            
            onEndReading?(updatedBook, log)
        }
        
        isTimerRunning = false
        elapsedTime = 0 // 重置时间
    }

    private func countdownDisplay() -> String {
        let remainingTime = countdownTime - elapsedTime
        if remainingTime > 60 {
            return "剩余时间: \(Int(remainingTime) / 60) 分钟"
        } else {
            return String(format: "剩余时间: %.0f 秒", remainingTime)
        }
    }
    
    private func elapsedTimeDisplay() -> String {
        if elapsedTime > 60 {
            return "阅读时间: \(Int(elapsedTime) / 60) 分钟"
        } else {
            return String(format: "阅读时间: %.0f 秒", elapsedTime)
        }
    }

    private func enterLandscapeMode() {
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.orientationLock = .landscape
        }
    }

    private func exitLandscapeMode() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.orientationLock = .all
        }
    }
}

// 圆润的正计时进度条
struct ElapsedTimeProgressBar: View {
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 10)
                    .foregroundColor(.gray)
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: geometry.size.width * progress, height: 10)
                    .foregroundColor(.green)
            }
        }
    }
}

// 圆润的倒计时进度条
struct CountdownProgressBar: View {
    var progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 10)
                    .foregroundColor(.gray)
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: geometry.size.width * (1 - progress), height: 10)
                    .foregroundColor(.red)
            }
        }
    }
}
