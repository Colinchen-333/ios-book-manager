import SwiftUI

struct BookDetailView: View {
    @Binding var book: Book
    var folder: Folder
    @ObservedObject var bookManager: BookManager
    
    @State private var isEditing = false
    @State private var editedBook: Book
    @State private var selectedCategory: String = ""
    @State private var isShowingReadingLog = false
    @State private var isShowingAddReadingLog = false
    @State private var isShowingReadingMode = false
    @State private var selectedBook: Book?
    @State private var selectedFolder: Folder?
    @State private var showDeleteConfirmation = false
    @State private var logToDelete: ReadingLog? = nil
    @State private var isSaving = false
    @Environment(\.presentationMode) var presentationMode
    
    let categories = ["小说", "非小说", "科幻", "历史", "传记", "自助", "教育", "艺术", "哲学", "宗教", "科技", "旅行", "烹饪", "健康", "儿童"]
    
    init(book: Binding<Book>, folder: Folder, bookManager: BookManager) {
        self._book = book
        self.folder = folder
        self.bookManager = bookManager
        self._editedBook = State(initialValue: book.wrappedValue)
    }
    
    var body: some View {
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
                // 书籍封面
                if let coverImage = editedBook.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                // 书籍详细信息
                Form {
                    Section(header: Text("书籍信息").foregroundColor(.white)) {
                        TextField("书名", text: $editedBook.title)
                            .foregroundColor(.white)
                            .disabled(!isEditing)
                        TextField("作者", text: $editedBook.author)
                            .foregroundColor(.white)
                            .disabled(!isEditing)
                        TextField("出版社", text: $editedBook.publisher)
                            .foregroundColor(.white)
                            .disabled(!isEditing)
                        DatePicker("添加日期", selection: $editedBook.dateAdded, displayedComponents: .date)
                            .foregroundColor(.white)
                            .disabled(!isEditing)
                        TextField("备注", text: Binding(
                            get: { editedBook.notes ?? "" },
                            set: { editedBook.notes = $0 }
                        ))
                        .foregroundColor(.white)
                        .disabled(!isEditing)
                    }
                    
                    // 书籍类别
                    Section(header: Text("书籍类别").foregroundColor(.white)) {
                        if isEditing {
                            Picker("类别", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: selectedCategory) { newCategory in
                                editedBook.category = newCategory
                            }
                        } else {
                            Text(editedBook.category ?? "未分类")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.vertical, 4)
                        }
                    }
                    
                    // 阅读进度
                    Section(header: Text("阅读进度").foregroundColor(.white)) {
                        Slider(value: $editedBook.progress, in: 0...100, step: 1)
                            .accentColor(Color(red: 0.4, green: 0.6, blue: 0.8))
                            .disabled(!isEditing)
                        HStack {
                            Text("进度: \(Int(editedBook.progress))%")
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    
                    // 阅读记录
                    Section(header: HStack {
                        Text("阅读记录")
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            isShowingAddReadingLog = true
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(Color(red: 0.4, green: 0.6, blue: 0.8))
                        }
                    }) {
                        if editedBook.readingLogs.isEmpty {
                            Text("暂无阅读记录")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(editedBook.readingLogs) { log in
                                HStack {
                                    Text("阅读时间: \(log.date, formatter: DateFormatter.shortDate)")
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("时长: \(log.duration / 60, specifier: "%.2f") 分钟")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .contextMenu {
                                    Button(action: {
                                        logToDelete = log
                                        showDeleteConfirmation = true
                                    }) {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    // 设置表单背景为透明
                    UITableView.appearance().backgroundColor = .clear
                }
                .onDisappear {
                    // 恢复默认背景
                    UITableView.appearance().backgroundColor = .systemGroupedBackground
                }
                
                // 编辑或保存按钮
                HStack {
                    Button(action: {
                        withAnimation {
                            if isEditing {
                                isSaving = true
                                saveChanges {
                                    isEditing = false
                                    isSaving = false
                                    book = editedBook // 同步更新外部绑定的书籍对象
                                    withAnimation(.easeInOut) {
                                        presentationMode.wrappedValue.dismiss() // 添加过渡动画
                                    }
                                }
                            } else {
                                selectedCategory = editedBook.category ?? ""
                                isEditing.toggle()
                            }
                        }
                    }) {
                        if isSaving {
                            ProgressView() // 保存时显示进度指示器
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        } else {
                            Text(isEditing ? "保存" : "编辑")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isEditing ? Color.green : Color(red: 0.4, green: 0.6, blue: 0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    // 阅读模式按钮
                    Button(action: {
                        selectedBook = editedBook
                        isShowingReadingMode = true
                    }) {
                        Text("开始阅读")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(editedBook.title, displayMode: .inline)
        .onAppear {
            selectedCategory = editedBook.category ?? ""
        }
        .sheet(isPresented: $isShowingAddReadingLog) {
            AddReadingLogView(
                book: $editedBook,
                folder: folder,
                bookManager: bookManager
            )
            .onDisappear {
                if bookManager.folders.contains(where: { $0.id == folder.id }) {
                    saveChanges()
                }
            }
        }
        .sheet(isPresented: $isShowingReadingMode) {
            ReadingModeView(
                bookManager: bookManager,
                selectedBook: $selectedBook,
                onSave: { book, log in
                    if var updatedBook = selectedBook {
                        updatedBook.readingLogs.append(log)
                        selectedBook = updatedBook
                        editedBook = updatedBook
                        saveChanges()
                    }
                }
            )
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("删除阅读记录"),
                message: Text("你确定要删除这条阅读记录吗？"),
                primaryButton: .destructive(Text("删除")) {
                    if let log = logToDelete {
                        if let index = editedBook.readingLogs.firstIndex(where: { $0.id == log.id }) {
                            withAnimation {
                                editedBook.readingLogs.remove(at: index)
                                saveChanges {
                                    // 添加一个平滑的动画，返回到FolderView
                                    withAnimation(.easeInOut) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // 保存更改的函数
    private func saveChanges(completion: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            if let lastLog = editedBook.readingLogs.last {
                editedBook.lastReadDate = lastLog.date
                book.lastReadDate = lastLog.date
            }

            if let folderIndex = bookManager.folders.firstIndex(where: { $0.id == folder.id }),
               let bookIndex = bookManager.folders[folderIndex].books.firstIndex(where: { $0.id == book.id }) {
                bookManager.folders[folderIndex].books[bookIndex] = editedBook
                bookManager.saveFolders()
            }

            completion()
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
