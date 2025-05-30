import SwiftUI

struct FolderView: View {
    var folder: Folder
    @ObservedObject var bookManager: BookManager
    @ObservedObject var trash: Trash
    
    @State private var isShowingAddBookView = false // 控制 `AddBookView` 的显示

    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.8),  // 深蓝灰色
                    Color(red: 0.7, green: 0.7, blue: 0.8)   // 浅蓝灰色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            List {
                ForEach(folder.books.indices, id: \.self) { index in
                    NavigationLink(
                        destination: BookDetailView(
                            book: .constant(folder.books[index]),
                            folder: folder,
                            bookManager: bookManager
                        )
                    ) {
                        HStack {
                            if let coverImage = folder.books[index].coverImage {
                                Image(uiImage: coverImage)
                                    .resizable()
                                    .frame(width: 50, height: 70)
                                    .cornerRadius(5)
                                    .shadow(radius: 3)
                            } else {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 70)
                                    .cornerRadius(5)
                                    .shadow(radius: 3)
                            }
                            VStack(alignment: .leading) {
                                Text(folder.books[index].title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(folder.books[index].author)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.3))  // 降低透明度使其更透明
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .buttonStyle(PlainButtonStyle())
                    .listRowBackground(Color.clear)
                    .contextMenu {
                        Button(action: {
                            deleteBook(at: index)
                        }) {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle(folder.name)
        .navigationBarItems(trailing: Button(action: {
            isShowingAddBookView = true
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $isShowingAddBookView) {
            AddBookView(bookManager: bookManager, folder: folder) // 传递当前文件夹
        }
    }

    private func deleteBook(at index: Int) {
        let book = folder.books[index]
        trash.deletedBooks.append((book, folder.id)) // 将书籍添加到垃圾桶
        bookManager.folders[bookManager.folders.firstIndex(where: { $0.id == folder.id })!]
            .books.remove(at: index)
        bookManager.saveFolders()
    }
}
