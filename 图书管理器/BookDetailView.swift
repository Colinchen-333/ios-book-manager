import SwiftUI

struct BookDetailView: View {
    @Binding var book: Book
    var folder: Folder
    @ObservedObject var bookManager: BookManager
    
    @State private var isEditing = false
    @State private var editedBook: Book
    @State private var selectedCategory: String = ""
    @State private var isShowingReadingLog = false
    @State private var isShowingReadingMode = false
    @State private var selectedBook: Book?
    @State private var selectedFolder: Folder?
    @State private var showDeleteConfirmation = false
    @State private var logToDelete: ReadingLog? = nil
    @State private var isSaving = false
    @State private var isPresentingView = false
    @Environment(\.presentationMode) var presentationMode
    
    let categories = ["小说", "非小说", "科幻", "历史", "传记", "自助", "教育", "艺术", "哲学", "宗教", "科技", "旅行", "烹饪", "健康", "儿童"]
    
    init(book: Binding<Book>, folder: Folder, bookManager: BookManager) {
        self._book = book
        self.folder = folder
        self.bookManager = bookManager
        self._editedBook = State(initialValue: book.wrappedValue)
    }
    
    var body: some View {
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
                ZStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    Text("暂无封面")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
            
            // 书籍详细信息
            Form {
                Section(header: Text("书籍信息")) {
                    TextField("书名", text: $editedBook.title)
                        .disabled(!isEditing)
                    TextField("作者", text: $editedBook.author)
                        .disabled(!isEditing)
                    TextField("出版社", text: $editedBook.publisher)
                        .disabled(!isEditing)
                    DatePicker("添加日期", selection: $editedBook.dateAdded, displayedComponents: .date)
                        .disabled(!isEditing)
                    TextField("备注", text: Binding(
                        get: { editedBook.notes ?? "" },
                        set: { editedBook.notes = $0 }
                    ))
                    .disabled(!isEditing)
                }
                
                // 书籍类别
                Section(header: Text("书籍类别")) {
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
                            .foregroundColor(.primary)
                            .padding(.vertical, 4)
                    }
                }
                
                // 阅读进度
                Section(header: Text("阅读进度")) {
                    Slider(value: $editedBook.progress, in: 0...100, step: 1)
                        .disabled(!isEditing)
                    HStack {
                        Text("进度: \(Int(editedBook.progress))%")
                        Spacer()
                    }
                }
                
                // 阅读记录
                Section(header: Text("阅读记录")) {
                    if editedBook.readingLogs.isEmpty {
                        Text("暂无阅读记录")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(editedBook.readingLogs) { log in
                            HStack {
                                Text("阅读时间: \(log.date, formatter: DateFormatter.shortDate)")
                                Spacer()
                                Text("时长: \(log.duration / 60, specifier: "%.2f") 分钟")
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    logToDelete = log
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
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
            
            // 编辑或保存按钮
            HStack {
                Button(action: {
                    withAnimation {
                        if isEditing {
                            isSaving = true
                            saveChanges {
                                isEditing = false
                                isSaving = false
                                book = editedBook
                                withAnimation(.easeInOut) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        } else {
                            selectedCategory = editedBook.category ?? ""
                            isEditing.toggle()
                        }
                    }
                }) {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text(isEditing ? "保存" : "编辑")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isEditing ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                // 阅读模式按钮
                Button(action: {
                    if !isPresentingView {
                        isPresentingView = true
                        selectedBook = editedBook
                        selectedFolder = folder
                        isShowingReadingMode = true
                    }
                }) {
                    Text("阅读模式")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $isShowingReadingMode, onDismiss: {
                    isPresentingView = false
                }) {
                    ReadingModeView(
                        bookManager: bookManager,
                        selectedBook: Binding<Book?>(
                            get: { editedBook },
                            set: { _ in }
                        ),
                        selectedFolder: .constant(folder),
                        onEndReading: { book, log in
                            saveReadingLog(log)
                        },
                        onSave: { book, log in
                            saveReadingLog(log)
                        }
                    )
                }
            }
            .padding()
        }
        .navigationBarTitle(editedBook.title, displayMode: .inline)
        .onAppear {
            selectedCategory = editedBook.category ?? ""
        }
    }
    
    private func saveReadingLog(_ log: ReadingLog) {
        if !editedBook.readingLogs.contains(where: { $0.id == log.id }) {
            editedBook.readingLogs.append(log)
            saveChanges()
        }
    }
    
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
