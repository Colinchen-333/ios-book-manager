import SwiftUI

class Folder: ObservableObject, Identifiable, Codable {
    var id = UUID()
    @Published var name: String
    @Published var books: [Book]
    @Published var isPinned: Bool = false  // 新增置顶属性
    
    enum CodingKeys: String, CodingKey {
        case id, name, books, isPinned
    }
    
    // 编码方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(books, forKey: .books)
        try container.encode(isPinned, forKey: .isPinned)
    }
    
    // 解码方法
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        books = try container.decode([Book].self, forKey: .books)
        isPinned = try container.decode(Bool.self, forKey: .isPinned)
    }

    // 添加Book到Folder的方法
    func addBook(_ book: Book) {
        books.append(book)
    }

    // 从Folder中移除Book的方法
    func removeBook(at index: Int) {
        books.remove(at: index)
    }
    
    // 初始化方法，可选地接受一个 UUID
    init(id: UUID = UUID(), name: String, books: [Book] = []) {
        self.id = id
        self.name = name
        self.books = books
    }
}

// 添加 Hashable 协议支持
extension Folder: Hashable {
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
