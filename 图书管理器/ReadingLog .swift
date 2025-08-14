import Foundation
import UIKit

struct ReadingLog: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    let date: Date
    let duration: TimeInterval  // 以分钟为单位
    var notes: String?
    var imagesData: [Data]?
    
    init(date: Date = Date(), duration: TimeInterval, notes: String? = nil) {
        self.date = date
        self.duration = duration
        self.notes = notes
        self.imagesData = nil
    }
    
    // 添加图片的初始化方法
    init(date: Date = Date(), duration: TimeInterval, notes: String? = nil, images: [UIImage]) {
        self.date = date
        self.duration = duration
        self.notes = notes
        self.imagesData = images.compactMap { $0.pngData() }
    }
    
    // Computed property to get UIImage from Data
    var images: [UIImage]? {
        imagesData?.compactMap { UIImage(data: $0) }
    }

    // Coding Keys
    enum CodingKeys: String, CodingKey {
        case id, date, duration, notes, imagesData
    }
    
    // Equatable
    static func == (lhs: ReadingLog, rhs: ReadingLog) -> Bool {
        return lhs.id == rhs.id &&
               lhs.date == rhs.date &&
               lhs.duration == rhs.duration &&
               lhs.notes == rhs.notes &&
               lhs.imagesData == rhs.imagesData
    }

    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
        hasher.combine(duration)
        hasher.combine(notes)
        hasher.combine(imagesData)
    }
}
