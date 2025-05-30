import SwiftUI
import Vision
import VisionKit
import CoreImage
struct AddBookView: View {
    @ObservedObject var bookManager: BookManager
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var publisher: String = ""
    @State private var notes: String = ""
    @State private var selectedFolder: Folder?
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isProcessingOCR = false
    @State private var progress: Double = 0.0
    @State private var rotationAngle: Angle = .degrees(0)
    @State private var imageScale: CGFloat = 1.0
    @State private var selectedCategory: String = "小说"
    @State private var customCategory: String = ""
    @State private var categories: [String] = [
        "小说", "非小说", "科幻", "历史", "传记", "自助", "教育", 
        "艺术", "哲学", "宗教", "科技", "旅行", "烹饪", "健康", 
        "儿童", "社会", "经济"
    ]
    @State private var showCustomAlert = false
    @State private var newFolderName: String = ""
    @State private var showFolderAlert = false
    @State private var isFolderHighlighted = false
    @State private var showFolderPicker = false
    @Environment(\.presentationMode) var presentationMode

    init(bookManager: BookManager, folder: Folder? = nil) {
        self.bookManager = bookManager
        self._selectedFolder = State(initialValue: folder) // 初始化文件夹
    }

    var body: some View {
        NavigationView {
            ZStack {
                // 渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.4, green: 0.6, blue: 0.8),
                        Color(red: 0.7, green: 0.7, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 封面图片部分
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .frame(height: 200)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 180)
                                    .rotationEffect(rotationAngle)
                                    .scaleEffect(imageScale)
                                    .cornerRadius(10)
                                    .gesture(
                                        DragGesture()
                                            .onEnded { value in
                                                if abs(value.translation.width) > abs(value.translation.height) {
                                                    rotationAngle += .degrees(value.translation.width > 0 ? 90 : -90)
                                                }
                                            }
                                    )
                                    .gesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                imageScale = value.magnitude
                                            }
                                    )
                            } else {
                                VStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("添加封面")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .onTapGesture {
                            showImagePicker = true
                        }
                        
                        if isProcessingOCR {
                            ProgressView("正在识别...")
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        
                        // 主要信息部分
                        VStack(spacing: 25) {
                            // 文件夹选择
                            HStack {
                                Image(systemName: "folder")
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                // 显示当前选择的文件夹
                                Text(selectedFolder?.name ?? "选择文件夹")
                                    .foregroundColor(selectedFolder == nil ? .gray : .primary)
                                
                                Spacer()
                                
                                // 文件夹选择按钮
                                Button(action: {
                                    showFolderPicker = true
                                }) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isFolderHighlighted ? Color.red : Color.clear, lineWidth: 1)
                            )
                            .sheet(isPresented: $showFolderPicker) {
                                NavigationView {
                                    List {
                                        // 添加新文件夹按钮
                                        Button(action: {
                                            showFolderPicker = false  // 先关闭文件夹选择器
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                withAnimation {
                                                    showCustomAlert = true  // 显示自定义弹窗
                                                }
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "folder.badge.plus")
                                                    .foregroundColor(.blue)
                                                Text("新建文件夹")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        
                                        // 现有文件夹列表
                                        ForEach(bookManager.folders) { folder in
                                            HStack {
                                                Image(systemName: "folder.fill")
                                                    .foregroundColor(.blue)
                                                Text(folder.name)
                                                Spacer()
                                                if selectedFolder?.id == folder.id {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                selectedFolder = folder
                                                showFolderPicker = false
                                            }
                                        }
                                    }
                                    .navigationTitle("选择文件夹")
                                    .navigationBarItems(
                                        trailing: Button("取消") {
                                            showFolderPicker = false
                                        }
                                    )
                                }
                            }
                            
                            // 书籍信息输入
                            CustomInputField(icon: "book", placeholder: "书名", text: $title)
                            CustomInputField(icon: "person", placeholder: "作者", text: $author)
                            CustomInputField(icon: "building.2", placeholder: "出版社", text: $publisher)
                            
                            // 笔记输入
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    Text("笔记")
                                        .foregroundColor(.gray)
                                }
                                CustomTextView(text: $notes)
                                    .frame(height: 120)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                            }
                            
                            // 类别选择
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                Picker("类别", selection: $selectedCategory) {
                                    ForEach(categories, id: \.self) { category in
                                        Text(category).tag(category)
                                    }
                                    Text("自定义").tag("自定义")
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            
                            if selectedCategory == "自定义" {
                                CustomInputField(icon: "tag.fill", placeholder: "输入自定义类别", text: $customCategory)
                            }
                            
                            // 阅读进度
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "book.closed")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    Text("阅读进度: \(Int(progress))%")
                                        .foregroundColor(.gray)
                                }
                                Slider(value: $progress, in: 0...100, step: 1)
                                    .accentColor(.blue)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                
                // 添加自定义弹窗
                if showCustomAlert {
                    customFolderAlert
                }
            }
            .navigationBarTitle("添加书籍", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    saveBook()
                }
                .disabled(title.isEmpty || selectedFolder == nil)
            )
            .sheet(isPresented: $showImagePicker) {
                CustomImagePicker(sourceType: .photoLibrary) { image in
                    selectedImage = image
                    processImageForOCR(image)
                }
            }
            .alert(isPresented: $showFolderAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text("请选择文件夹！"),
                    dismissButton: .default(Text("确认")) {
                        withAnimation {
                            isFolderHighlighted = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isFolderHighlighted = false
                            }
                        }
                    }
                )
            }
        }
    }
    

    private func processImageForOCR(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        // 创建图片的不同角度版本
        let originalImage = UIImage(cgImage: cgImage)
        let rotatedImage = rotateImage(image: originalImage, byDegrees: 90)

        let requestHandlerOriginal = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let requestHandlerRotated = VNImageRequestHandler(cgImage: rotatedImage.cgImage!, options: [:])

        // 先处理原始图片的 OCR
        processOCR(requestHandler: requestHandlerOriginal) { detectedTitle, detectedAuthor, detectedPublisher in
            if detectedTitle.isEmpty && detectedAuthor.isEmpty && detectedPublisher.isEmpty {
                // 如果原始图片未检测到有效结果，尝试使用旋转后的图片
                processOCR(requestHandler: requestHandlerRotated) { rotatedTitle, rotatedAuthor, rotatedPublisher in
                    // 更新识别结果
                    DispatchQueue.main.async {
                        self.isProcessingOCR = false
                        self.title = rotatedTitle
                        self.author = rotatedAuthor
                        self.publisher = rotatedPublisher
                    }
                }
            } else {
                // 更新识别结果
                DispatchQueue.main.async {
                    self.isProcessingOCR = false
                    self.title = detectedTitle
                    self.author = detectedAuthor
                    self.publisher = detectedPublisher
                }
            }
        }
    }

    // OCR 处理函数
    private func processOCR(requestHandler: VNImageRequestHandler, completion: @escaping (String, String, String) -> Void) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("", "", "")
                return
            }

            var detectedTitle: String = ""
            var detectedAuthor: String = ""
            var detectedPublisher: String = ""

            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    let text = topCandidate.string

                    // 优先选择竖排的文本进行书名、作者、出版社的识别
                    if self.isVerticalText(observation: observation) {
                        if detectedTitle.isEmpty {
                            detectedTitle = text // 如果书名为空，则优先填充竖排文本
                        }
                        if detectedAuthor.isEmpty && (text.count <= 3 || text.contains("著")) {
                            detectedAuthor = text
                        }
                        if detectedPublisher.isEmpty && (text.contains("出版社") || text.contains("公司") || text.contains("出版")) {
                            detectedPublisher = text
                        }
                    } else {
                        // 横排文本作为备选
                        if detectedTitle.isEmpty {
                            detectedTitle = text
                        }
                        if detectedAuthor.isEmpty && (text.count <= 3 || text.contains("著")) {
                            detectedAuthor = text
                        }
                        if detectedPublisher.isEmpty && (text.contains("出版社") || text.contains("公司") || text.contains("出版")) {
                            detectedPublisher = text
                        }
                    }
                }
            }
            
            // 返回识别结果
            completion(detectedTitle, detectedAuthor, detectedPublisher)
        }

        request.recognitionLanguages = ["zh-Hans"]  // 设置中文识别
        request.usesLanguageCorrection = true

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("OCR识别失败: \(error)")
                completion("", "", "")
            }
        }
    }

    // 判断文本是否为竖排
    private func isVerticalText(observation: VNRecognizedTextObservation) -> Bool {
        let aspectRatio = observation.boundingBox.height / observation.boundingBox.width
        return aspectRatio > 2.0 // 当高宽比超过2时，视为竖排文本
    }

    // 旋转图片函数
    private func rotateImage(image: UIImage, byDegrees degrees: CGFloat) -> UIImage {
        let radians = degrees * CGFloat.pi / 180
        var newSize = CGRect(origin: CGPoint.zero, size: image.size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size

        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        let context = UIGraphicsGetCurrentContext()!

        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)

        image.draw(in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return rotatedImage!
    }
    // 新建文件夹
    private func createNewFolder(name: String) {
        var folderName = name
        if folderName.isEmpty {
            let defaultName = "新建文件夹"
            var counter = 1
            while bookManager.folders.contains(where: { $0.name == "\(defaultName) \(counter)" }) {
                counter += 1
            }
            folderName = "\(defaultName) \(counter)"
        }
        
        let newFolder = Folder(name: folderName, books: [])
        bookManager.folders.append(newFolder)
        bookManager.saveFolders()
        selectedFolder = newFolder
        showFolderPicker = false
    }
    
    // 保存书籍
    private func saveBook() {
        guard let folder = selectedFolder else {
            showFolderAlert = true
            return
        }
        
        let newBook = Book(
            id: UUID(),
            title: title,
            author: author,
            publisher: publisher,
            coverImageData: selectedImage?.jpegData(compressionQuality: 0.8) ?? Data(),
            dateAdded: Date(),
            notes: notes,
            progress: progress,
            category: selectedCategory,
            folderID: folder.id

        )
        
        if let folderIndex = bookManager.folders.firstIndex(where: { $0.id == folder.id }) {
            bookManager.folders[folderIndex].addBook(newBook)
            bookManager.saveFolders()
            print("书籍已保存")
            
            // 保存成功后关闭视图，返回主界面
            presentationMode.wrappedValue.dismiss()
        }
    }

    // 添加自定义弹窗视图
    private var customFolderAlert: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("新建文件夹")
                    .font(.headline)
                
                TextField("输入文件夹名称", text: $newFolderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button("取消") {
                        newFolderName = ""
                        showCustomAlert = false
                    }
                    .foregroundColor(.red)
                    
                    Button("确定") {
                        if !newFolderName.isEmpty {
                            createNewFolder(name: newFolderName)
                            newFolderName = ""
                            showCustomAlert = false
                        }
                    }
                    .disabled(newFolderName.isEmpty)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
    }
}

// 自定义的 TextView 以支持 done 按钮
struct CustomTextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.returnKeyType = .done  // 设置 returnKeyType 为 .done
        textView.backgroundColor = UIColor.clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView
        
        init(_ parent: CustomTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()  // 关闭键盘
                return false
            }
            return true
        }
    }
}

// 自定义输入框组件
struct CustomInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
