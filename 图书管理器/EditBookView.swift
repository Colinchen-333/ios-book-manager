import SwiftUI

struct EditBookView: View {
    @Binding var book: Book
    @ObservedObject var bookManager: BookManager
    var folder: Folder
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            // 书籍封面显示
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
            } else if let image = UIImage(data: book.coverImageData ?? Data()) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
            }else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
            }

            Form {
                Section(header: Text("书籍信息")) {
                    TextField("书名", text: $book.title)
                        .disabled(!isEditing)
                    TextField("作者", text: $book.author)
                        .disabled(!isEditing)
                    TextField("出版社", text: $book.publisher)
                        .disabled(!isEditing)
                    DatePicker("添加日期", selection: $book.dateAdded, displayedComponents: .date)
                        .disabled(!isEditing)
                    TextEditor(text: Binding(
                        get: { book.notes ?? "" },
                        set: { book.notes = $0 }
                    ))
                    .disabled(!isEditing)
                }
            }
            
            // 编辑或保存按钮
            Button(action: {
                if isEditing {
                    saveChanges()
                }
                isEditing.toggle()
            }) {
                Text(isEditing ? "保存" : "编辑")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarTitle("编辑书籍", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            showImagePicker.toggle()
        }) {
            Image(systemName: "photo")
                .font(.system(size: 24))
        })
        .sheet(isPresented: $showImagePicker) {
            CustomImagePicker(sourceType: .photoLibrary) { image in
                selectedImage = image
                if let data = image.jpegData(compressionQuality: 0.8) {
                    book.coverImageData = data
                }
            }
        }
    }
    
    private func saveChanges() {
        if let folderIndex = bookManager.folders.firstIndex(where: { $0.id == folder.id }) {
            if let bookIndex = bookManager.folders[folderIndex].books.firstIndex(where: { $0.id == book.id }) {
                bookManager.folders[folderIndex].books[bookIndex] = book
                bookManager.saveFolders()
            }
        }
    }
}
