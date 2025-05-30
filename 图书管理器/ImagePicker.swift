import SwiftUI
import UIKit

// 使用 UIKit 中的 ImagePicker
var imagePicker = UIImagePickerController()

// 自定义的 ImagePicker 改名为 CustomImagePicker
struct CustomImagePicker: UIViewControllerRepresentable {
    enum SourceType {
        case photoLibrary, camera
    }

    var sourceType: SourceType
    var completionHandler: (UIImage) -> Void

    @Environment(\.presentationMode) private var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator

        switch sourceType {
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        case .camera:
            picker.sourceType = .camera
        }

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CustomImagePicker

        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completionHandler(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
