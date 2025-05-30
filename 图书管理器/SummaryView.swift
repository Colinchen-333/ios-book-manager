import SwiftUI

struct SummaryView: View {
    @Binding var summaryText: String
    @Binding var summaryImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    var onSave: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $summaryText)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .frame(height: 200)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(summaryImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                        }
                        Button(action: {
                            pickImage()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitle("添加摘要", displayMode: .inline)
            .navigationBarItems(trailing: Button("保存") {
                onSave()
                presentationMode.wrappedValue.dismiss()
            })
            .padding()
        }
    }
    
    private func pickImage() {
        // 实现图片选择功能，这里可以使用UIImagePickerController
    }
}
