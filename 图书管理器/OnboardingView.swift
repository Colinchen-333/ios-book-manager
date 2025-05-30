import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentStep: Int = 1
    
    var body: some View {
        VStack {
            if currentStep == 1 {
                stepOneView
                    .transition(.slide)
            } else if currentStep == 2 {
                stepTwoView
                    .transition(.slide)
            }
        }
        .animation(.default, value: currentStep)
    }

    private var stepOneView: some View {
        VStack {
            Spacer()
            Text("这是一个能帮助你管理纸质书籍的软件\n欢迎来到你的黄金屋")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()

            Spacer()

            Button(action: {
                currentStep = 2
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 50)
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.gray]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
    }

    private var stepTwoView: some View {
        VStack {
            HStack {
                Text("3Q")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.red)
                Spacer()
                Text("3 Questions")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("问题 1")
                    .font(.headline)
                Text("这里是问题 1 的描述...")

                Text("问题 2")
                    .font(.headline)
                Text("这里是问题 2 的描述...")

                Text("问题 3")
                    .font(.headline)
                Text("这里是问题 3 的描述...")
            }
            .padding()
            
            Spacer()

            Button(action: {
                hasCompletedOnboarding = true
            }) {
                Text("开始使用")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding()
        }
        .background(Color(UIColor.systemGray6))
        .edgesIgnoringSafeArea(.all)
    }
}
