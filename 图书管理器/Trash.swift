import Foundation

class Trash: ObservableObject {
    @Published var deletedFolders: [Folder] = []
    @Published var deletedBooks: [(book: Book, folderID: UUID)] = []
}
