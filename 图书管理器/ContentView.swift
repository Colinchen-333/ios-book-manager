import SwiftUI

struct ContentView: View {
    @StateObject private var bookManager = BookManager()
    @StateObject private var trash = Trash()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @State private var isShowingAddBookView = false
    @State private var isShowingSettingsView = false
    @State private var isShowingNewFolderSheet = false
    @State private var isShowingAddReadingLogView = false
    @State private var newFolderName: String = ""
    @State private var isEditingFolders = false
    @State private var searchText = ""
    @State private var folderToRename: Folder?
    @State private var isShowingRenameSheet = false
    @State private var isSearchActive = false
    @State private var selectedTab: Tab = .library
    @State private var selectedBook: Book? // 用于在阅读模式下选择书籍
    @State private var selectedFolder: Folder?
    @State private var isDetailViewActive = false // 控制详情页的显示状态
    @State private var isShowingNewReadingLogView = false // 控制新建阅读记录的显示
    @State private var groupedReadingLogs: [Book: [Date: [ReadingLog]]] = [:] // 保存按日期分组的阅读记录
    @State private var showDeleteConfirmation = false
    @State private var bookToDelete: Book? = nil
    
    enum Tab {
        case library
        case readingMode
        case settings
    }
    
    var body: some View {
        if hasCompletedOnboarding {
            mainContentView
                .onReceive(NotificationCenter.default.publisher(for: .init("RefreshContentView"))) { _ in
                    bookManager.loadFolders()
                }
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
    
    private var mainContentView: some View {
        TabView(selection: $selectedTab) {
            // 资源库标签页
            NavigationView {
                ZStack {
                    // 统一使用的渐变背景
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.4, green: 0.6, blue: 0.8),  // 深蓝灰色
                            Color(red: 0.7, green: 0.7, blue: 0.8)   // 浅蓝灰色
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack {
                        if selectedTab == .library {
                            searchView
                            libraryView
                        }
                    }
                }
                .navigationBarTitle("资源库")
                .navigationBarItems(
                    leading: NavigationLink(destination: TrashView(trash: trash, bookManager: bookManager)) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    },
                    trailing: Button(action: {
                        isShowingAddBookView = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                )
            }
            .tabItem {
                Image(systemName: "books.vertical.fill")
                Text("我的")
            }
            .tag(Tab.library)
            
            // 阅读模式标签页
            NavigationView {
                ZStack {
                    // 使用相同的渐变背景
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.4, green: 0.6, blue: 0.8),
                            Color(red: 0.7, green: 0.7, blue: 0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack {
                        readingModeMainView
                    }
                }
                .navigationBarTitle("阅读模式")
                .onAppear(perform: loadReadingLogs)
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("阅读模式")
            }
            .tag(Tab.readingMode)
            
            // 设置标签页
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                Text("设置")
            }
            .tag(Tab.settings)
        }
        .sheet(isPresented: $isShowingAddBookView) {
            AddBookView(bookManager: bookManager)
        }
        .sheet(isPresented: $isShowingNewFolderSheet) {
            createFolderSheet
        }
        .sheet(isPresented: $isShowingRenameSheet) {
            renameFolderSheet
        }
        .sheet(isPresented: $isShowingAddReadingLogView) {
            addReadingLogSheet
        }
        .sheet(isPresented: $isShowingNewReadingLogView) {
            ReadingModeView(bookManager: bookManager, selectedBook: $selectedBook, selectedFolder: $selectedFolder) { book, log in
                saveReadingLog(book: book, log: log)
                loadReadingLogs() // 更新阅读记录以反映最新的变化
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("删除书籍"),
                message: Text("你确定要删除这本书吗？"),
                primaryButton: .destructive(Text("删除")) {
                    if let book = bookToDelete, let folder = selectedFolder {
                        deleteBook(book, from: folder)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            // 设置导航栏样式
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            // 设置 TabBar 样式为透明
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithTransparentBackground()
            tabBarAppearance.backgroundColor = .clear
            
            // 修改 TabBar 图标和文字颜色
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white.withAlphaComponent(0.6)
            ]
            let selectedAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white
            ]
            
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.6)
            tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .white
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
    
    struct TrashView: View {
        @ObservedObject var trash: Trash
        @ObservedObject var bookManager: BookManager
        @State private var showingDeleteAlert = false
        @State private var selectedDeletedItem: (book: Book, folderID: UUID)?
        
        var body: some View {
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
                
                // 原有内容
                Group {
                    if trash.deletedBooks.isEmpty && trash.deletedFolders.isEmpty {
                        emptyTrashView
                    } else {
                        trashContentView
                    }
                }
            }
            .navigationBarTitle("回收站", displayMode: .inline)
            .navigationBarItems(
                trailing: (!trash.deletedBooks.isEmpty || !trash.deletedFolders.isEmpty) ? Button(action: {
                    showingDeleteAlert = true
                }) {
                    Text("清空")
                        .foregroundColor(.red)
                } : nil
            )
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("清空回收站"),
                    message: Text("确定要永久删除所有项目吗？此操作不可撤销。"),
                    primaryButton: .destructive(Text("清空")) {
                        trash.deletedBooks.removeAll()
                        trash.deletedFolders.removeAll()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        
        // 空回收站视图
        private var emptyTrashView: some View {
            VStack(spacing: 20) {
                Image(systemName: "trash")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                Text("回收站是空的")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        
        // 回收站内容视图
        private var trashContentView: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // 已删除的文件夹
                    if !trash.deletedFolders.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("已删除的文件夹")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(trash.deletedFolders, id: \.id) { folder in
                                    DeletedFolderCard(folder: folder) {
                                        restoreFolder(folder)
                                    }
                                }
                                }
                        }
                    }
                    
                    // 已删除的书籍
                    if !trash.deletedBooks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("已删除的书籍")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(trash.deletedBooks, id: \.book.id) { deletedBook in
                                    DeletedBookCard(book: deletedBook.book) {
                                        restoreBook(deletedBook.book, to: deletedBook.folderID)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        
        // 已删除的文件夹卡片
        private struct DeletedFolderCard: View {
            let folder: Folder
            let onRestore: () -> Void
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "folder.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    
                    Text(folder.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(folder.books.count) 本书")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: onRestore) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("恢复")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        
        // 已删除的书籍卡片
        private struct DeletedBookCard: View {
            let book: Book
            let onRestore: () -> Void
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    if let coverImage = book.coverImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: coverImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 160)
                                .cornerRadius(8)
                            
                            // 右上角显示类别标签
                            Text(book.category ?? "未分类")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                                .padding(8)
                        }
                        
                        // 阅读进度放在封面下方
                        if book.progress > 0 {
                            HStack {
                                ProgressView(value: book.progress / 100)
                                    .progressViewStyle(LinearProgressViewStyle())
                                Text("\(Int(book.progress))%")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 4)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 160)
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(.headline)
                            .lineLimit(2)
                        
                        HStack {
                            Text(book.author)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Spacer()
                        }
                        
                        if !book.publisher.isEmpty {
                            Text(book.publisher)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                        Button(action: onRestore) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("恢复")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 8)
                }
                .padding(8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        
        // 恢复文件夹
        private func restoreFolder(_ folder: Folder) {
            trash.deletedFolders.removeAll(where: { $0.id == folder.id })
            bookManager.folders.append(folder)
            bookManager.saveFolders()
        }
        
        // 恢复书籍
        private func restoreBook(_ book: Book, to folderID: UUID) {
            if let folderIndex = bookManager.folders.firstIndex(where: { $0.id == folderID }) {
                trash.deletedBooks.removeAll(where: { $0.book.id == book.id })
                bookManager.folders[folderIndex].books.append(book)
                bookManager.saveFolders()
            }
        }
    }
    
    // 搜索视图
    private var searchView: some View {
        ZStack(alignment: .topTrailing) {
            if (!isSearchActive) {
                Button(action: {
                    withAnimation {
                        isSearchActive = true
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding()
            } else {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.8))
                    TextField("搜索书名或作者", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                        .accentColor(.white)
                    Button(action: {
                        withAnimation {
                            isSearchActive = false
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding()
            }
        }
    }
    
    // 资源库视图
    private var libraryView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if searchText.isEmpty && !filteredFolders.filter({ $0.isPinned }).isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("置顶文件夹")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(filteredFolders.filter { $0.isPinned }, id: \.id) { folder in
                                NavigationLink(destination: FolderView(folder: folder, bookManager: bookManager, trash: trash)) {
                                    FolderCardView(
                                        folder: folder,
                                        isEditing: isEditingFolders,
                                        editAction: {
                                            folderToRename = folder
                                            newFolderName = folder.name
                                            isShowingRenameSheet = true
                                        },
                                        deleteAction: {
                                            confirmDeleteFolder(folder)
                                        },
                                        bookManager: bookManager
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.vertical)
                    }
                }
                
                // 非置顶文件夹部分
                VStack(alignment: .leading, spacing: 0) {
                    Text("所有文件夹")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredFolders.filter { !$0.isPinned }, id: \.id) { folder in
                            NavigationLink(destination: FolderView(folder: folder, bookManager: bookManager, trash: trash)) {
                                FolderCardView(
                                    folder: folder,
                                    isEditing: isEditingFolders,
                                    editAction: {
                                        folderToRename = folder
                                        newFolderName = folder.name
                                        isShowingRenameSheet = true
                                    },
                                    deleteAction: {
                                        confirmDeleteFolder(folder)
                                    },
                                    bookManager: bookManager
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // 置顶文件夹区域
    private var pinnedFoldersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("置顶文件夹")
                .font(.headline)
                .padding(.leading, 4)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredFolders.filter { $0.isPinned }, id: \.id) { folder in
                    NavigationLink(destination: FolderView(folder: folder, bookManager: bookManager, trash: trash)) {
                        FolderCardView(
                            folder: folder,
                            isEditing: isEditingFolders,
                            editAction: {
                                folderToRename = folder
                                newFolderName = folder.name
                                isShowingRenameSheet = true
                            },
                            deleteAction: {
                                confirmDeleteFolder(folder)
                            },
                            bookManager: bookManager
                        )
                    }
                }
                .onMove(perform: movePinnedFolder)
            }
        }
    }
    
    // 更新文件夹卡片视图
    private struct FolderCardView: View {
        let folder: Folder
        let isEditing: Bool
        let editAction: () -> Void
        let deleteAction: () -> Void
        @ObservedObject var bookManager: BookManager
        var isPinned: Bool = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                    
                    if folder.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundColor(Color(red: 1, green: 0.85, blue: 0.4))
                    }
                    
                    Spacer()
                    
                    Text("\(folder.books.count) 本书")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Text(folder.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .contextMenu {
                Button(action: editAction) {
                    Label("重命名", systemImage: "pencil")
                }
                Button(action: {
                    togglePin(folder)
                }) {
                    Label(folder.isPinned ? "取消置顶" : "置顶", 
                          systemImage: folder.isPinned ? "pin.slash" : "pin")
                }
                Button(action: deleteAction) {
                    Label("删除", systemImage: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        
        private func togglePin(_ folder: Folder) {
            if let index = bookManager.folders.firstIndex(where: { $0.id == folder.id }) {
                bookManager.folders[index].isPinned.toggle()
                bookManager.saveFolders()
            }
        }
    }
    
    // 书籍卡片视图
    private struct BookCardView: View {
        let book: Book
        let tapAction: () -> Void
        let deleteAction: () -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                if let coverImage = book.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(8)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .cornerRadius(8)
                }
                
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .onTapGesture(perform: tapAction)
            .contextMenu {
                Button(action: deleteAction) {
                    Label("删除", systemImage: "trash")
                }
            }
        }
    }
    
    // 保存阅读记录到本地
    private func saveReadingLog(book: Book, log: ReadingLog) {
        if let folderIndex = bookManager.folders.firstIndex(where: { $0.id == selectedFolder?.id }),
           let bookIndex = bookManager.folders[folderIndex].books.firstIndex(where: { $0.id == book.id }) {
            bookManager.folders[folderIndex].books[bookIndex].readingLogs.append(log)
            bookManager.saveFolders() // 保存更新后的数据
            updateBookSummary(for: book)
            
            // 更新 selectedBook，确保在 ReadingModeView 中使用最新的 book 数据
            selectedBook = bookManager.folders[folderIndex].books[bookIndex]
        }
    }
    
    // 更新书籍的最近阅读时间和总阅读时间
    private func updateBookSummary(for originalBook: Book) {
        guard let folderIndex = bookManager.folders.firstIndex(where: { $0.id == originalBook.folderID }),
              let bookIndex = bookManager.folders[folderIndex].books.firstIndex(where: { $0.id == originalBook.id }) else { return }
        
        // 找到最近的阅读时间
        let latestLog = bookManager.folders[folderIndex].books[bookIndex].readingLogs.max(by: { $0.date < $1.date })
        bookManager.folders[folderIndex].books[bookIndex].lastReadDate = latestLog?.date
        
        // 计算累积阅读时间
        let totalDuration = bookManager.folders[folderIndex].books[bookIndex].readingLogs.reduce(0) { $0 + $1.duration }
        bookManager.folders[folderIndex].books[bookIndex].totalReadingDuration = totalDuration
        
        bookManager.saveFolders() // 保存更改
    }
    
    // 从本地加载阅读记录
    private func loadReadingLogs() {
        groupedReadingLogs = [:]
        
        // 遍历所有文件夹和书籍
        for folder in bookManager.folders {
            for book in folder.books {
                // 确保书籍有阅读记录
                if !book.readingLogs.isEmpty {
                    var bookLogs: [Date: [ReadingLog]] = [:]
                    
                    // 按日期分组阅读记录
                    for log in book.readingLogs {
                        let date = Calendar.current.startOfDay(for: log.date)
                        if bookLogs[date] == nil {
                            bookLogs[date] = []
                        }
                        bookLogs[date]?.append(log)
                    }
                    
                    // 确保日期是按时间排序的
                    let sortedDates = bookLogs.keys.sorted(by: >)
                    var sortedLogs: [Date: [ReadingLog]] = [:]
                    for date in sortedDates {
                        sortedLogs[date] = bookLogs[date]?.sorted(by: { $0.date > $1.date })
                    }
                    
                    groupedReadingLogs[book] = sortedLogs
                }
            }
        }
        
        // 打印调试信息
        print("📚 加载阅读记录:")
        for (book, logs) in groupedReadingLogs {
            print("书籍: \(book.title)")
            for (date, dayLogs) in logs {
                print("  日期: \(date)")
                for log in dayLogs {
                    print("    时间: \(log.date), 时长: \(log.duration/60)分钟")
                }
            }
        }
    }
    
    // 删除阅读记录
    private func deleteReadingLog(book: Book, log: ReadingLog) {
        if let folderIndex = bookManager.folders.firstIndex(where: { $0.id == book.folderID }),
           let bookIndex = bookManager.folders[folderIndex].books.firstIndex(where: { $0.id == book.id }),
           let logIndex = bookManager.folders[folderIndex].books[bookIndex].readingLogs.firstIndex(where: { $0.id == log.id }) {
            
            // 删除日志
            bookManager.folders[folderIndex].books[bookIndex].readingLogs.remove(at: logIndex)
            
            // 更新总阅读时间
            bookManager.folders[folderIndex].books[bookIndex].totalReadingDuration -= log.duration
            
            // 更新最近阅读时间
            let latestLog = bookManager.folders[folderIndex].books[bookIndex].readingLogs.max(by: { $0.date < $1.date })
            bookManager.folders[folderIndex].books[bookIndex].lastReadDate = latestLog?.date
            
            bookManager.saveFolders() // 保存更新后的数据
            loadReadingLogs() // 重新加载阅读记录
        }
    }
    
    // 阅读模式主界面视图
    private var readingModeMainView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if groupedReadingLogs.isEmpty {
                    Text("暂无阅读记录")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(Array(groupedReadingLogs.keys), id: \.id) { book in
                        // 使用可选绑定来获取 `book` 的最新阅读时间和累积时间
                        let lastDate = groupedReadingLogs[book]?.keys.sorted().last
                        let totalDuration = groupedReadingLogs[book]?.values.flatMap { $0 }.reduce(0) { $0 + $1.duration } ?? 0
                        
                        NavigationLink(destination: BookReadingLogsView(book: book, groupedLogs: groupedReadingLogs[book]!, deleteLog: deleteReadingLog)) {
                            BookLogSummaryView(book: book, lastDate: lastDate, totalDuration: totalDuration)
                                .padding(.bottom)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // 阅读记录概览视图
    private struct BookLogSummaryView: View {
        var book: Book
        var lastDate: Date?
        var totalDuration: TimeInterval
        
        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter
        }()
        
        var body: some View {
            HStack {
                if let coverImage = book.coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 100)
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let lastDate = lastDate {
                        Text("最近阅读: \(dateFormatter.string(from: lastDate))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("累积阅读时间: \(formatDuration(totalDuration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.3))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        
        // 格式化持续时间
        private func formatDuration(_ duration: TimeInterval) -> String {
            let minutes = Int(duration / 60)
            if minutes >= 60 {
                let hours = minutes / 60
                let remainingMinutes = minutes % 60
                if remainingMinutes == 0 {
                    return "\(hours)小时"
                }
                return "\(hours)小时\(remainingMinutes)分钟"
            }
            return "\(minutes)分钟"
        }
    }
    
    // 显示某本书的阅读记录页面
    private struct BookReadingLogsView: View {
        var book: Book
        var groupedLogs: [Date: [ReadingLog]]
        var deleteLog: (Book, ReadingLog) -> Void
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(groupedLogs.keys.sorted(), id: \.self) { date in
                        Section(header: Text("\(date, formatter: logDateFormatter)").font(.headline)) {
                            ForEach(groupedLogs[date]!, id: \.id) { log in
                                HStack {
                                    if let coverImage = book.coverImage {
                                        Image(uiImage: coverImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 70)
                                            .cornerRadius(5)
                                    }
                                    VStack(alignment: .leading) {
                                        Text("阅读时间: \(log.duration/60 , specifier: "%.0f") 分钟")
                                            .font(.subheadline)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .padding(.bottom)
                                .contextMenu {
                                    Button(action: {
                                        deleteLog(book, log)
                                    }) {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle(book.title, displayMode: .inline)
        }
        
        private var logDateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }
    }
    
    // 筛选后的文件夹列表
    var filteredFolders: [Folder] {
        if searchText.isEmpty {
            return bookManager.folders
        } else {
            return []
        }
    }
    
    // 筛选后的书籍列表
    var filteredBooks: [Book] {
        return bookManager.searchBooks(with: searchText)
    }
    
    // 移动文件夹位置
    private func moveFolder(from source: IndexSet, to destination: Int) {
        var nonPinnedFolders = bookManager.folders.filter { !$0.isPinned }
        nonPinnedFolders.move(fromOffsets: source, toOffset: destination)
        
        // 更新主文件夹数组
        let pinnedFolders = bookManager.folders.filter { $0.isPinned }
        bookManager.folders = pinnedFolders + nonPinnedFolders
        bookManager.saveFolders()
    }
    
    private func movePinnedFolder(from source: IndexSet, to destination: Int) {
        var pinnedFolders = bookManager.folders.filter { $0.isPinned }
        pinnedFolders.move(fromOffsets: source, toOffset: destination)
        
        // 更新主文件夹数组
        let nonPinnedFolders = bookManager.folders.filter { !$0.isPinned }
        bookManager.folders = pinnedFolders + nonPinnedFolders
        bookManager.saveFolders()
    }
    
    // 删除文件夹
    private func deleteFolder(at offsets: IndexSet) {
        for index in offsets {
            let folder = bookManager.folders[index]
            trash.deletedFolders.append(folder) // 将文件夹添加到垃圾桶
        }
        bookManager.folders.remove(atOffsets: offsets)
        bookManager.saveFolders()
    }
    
    // 删除单个文件夹并显示确认提示框
    private func confirmDeleteFolder(_ folder: Folder) {
        let alert = UIAlertController(title: "删除文件夹", message: "确定要删除此文件夹吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { _ in
            if let index = bookManager.folders.firstIndex(where: { $0.id == folder.id }) {
                deleteFolder(at: IndexSet(integer: index))
            }
        }))
        
        // 使用新的 API 获取窗口
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    // 删除书籍
    private func deleteBook(_ book: Book, from folder: Folder) {
        if let folderIndex = bookManager.folders.firstIndex(where: { $0.id == folder.id }) {
            if let bookIndex = bookManager.folders[folderIndex].books.firstIndex(where: { $0.id == book.id }) {
                trash.deletedBooks.append((book, folder.id)) // 将书本添加到垃圾桶
                bookManager.folders[folderIndex].books.remove(at: bookIndex)
                bookManager.saveFolders()
            }
        }
    }
    
    // 新建文件夹
    private func createNewFolder() {
        guard !newFolderName.isEmpty else { return }
        let newFolder = Folder(name: newFolderName, books: [])
        bookManager.folders.append(newFolder)
        bookManager.saveFolders()
    }
    
    // 重命名文件夹
    private func renameFolder() {
        guard let folder = folderToRename else { return }
        if let index = bookManager.folders.firstIndex(where: { $0.id == folder.id }) {
            bookManager.folders[index].name = newFolderName
            bookManager.saveFolders()
        }
    }
    
    // 新建阅读记录表单
    private var addReadingLogSheet: some View {
        if let book = selectedBook, let folder = selectedFolder {
            AnyView(
                AddReadingLogView(book: .constant(book), folder: .constant(folder), bookManager: bookManager)
            )
        } else {
            AnyView(
                Text("请先选择一本书")
                    .font(.headline)
                    .padding()
            )
        }
    }
    
    // 创建文件夹表单
    private var createFolderSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 文件夹图标
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                
                // 输入框
                VStack(alignment: .leading, spacing: 8) {
                    Text("文件夹名称")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("输入文件夹名称", text: $newFolderName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 18))
                        .padding(12)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitle("新建文件夹", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    isShowingNewFolderSheet = false
                },
                trailing: Button("创建") {
                    createNewFolder()
                    isShowingNewFolderSheet = false
                }
                .disabled(newFolderName.isEmpty)
            )
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
    }
    
    // 重命名文件夹表单
    private var renameFolderSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 文件夹图标
                Image(systemName: "folder.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                
                // 输入框
                VStack(alignment: .leading, spacing: 8) {
                    Text("文件夹名称")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("输入新名称", text: $newFolderName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 18))
                        .padding(12)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitle("重命名文件夹", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    isShowingRenameSheet = false
                },
                trailing: Button("完成") {
                    renameFolder()
                    isShowingRenameSheet = false
                }
                .disabled(newFolderName.isEmpty)
            )
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
    }
}
