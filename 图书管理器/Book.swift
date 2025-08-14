import SwiftUI

struct Book: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var author: String
    var publisher: String
    var coverImageData: Data? // 存储封面图片的二进制数据
    var dateAdded: Date
    var addedDate: Date // 确保这个属性存在
    var notes: String?
    var progress: Double // 进度条的值
    var category: String? // 添加的类别属性
    var readingLogs: [ReadingLog] = [] // 存储阅读记录
    var folderID: UUID // 关联的文件夹ID
    var lastReadDate: Date?  // 添加 lastReadDate 属性
    var totalReadingDuration: TimeInterval = 0  // 总的阅读时长

    var coverImage: UIImage? {
        get {
            if let data = coverImageData {
                return UIImage(data: data)
            }
            return nil
        }
        set {
            coverImageData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
    
    // 更新封面图片
    mutating func updateCoverImage(_ image: UIImage) {
        self.coverImageData = image.jpegData(compressionQuality: 0.8) ?? Data()
    }
    
    // 自定义编码和解码方法，以处理 UIImage 和 Data 的转换
    enum CodingKeys: String, CodingKey {
        case id, title, author, publisher, coverImageData, dateAdded, notes, progress, category, readingLogs, folderID, lastReadDate, totalReadingDuration, addedDate
    }

    // 编码方法
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(author, forKey: .author)
        try container.encode(publisher, forKey: .publisher)
        try container.encode(coverImageData, forKey: .coverImageData)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(addedDate, forKey: .addedDate) // 编码 addedDate
        try container.encode(notes, forKey: .notes)
        try container.encode(progress, forKey: .progress)
        try container.encode(category, forKey: .category)
        try container.encode(readingLogs, forKey: .readingLogs)
        try container.encode(folderID, forKey: .folderID)
        try container.encode(lastReadDate, forKey: .lastReadDate)
        try container.encode(totalReadingDuration, forKey: .totalReadingDuration)
    }

    // 解码方法
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        publisher = try container.decode(String.self, forKey: .publisher)
        coverImageData = try container.decodeIfPresent(Data.self, forKey: .coverImageData)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        addedDate = try container.decode(Date.self, forKey: .addedDate) // 解码 addedDate
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        progress = try container.decode(Double.self, forKey: .progress)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        readingLogs = try container.decode([ReadingLog].self, forKey: .readingLogs)
        folderID = try container.decode(UUID.self, forKey: .folderID)
        lastReadDate = try container.decodeIfPresent(Date.self, forKey: .lastReadDate)
        totalReadingDuration = try container.decode(TimeInterval.self, forKey: .totalReadingDuration)
    }
    
    // 默认初始化方法
    init(id: UUID = UUID(),
         title: String,
         author: String,
         publisher: String,
         coverImageData: Data? = nil,
         dateAdded: Date = Date(),
         addedDate: Date = Date(), // 添加 addedDate 的默认值
         notes: String? = nil,
         progress: Double = 0.0,
         category: String? = nil,
         readingLogs: [ReadingLog] = [],
         folderID: UUID,
         lastReadDate: Date? = nil,
         totalReadingDuration: TimeInterval = 0) {
        self.id = id
        self.title = title
        self.author = author
        self.publisher = publisher
        self.coverImageData = coverImageData
        self.dateAdded = dateAdded
        self.addedDate = addedDate // 初始化 addedDate
        self.notes = notes
        self.progress = progress
        self.category = category
        self.readingLogs = readingLogs
        self.folderID = folderID
        self.lastReadDate = lastReadDate
        self.totalReadingDuration = totalReadingDuration
    }
}
