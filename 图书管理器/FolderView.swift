import SwiftUI

struct FolderView: View {
    @ObservedObject var folder: Folder
    @ObservedObject var bookManager: BookManager
    @State private var isShowingAddBookView = false
    @State private var isShowingRenameSheet = false
    @State private var newName: String = ""
    @State private var showDeleteConfirmation = false
    @State private var bookToDelete: Book? = nil
    
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
            
            VStack(spacing: 16) {
                // 文件夹标题栏
                HStack {
                    Text(folder.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        newName = folder.name
                        isShowingRenameSheet = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                
                // 书籍列表
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(folder.books.indices, id: \.self) { index in
                            let book = folder.books[index]
                            if let folderIndex = bookManager.folders.firstIndex(where: { $0.id == folder.id }) {
                                NavigationLink(destination: BookDetailView(
                                    book: Binding(
                                        get: { bookManager.folders[folderIndex].books[index] },
                                        set: { newValue in
                                            bookManager.folders[folderIndex].books[index] = newValue
                                            bookManager.saveFolders()
                                        }
                                    ),
                                    folder: folder,
                                    bookManager: bookManager
                                )) {
                                    BookCard(book: book)
                                        .contextMenu {
                                            Button(action: {
                                                bookToDelete = book
                                                showDeleteConfirmation = true
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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            isShowingAddBookView = true
        }) {
            Image(systemName: "plus")
                .foregroundColor(.white)
                .font(.system(size: 22, weight: .medium))
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())
        })
        .sheet(isPresented: $isShowingAddBookView) {
            AddBookView(bookManager: bookManager, folder: folder)
        }
        .sheet(isPresented: $isShowingRenameSheet) {
            renameFolderSheet
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("删除书籍"),
                message: Text("确定要删除这本书吗？"),
                primaryButton: .destructive(Text("删除")) {
                    if let book = bookToDelete {
                        bookManager.deleteBook(book, from: folder)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var renameFolderSheet: some View {
        NavigationView {
            ZStack {
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
                    Section(header: Text("重命名文件夹").foregroundColor(.white)) {
                        TextField("文件夹名称", text: $newName)
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
            .navigationBarTitle("重命名", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    isShowingRenameSheet = false
                }
                .foregroundColor(.white),
                trailing: Button("保存") {
                    bookManager.renameFolder(folder, to: newName)
                    isShowingRenameSheet = false
                }
                .disabled(newName.isEmpty)
                .foregroundColor(.white)
            )
        }
    }
}

struct BookCard: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let coverImage = book.coverImage {
                Image(uiImage: coverImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
