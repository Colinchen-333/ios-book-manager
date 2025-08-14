import SwiftUI

struct AddReadingLogView: View {
    @Binding var book: Book
    var folder: Folder  // 改为普通的 Folder 类型
    @ObservedObject var bookManager: BookManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var duration: TimeInterval = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("阅读日期", selection: $date, displayedComponents: .date)
                
                DatePicker("开始时间", selection: $startTime, displayedComponents: .hourAndMinute)
                
                DatePicker("结束时间", selection: $endTime, displayedComponents: .hourAndMinute)
                    .onChange(of: endTime) { _ in
                        calculateDuration()
                    }
                
                Text("阅读时长: \(duration , specifier: "%.2f") 分钟")
                    .foregroundColor(.gray)
            }
            .navigationBarTitle("新增阅读记录", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveLog()
                }
            )
        }
    }
    
    private func calculateDuration() {
        // 计算时间间隔（秒）
        duration = endTime.timeIntervalSince(startTime)
        if duration < 0 {
            duration += 24 * 60 * 60 // 如果结束时间早于开始时间，表示跨越了一天
        }
        // 将秒转换为分钟
        duration = duration / 60
    }
    
    private func saveLog() {
        // 创建新的阅读记录
        let newLog = ReadingLog(
            date: date,
            duration: duration  // duration 已经在 calculateDuration 中转换为分钟
        )
        
        // 更新本地的 book 数据
        var updatedBook = book
        updatedBook.readingLogs.append(newLog)
        
        // 更新 folders 中的 book 数据
        if let folderIndex = bookManager.folders.firstIndex(where: { $0.id == folder.id }) {
            if let bookIndex = bookManager.folders[folderIndex].books.firstIndex(where: { $0.id == book.id }) {
                bookManager.folders[folderIndex].books[bookIndex] = updatedBook
                bookManager.saveFolders()
            }
        }
        
        // 更新 book 的绑定
        book = updatedBook
        
        // 退出视图，仅返回到上一级
        presentationMode.wrappedValue.dismiss()
    }
}
