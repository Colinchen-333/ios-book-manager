import Foundation
import UIKit

struct ReadingLog: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    let date: Date
    let duration: TimeInterval
    var summary: String?
    var imagesData: [Data]? // Store image data instead of UIImage
    var summaryText: String? = "" // 阅读摘要文本
    var summaryImages: [UIImage] = [] // 阅读摘要图片
    init(date: Date, duration: TimeInterval, summary: String? = nil, images: [UIImage]? = nil) {
        self.date = date
        self.duration = duration
        self.summary = summary
        self.imagesData = images?.compactMap { $0.pngData() } // Convert UIImage to Data
    }
    
    // Computed property to get UIImage from Data
    var images: [UIImage]? {
        imagesData?.compactMap { UIImage(data: $0) }
    }

    // Custom Decodable and Encodable conformance to handle UIImage
    enum CodingKeys: String, CodingKey {
        case id, date, duration, summary, imagesData
    }
    
    // Equatable Conformance
    static func == (lhs: ReadingLog, rhs: ReadingLog) -> Bool {
        return lhs.id == rhs.id &&
               lhs.date == rhs.date &&
               lhs.duration == rhs.duration &&
               lhs.summary == rhs.summary &&
               lhs.imagesData == rhs.imagesData
    }

    // Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
        hasher.combine(duration)
        hasher.combine(summary)
        hasher.combine(imagesData)
    }
}
