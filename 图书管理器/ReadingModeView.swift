import SwiftUI
import UIKit

struct ReadingModeView: View {
    @ObservedObject var bookManager: BookManager
    @Binding var selectedBook: Book?
    var onSave: (Book, ReadingLog) -> Void
    
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?
    @State private var isShowingGuide = false
    @State private var isTimerRunning = false
    @State private var exitConfirmation = false
    @State private var showCompletionAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // 背景渐变色
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.8),  // 顶部颜色
                    Color(red: 0.6, green: 0.75, blue: 0.9)  // 底部颜色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 主内容
            VStack(spacing: 20) {
                // 书籍标题
                Text(selectedBook?.title ?? "未知书籍")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer()
                
                // 计时器显示
                VStack(spacing: 10) {
                    Text("阅读时长")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(formattedTime)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(minWidth: 200)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(20)
                }
                
                Spacer()
                
                // 控制按钮
                HStack(spacing: 30) {
                    // 帮助按钮
                    Button(action: {
                        isShowingGuide = true
                    }) {
                        VStack {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text("帮助")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(15)
                    }
                    
                    // 开始/暂停按钮
                    Button(action: {
                        toggleTimer()
                    }) {
                        VStack {
                            Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            Text(isTimerRunning ? "暂停" : "开始")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .frame(width: 80, height: 80)
                        .background(isTimerRunning ? Color.orange : Color(red: 0.4, green: 0.6, blue: 0.8))
                        .cornerRadius(40)
                        .shadow(radius: 5)
                    }
                    
                    // 完成按钮
                    Button(action: {
                        if elapsedSeconds > 0 {
                            showCompletionAlert = true
                        } else {
                            exitConfirmation = true
                        }
                    }) {
                        VStack {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text("完成")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .frame(width: 60, height: 60)
                        .background(Color.green)
                        .cornerRadius(15)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
            .sheet(isPresented: $isShowingGuide) {
                ReadingModeGuideView()
            }
            .alert(isPresented: $showCompletionAlert) {
                Alert(
                    title: Text("完成阅读"),
                    message: Text("你已阅读了\(formattedTime)，记录将被保存。"),
                    primaryButton: .default(Text("确定")) {
                        saveReadingLog()
                        stopTimer()
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("继续阅读")) {
                        // 继续阅读，不做任何事
                    }
                )
            }
            .alert(isPresented: $exitConfirmation) {
                Alert(
                    title: Text("退出阅读模式"),
                    message: Text("你确定要退出吗？当前没有记录任何阅读时间。"),
                    primaryButton: .destructive(Text("退出")) {
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .onDisappear {
                stopTimer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            if elapsedSeconds > 0 {
                showCompletionAlert = true
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                Text("返回")
                    .foregroundColor(.white)
            }
        })
    }
    
    private var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func toggleTimer() {
        isTimerRunning.toggle()
        
        if isTimerRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
    }
    
    private func saveReadingLog() {
        if let book = selectedBook {
            let log = ReadingLog(date: Date(), duration: Double(elapsedSeconds))
            onSave(book, log)
        }
    }
}
