import SwiftUI

struct ReadingModeGuideView: View {
    @State private var countdown: Int = 5
    var onComplete: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Text("\(countdown)")
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()

            Text("即将进入阅读模式，请保持横屏")
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 使VStack充满屏幕
        .background(Color.black.edgesIgnoringSafeArea(.all)) // 背景颜色扩展到所有安全区域
        .onAppear {
            startCountdown()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            if countdown <= 0 {
                timer.invalidate()
                onComplete()
            }
        }
    }
}
