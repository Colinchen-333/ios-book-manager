import SwiftUI

struct BookPickerView: View {
    @ObservedObject var bookManager: BookManager
    @Binding var selectedBook: Book?
    @Binding var isCountdown: Bool
    @Binding var countdownTime: TimeInterval
    var startReading: (TimeInterval) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedTime: Int = 60 // 默认60分钟
    let timeOptions = [15, 30, 45, 60, 90, 120]
    
    var body: some View {
        NavigationView {
            ZStack {
                // 使用直接的颜色渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.6, blue: 0.8),  // 顶部颜色
                        Color(red: 0.6, green: 0.75, blue: 0.9)  // 底部颜色
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Form {
                        Section(header: Text("选择书籍").foregroundColor(.white)) {
                            ForEach(bookManager.getAllBooks()) { book in
                                Button(action: {
                                    selectedBook = book
                                }) {
                                    HStack {
                                        if let coverImage = book.coverImage {
                                            Image(uiImage: coverImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 60)
                                                .cornerRadius(8)
                                        } else {
                                            Rectangle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 40, height: 60)
                                                .cornerRadius(8)
                                                .overlay(
                                                    Image(systemName: "book.closed")
                                                        .foregroundColor(.white.opacity(0.5))
                                                )
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(book.title)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(book.author)
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedBook?.id == book.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("阅读模式").foregroundColor(.white)) {
                            Toggle("定时阅读", isOn: $isCountdown)
                                .foregroundColor(.white)
                            
                            if isCountdown {
                                Picker("阅读时长", selection: $selectedTime) {
                                    ForEach(timeOptions, id: \.self) { minutes in
                                        Text("\(minutes) 分钟").tag(minutes)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    
                    // 开始阅读按钮
                    Button(action: {
                        if let _ = selectedBook {
                            countdownTime = Double(selectedTime * 60) // 转换为秒
                            startReading(countdownTime)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("开始阅读")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedBook == nil ? Color.gray : Color(red: 0.4, green: 0.6, blue: 0.8))
                            .cornerRadius(10)
                    }
                    .disabled(selectedBook == nil)
                    .padding()
                }
            }
            .navigationBarTitle("选择书籍", displayMode: .inline)
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.white))
        }
    }
}
