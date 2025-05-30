import SwiftUI
import Combine

class BookManager: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var books: [Book] = []
    @Published var filteredBooks: [Book] = []  // 确保这个属性存在
    
    // 更新版本控制
    private let currentVersion = 2  // 增加版本号
    private let folderFileName = "folders_v2.json"  // 更新文件名以匹配新版本
    private let legacyFolderFileNames = ["folders.json", "folders_v1.json"]  // 旧版本文件名列表
    
    var authors: [String] {
        // 从 books 列表中提取作者
        Set(books.map { $0.author }).sorted()
    }
    
    var publishers: [String] {
        // 从 books 列表中提取出版社
        Set(books.map { $0.publisher }).sorted()
    }
    
    init() {
        loadFolders()
    }
    
    // 保存到文件系统
    func saveFolders() {
        do {
            let data = try JSONEncoder().encode(folders)
            
            // 同时保存到 UserDefaults 和文件系统，确保向后兼容
            UserDefaults.standard.set(data, forKey: "folders")
            
            // 保存到文件系统
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(folderFileName)
                try data.write(to: fileURL)
                print("✅ 数据已保存到文件：\(folderFileName)")
            }
        } catch {
            print("❌ 保存失败：\(error)")
        }
    }
    
    // 加载数据（优先从文件系统加载，如果失败则尝试从 UserDefaults 加载）
    func loadFolders() {
        // 首先尝试从文件系统加载
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(folderFileName)
            
            do {
                let data = try Data(contentsOf: fileURL)
                folders = try JSONDecoder().decode([Folder].self, from: data)
                print("✅ 从文件系统加载数据成功")
                return
            } catch {
                print("⚠️ 从文件系统加载失败，尝试从 UserDefaults 加载")
            }
        }
        
        // 如果文件系统加载失败，尝试从 UserDefaults 加载
        if let savedData = UserDefaults.standard.data(forKey: "folders"),
           let savedFolders = try? JSONDecoder().decode([Folder].self, from: savedData) {
            folders = savedFolders
            print("✅ 从 UserDefaults 加载数据成功")
            // 将数据保存到文件系统以完成迁移
            saveFolders()
        }
    }
    
    // 从本地存储恢复数据
    func restoreFromLocalStorage() throws -> Int {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法访问文档目录"])
        }
        
        print("📂 开始恢复本地数据...")
        
        // 首先尝试从 UserDefaults 恢复
        if let savedData = UserDefaults.standard.data(forKey: "folders"),
           let savedFolders = try? JSONDecoder().decode([Folder].self, from: savedData) {
            self.folders = savedFolders
            saveFolders() // 保存到文件系统
            print("✅ 从 UserDefaults 恢复成功：\(savedFolders.count) 个文件夹")
            return savedFolders.count
        }
        
        // 如果 UserDefaults 没有数据，尝试从文件系统恢复
        let possibleFiles = [folderFileName] + legacyFolderFileNames
        
        for fileName in possibleFiles {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("📄 发现数据文件：\(fileName)")
                
                do {
                    let data = try Data(contentsOf: fileURL)
                    let loadedFolders = try JSONDecoder().decode([Folder].self, from: data)
                    self.folders = loadedFolders
                    saveFolders() // 保存到最新的文件
                    print("✅ 从文件 \(fileName) 恢复成功：\(loadedFolders.count) 个文件夹")
                    return loadedFolders.count
                } catch {
                    print("❌ 读取文件失败：\(error)")
                }
            }
        }
        
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "未找到可恢复的数据"])
    }
    
    // 添加新文件夹
    func addFolder(_ folder: Folder) {
        folders.append(folder)
        saveFolders()
    }

    // 删除文件夹
    func removeFolder(at index: Int) {
        folders.remove(at: index)
        saveFolders()
    }

    // 添加书籍到指定文件夹
    func addBook(_ book: Book, to folder: Folder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].addBook(book)
            folders = folders
            saveFolders()
        }
    }

    // 删除文件夹中的书籍
    func removeBook(at bookIndex: Int, from folder: Folder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].removeBook(at: bookIndex)
            folders = folders
            saveFolders()
        }
    }
    
    // 添加阅读记录
    func addReadingLog(_ log: ReadingLog, to book: Book, in folder: Folder) {
        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
           let bookIndex = folders[folderIndex].books.firstIndex(where: { $0.id == book.id }) {
            folders[folderIndex].books[bookIndex].readingLogs.append(log)
            folders[folderIndex].books[bookIndex].lastReadDate = log.date // 更新最后阅读时间
            saveFolders()
        }
    }

    // 搜索书籍
    func searchBooks(with searchText: String) -> [Book] {
        return folders.flatMap { $0.books }.filter { book in
            book.title.contains(searchText) || book.author.contains(searchText)
        }
    }
}
