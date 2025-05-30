import SwiftUI

struct FeatureTourView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var isFinishing = false
    
    // 功能介绍数据
    private let features = [
        Feature(
            title: "智能图书管理",
            description: "轻松管理您的纸质书籍，支持扫描封面自动识别书籍信息",
            imageName: "books.vertical.fill",
            color: .blue,
            background: "feature_books"
        ),
        Feature(
            title: "阅读追踪",
            description: "记录每次阅读时间，追踪阅读进度，培养良好的阅读习惯",
            imageName: "book.circle.fill",
            color: .purple,
            background: "feature_tracking"
        ),
        Feature(
            title: "个性化书架",
            description: "创建自定义文件夹，按照您喜欢的方式整理图书",
            imageName: "folder.fill.badge.person.crop",
            color: .orange,
            background: "feature_shelf"
        ),
        Feature(
            title: "阅读统计",
            description: "直观展示您的阅读数据，包括阅读时长、完成书目等",
            imageName: "chart.pie.fill",
            color: .green,
            background: "feature_stats"
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景渐变
                LinearGradient(
                    gradient: Gradient(colors: [
                        features[currentPage].color.opacity(0.3),
                        features[currentPage].color.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 动态背景图案
                ForEach(0..<3) { index in
                    Circle()
                        .fill(features[currentPage].color.opacity(0.1))
                        .frame(width: geometry.size.width * 0.6)
                        .offset(
                            x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -100...100)
                        )
                        .blur(radius: 50)
                }
                
                VStack(spacing: 30) {
                    // 页面指示器
                    HStack(spacing: 8) {
                        ForEach(0..<features.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? features[index].color : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    // 功能展示区域
                    TabView(selection: $currentPage) {
                        ForEach(0..<features.count, id: \.self) { index in
                            FeatureCard(feature: features[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    
                    // 操作按钮
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("上一页")
                                }
                                .foregroundColor(features[currentPage].color)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }
                        
                        Button(action: {
                            if currentPage < features.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isFinishing = true
                                }
                                // 延迟设置完成引导
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    hasCompletedOnboarding = true
                                }
                            }
                        }) {
                            HStack {
                                Text(currentPage < features.count - 1 ? "下一页" : "开始使用")
                                if currentPage < features.count - 1 {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(features[currentPage].color)
                            .cornerRadius(25)
                            .shadow(color: features[currentPage].color.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .opacity(isFinishing ? 0 : 1)
            .animation(.easeInOut(duration: 0.5), value: isFinishing)
        }
    }
}

// 功能卡片视图
private struct FeatureCard: View {
    let feature: Feature
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            // 图标
            Image(systemName: feature.imageName)
                .font(.system(size: 80))
                .foregroundColor(feature.color)
                .padding()
                .background(
                    Circle()
                        .fill(feature.color.opacity(0.1))
                        .frame(width: 160, height: 160)
                )
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // 标题
            Text(feature.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(feature.color)
            
            // 描述
            Text(feature.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .opacity(0.8)
            
            Spacer()
        }
        .padding(.top, 60)
        .onAppear {
            isAnimating = true
        }
    }
}

// 功能数据模型
private struct Feature {
    let title: String
    let description: String
    let imageName: String
    let color: Color
    let background: String?
    
    init(title: String, description: String, imageName: String, color: Color, background: String? = nil) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.color = color
        self.background = background
    }
} 