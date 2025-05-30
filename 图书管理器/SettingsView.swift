import SwiftUI

struct SettingsView: View {
    @StateObject private var bookManager = BookManager()
    @State private var showRestoreAlert = false
    @State private var restoreResult: RestoreResult?
    @State private var showRestoreResultAlert = false
    @State private var isAboutSoftwarePresented = false
    
    enum RestoreResult {
        case success(Int)
        case failure(String)
    }
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.8),  // 深蓝灰色
                    Color(red: 0.7, green: 0.7, blue: 0.8)   // 浅蓝灰色
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all) // 忽略所有安全区域
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    // 数据管理部分
                    VStack(spacing: 0) {
                        // 分组标题
                        HStack {
                            Image(systemName: "externaldrive.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("数据管理")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        
                        // 选项
                        VStack(spacing: 1) {
                            Button(action: { showRestoreAlert = true }) {
                                SettingRowView(
                                    icon: "arrow.clockwise.circle.fill",
                                    title: "恢复本地数据",
                                    subtitle: "从本地存储恢复之前的数据"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: DebugView(bookManager: bookManager)) {
                                SettingRowView(
                                    icon: "doc.text.magnifyingglass",
                                    title: "数据状态",
                                    subtitle: "查看应用数据详细信息"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.85))
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // 应用信息部分
                    VStack(spacing: 0) {
                        // 分组标题
                        HStack {
                            Image(systemName: "app.badge.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                            Text("应用信息")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        
                        // 选项
                        Button(action: { isAboutSoftwarePresented = true }) {
                            SettingRowView(
                                icon: "info.circle.fill",
                                title: "关于图书管理器",
                                subtitle: "版本 2.1.0"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.85))
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 20)
            }
        }
        .navigationBarTitle("设置", displayMode: .inline)
        .onAppear {
            // 只为导航栏设置样式
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        .sheet(isPresented: $isAboutSoftwarePresented) {
            AboutSoftwareView()
                .transition(.opacity)
                .animation(.easeInOut, value: isAboutSoftwarePresented)
        }
        .alert(isPresented: $showRestoreAlert) {
            Alert(
                title: Text("确认恢复数据"),
                message: Text("这将尝试恢复本地存储的数据，是否继续？"),
                primaryButton: .destructive(Text("确认恢复")) {
                    restoreLocalData()
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }
        .alert(isPresented: $showRestoreResultAlert) {
            Alert(
                title: Text("恢复结果"),
                message: Text({
                    switch restoreResult {
                    case .success(let count):
                        return "成功恢复 \(count) 个文件夹的数据"
                    case .failure(let error):
                        return "恢复失败：\(error)"
                    case .none:
                        return ""
                    }
                }()),
                dismissButton: .default(Text("确定"))
            )
        }
    }
    
    private func restoreLocalData() {
        do {
            let count = try bookManager.restoreFromLocalStorage()
            restoreResult = .success(count)
            NotificationCenter.default.post(name: .init("RefreshContentView"), object: nil)
        } catch {
            restoreResult = .failure(error.localizedDescription)
        }
        showRestoreResultAlert = true
    }
}

// MARK: - 自定义组件

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .imageScale(.small)
            Text(title)
                .foregroundColor(.white)
        }
        .textCase(nil)
        .font(.headline)
    }
}

struct SettingRowView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.7)) // 深蓝色图标
                .imageScale(.large)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85)) // 更深的文字颜色
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color.black.opacity(0.6)) // 副标题颜色
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.black.opacity(0.4))
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.7)) // 深蓝色图标
                .imageScale(.large)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.85)) // 更深的文字颜色
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color.black.opacity(0.6)) // 副标题颜色
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.black.opacity(0.4))
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

struct AboutSoftwareView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.8),  // 深蓝灰色
                    Color(red: 0.7, green: 0.7, blue: 0.8)   // 浅蓝灰色
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 顶部关闭按钮
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                
                // 应用图标
                VStack {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 120, height: 120)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 5)
                }
                
                // 应用信息
                VStack(spacing: 15) {
                    Text("图书管理器")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("版本 2.1.0")
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // 底部版权信息
                VStack(spacing: 10) {
                    Text("© 2024-2025 开源项目")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("AGPL-3.0 + 商业双重许可证")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 30)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}

// 调试视图
struct DebugView: View {
    @ObservedObject var bookManager: BookManager
    
    var body: some View {
        ZStack {
            // 添加渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.6, blue: 0.8),  // 深蓝灰色
                    Color(red: 0.7, green: 0.7, blue: 0.8)   // 浅蓝灰色
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            List {
                Section(header: Text("数据统计")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))) {
                    Text("文件夹总数：\(bookManager.folders.count)")
                        .foregroundColor(.black.opacity(0.85))
                        .font(.system(size: 16, weight: .medium))
                    Text("书籍总数：\(bookManager.folders.flatMap { $0.books }.count)")
                        .foregroundColor(.black.opacity(0.85))
                        .font(.system(size: 16, weight: .medium))
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                Section(header: Text("文件夹详情")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))) {
                    ForEach(bookManager.folders) { folder in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("📁 \(folder.name)")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.85))
                            Text("包含 \(folder.books.count) 本书")
                                .font(.subheadline)
                                .foregroundColor(.black.opacity(0.6))
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                Section(header: Text("本地存储")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .bold))) {
                    Button("打印存储路径") {
                        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            print("📂 文档目录：\(path)")
                            do {
                                let files = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
                                print("发现文件：")
                                files.forEach { print("- \($0.lastPathComponent)") }
                            } catch {
                                print("读取目录失败：\(error)")
                            }
                        }
                    }
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.7))
                    .font(.system(size: 16, weight: .medium))
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.8))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color.clear) // 设置列表背景为透明
            .onAppear {
                // 设置列表背景为透明
                UITableView.appearance().backgroundColor = .clear
                UITableView.appearance().separatorColor = .clear
            }
        }
        .navigationTitle("调试信息")
    }
}

// 添加自定义转场样式
extension AnyTransition {
    static var smoothTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)),
            removal: .opacity.combined(with: .move(edge: .bottom))
        )
    }
}

// 优化按钮点击效果
struct AnimatedButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
        }
        .buttonStyle(SmoothButtonStyle())
    }
}

// 自定义按钮样式
struct SmoothButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// 修改 Section 标题样式
extension View {
    func customSectionHeader(_ title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .semibold))
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .textCase(nil)
    }
}
