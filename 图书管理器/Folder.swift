import SwiftUI

struct Folder: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var books: [Book]
    var isPinned: Bool = false  // 新增置顶属性

    // 添加Book到Folder的方法
    mutating func addBook(_ book: Book) {
        books.append(book)
    }

    // 从Folder中移除Book的方法
    mutating func removeBook(at index: Int) {
        books.remove(at: index)
    }

    // 获取书籍的绑定（如果在外部代码中有这种需求）
    func binding(for book: Book, in folders: Binding<[Folder]>) -> Binding<Book>? {
        guard let folderIndex = folders.wrappedValue.firstIndex(where: { $0.id == self.id }),
              let bookIndex = folders[folderIndex].books.firstIndex(where: { $0.id == book.id }) else {
            return nil
        }
        return folders[folderIndex].books[bookIndex]
    }
    
    // 初始化方法，可选地接受一个 UUID
    init(id: UUID = UUID(), name: String, books: [Book] = []) {
        self.id = id
        self.name = name
        self.books = books
    }
}
