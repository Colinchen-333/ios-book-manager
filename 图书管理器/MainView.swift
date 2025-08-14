import SwiftUI

struct MainView: View {
    @StateObject private var bookManager = BookManager()
    @State private var isShowingAddFolderSheet = false
    @State private var folderName = ""
    @State private var searchText = ""
    @State private var selectedTab: Int = 0
    @State private var showWelcomeScreen = false
    
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
                    // 顶部区域: 搜索栏
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    // 中间区域: 文件夹网格
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            // 创建文件夹按钮
                            Button(action: {
                                isShowingAddFolderSheet = true
                            }) {
                                FolderCreateButton()
                            }
                            .sheet(isPresented: $isShowingAddFolderSheet) {
                                AddFolderView(isPresented: $isShowingAddFolderSheet, bookManager: bookManager)
                            }
                            
                            // 文件夹列表
                            ForEach(filteredFolders) { folder in
                                NavigationLink(destination: FolderView(folder: folder, bookManager: bookManager)) {
                                    FolderGridItem(folder: folder)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("七印图书管理器", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showWelcomeScreen = true
            }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .medium))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            })
            .sheet(isPresented: $showWelcomeScreen) {
                WelcomeView(isPresented: $showWelcomeScreen)
            }
            .onAppear {
                // 应用启动时，显示欢迎屏幕
                if bookManager.isFirstLaunch {
                    showWelcomeScreen = true
                    bookManager.isFirstLaunch = false
                }
            }
        }
    }
    
    // 过滤文件夹
    var filteredFolders: [Folder] {
        if searchText.isEmpty {
            return bookManager.folders
        } else {
            return bookManager.folders.filter { folder in
                // 检查文件夹名称
                if folder.name.lowercased().contains(searchText.lowercased()) {
                    return true
                }
                
                // 检查书名或作者
                for book in folder.books {
                    if book.title.lowercased().contains(searchText.lowercased()) ||
                        book.author.lowercased().contains(searchText.lowercased()) {
                        return true
                    }
                }
                
                return false
            }
        }
    }
}

// 搜索栏组件
struct SearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("搜索书籍、作者或文件夹", text: $text)
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
                .foregroundColor(.white)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing && !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.white)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    isEditing = true
                }
            
            if isEditing {
                Button(action: {
                    isEditing = false
                    text = ""
                    // 隐藏键盘
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("取消")
                        .foregroundColor(.white)
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}

// 文件夹网格项
struct FolderGridItem: View {
    let folder: Folder
    
    var body: some View {
        VStack {
            ZStack {
                // 文件夹背景
                Rectangle()
                    .fill(Color.white.opacity(0.15))
                    .cornerRadius(15)
                    .aspectRatio(1, contentMode: .fit)
                
                VStack {
                    // 文件夹图标
                    Image(systemName: "folder.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    // 文件夹名称
                    Text(folder.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // 书籍数量
                    Text("\(folder.books.count) 本书")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            }
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 创建文件夹按钮
struct FolderCreateButton: View {
    var body: some View {
        ZStack {
            // 背景
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .cornerRadius(15)
                .aspectRatio(1, contentMode: .fit)
            
            VStack {
                // 加号图标
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                // 文字提示
                Text("创建文件夹")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 添加文件夹视图
struct AddFolderView: View {
    @Binding var isPresented: Bool
    @ObservedObject var bookManager: BookManager
    @State private var folderName = ""
    
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
                
                Form {
                    Section(header: Text("文件夹名称").foregroundColor(.white)) {
                        TextField("输入文件夹名称", text: $folderName)
                            .foregroundColor(.white)
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
            }
            .navigationBarTitle("新建文件夹", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    isPresented = false
                }
                .foregroundColor(.white),
                trailing: Button("保存") {
                    if !folderName.isEmpty {
                        let newFolder = Folder(name: folderName, books: [])
                        bookManager.folders.append(newFolder)
                        bookManager.saveFolders()
                        isPresented = false
                    }
                }
                .disabled(folderName.isEmpty)
                .foregroundColor(folderName.isEmpty ? .gray : .white)
            )
        }
    }
}

// 欢迎视图
struct WelcomeView: View {
    @Binding var isPresented: Bool
    
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
            
            VStack(spacing: 30) {
                // 应用图标
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // 欢迎标题
                Text("欢迎使用七印图书管理器")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // 功能介绍
                VStack(alignment: .leading, spacing: 15) {
                    FeatureRow(icon: "folder.fill", title: "创建文件夹", description: "整理归类你的图书")
                    FeatureRow(icon: "book.fill", title: "添加书籍", description: "记录你的阅读进度")
                    FeatureRow(icon: "timer", title: "阅读计时", description: "追踪阅读时间")
                    FeatureRow(icon: "note.text", title: "添加笔记", description: "记录阅读心得")
                    FeatureRow(icon: "magnifyingglass", title: "快速搜索", description: "查找你的书籍")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 开始使用按钮
                Button(action: {
                    isPresented = false
                }) {
                    Text("开始使用")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .padding(.top, 50)
        }
    }
}

// 功能介绍行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.vertical, 5)
    }
} 