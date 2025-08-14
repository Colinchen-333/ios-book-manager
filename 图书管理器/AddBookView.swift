import SwiftUI
import Vision
import VisionKit
import CoreImage
import PhotosUI

struct AddBookView: View {
    @ObservedObject var bookManager: BookManager
    var folder: Folder
    
    @State private var title = ""
    @State private var author = ""
    @State private var publisher = ""
    @State private var selectedCategory: String = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var notes: String = ""
    @State private var showPhotoPermissionAlert = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let categories = ["小说", "非小说", "科幻", "历史", "传记", "自助", "教育", "艺术", "哲学", "宗教", "科技", "旅行", "烹饪", "健康", "儿童"]
    
    var body: some View {
        NavigationView {
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
                
                Form {
                    Section(header: Text("书籍信息").foregroundColor(.white)) {
                        TextField("书名", text: $title)
                            .foregroundColor(.white)
                        TextField("作者", text: $author)
                            .foregroundColor(.white)
                        TextField("出版社", text: $publisher)
                            .foregroundColor(.white)
                        
                        Picker("类别", selection: $selectedCategory) {
                            Text("选择类别").tag("")
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("添加封面").foregroundColor(.white)) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            checkPhotoPermission { hasPermission in
                                if hasPermission {
                                    isShowingImagePicker = true
                                } else {
                                    showPhotoPermissionAlert = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                                Text("选择封面图片")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    Section(header: Text("备注").foregroundColor(.white)) {
                        TextField("备注信息", text: $notes)
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
            .navigationBarTitle("添加书籍", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white),
                trailing: Button("保存") {
                    saveBook()
                }
                .disabled(title.isEmpty || author.isEmpty)
                .foregroundColor(title.isEmpty || author.isEmpty ? Color.gray : .white)
            )
            .sheet(isPresented: $isShowingImagePicker) {
                PhotoPicker(selectedImage: $selectedImage)
            }
            .alert(isPresented: $showPhotoPermissionAlert) {
                Alert(
                    title: Text("需要照片访问权限"),
                    message: Text("请在系统设置中允许访问照片库"),
                    primaryButton: .default(Text("前往设置")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func saveBook() {
        let newBook = Book(
            title: title,
            author: author,
            publisher: publisher,
            coverImage: selectedImage,
            notes: notes.isEmpty ? nil : notes,
            category: selectedCategory.isEmpty ? nil : selectedCategory
        )
        
        bookManager.addBook(newBook, to: folder)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func checkPhotoPermission(completion: @escaping (Bool) -> Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
            }
        case .restricted, .denied, .limited:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider else {
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                        self.parent.presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
