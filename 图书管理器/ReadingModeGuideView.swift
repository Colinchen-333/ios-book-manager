import SwiftUI

struct ReadingModeGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // 背景渐变色
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.8),  // 顶部颜色
                    Color(red: 0.6, green: 0.75, blue: 0.9)  // 底部颜色
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // 内容
            VStack(alignment: .leading, spacing: 20) {
                Text("阅读模式使用指南")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        guideItem(icon: "play.fill", title: "开始阅读", description: "点击开始按钮启动计时器，开始记录你的阅读时间。")
                        guideItem(icon: "pause.fill", title: "暂停阅读", description: "需要暂停时，点击暂停按钮。时间会停止计算，直到你再次点击开始。")
                        guideItem(icon: "checkmark.circle", title: "完成阅读", description: "阅读结束后，点击完成按钮。系统会记录你的阅读时长。")
                        guideItem(icon: "clock", title: "时间记录", description: "阅读时间会自动计算并显示为时:分:秒格式。")
                        guideItem(icon: "book.closed", title: "阅读习惯", description: "建议每次阅读至少25分钟，不受干扰地专注阅读。")
                        guideItem(icon: "eye", title: "护眼提醒", description: "每阅读45分钟，建议休息5-10分钟，看看远处或做眼部放松。")
                    }
                    .padding()
                }
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                
                Spacer()
                
                // 关闭按钮
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("了解了")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.4, green: 0.6, blue: 0.8))
                        .cornerRadius(10)
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
    }
    
    private func guideItem(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 5)
    }
}
