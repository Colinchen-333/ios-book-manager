# 图书管理器 (Book Manager)

图书管理器是一个功能强大的iOS应用程序，帮助用户更好地管理和追踪他们的阅读生活。使用Swift和SwiftUI开发，提供了直观的用户界面和丰富的功能。

A powerful iOS application that helps users better manage and track their reading life. Built with Swift and SwiftUI, providing an intuitive user interface and rich functionality.

## 主要功能 (Main Features)

### 1. 书籍管理 (Book Management)
- 添加书籍，包括标题、作者、出版社、封面图片和笔记
- Add books with title, author, publisher, cover image, and notes
- 将书籍整理到不同文件夹中
- Organize books into different folders
- 跟踪每本书的阅读进度
- Track reading progress for each book
- 按类别分类书籍
- Categorize books by type
- 支持图书封面扫描和OCR识别
- Support book cover scanning and OCR recognition

### 2. 阅读模式 (Reading Mode)
- 计时功能跟踪阅读时长
- Timer function to track reading duration
- 支持倒计时或已读时间跟踪
- Support countdown or elapsed time tracking
- 记录阅读日志，包括时间和摘要
- Record reading logs with time and summary

### 3. 用户界面 (User Interface)
- 基于标签的界面，包括资源库、阅读模式和设置
- Tab-based interface with library, reading mode, and settings
- 基于文件夹的组织结构
- Folder-based organization structure
- 书籍搜索功能
- Book search functionality
- 整个应用采用蓝色渐变主题
- Blue gradient theme throughout the app

### 4. 数据持久化 (Data Persistence)
- 书籍和文件夹使用JSON序列化存储
- Books and folders stored using JSON serialization
- 文件同时保存在UserDefaults和文件系统中
- Files saved in both UserDefaults and file system
- 包含数据迁移的版本控制系统
- Version control system with data migration
- 回收站系统用于可恢复的删除操作
- Trash system for recoverable delete operations

### 5. 其他功能 (Other Features)
- 为首次使用者提供引导体验
- Onboarding experience for first-time users
- 数据管理设置
- Data management settings
- 关于部分信息
- About section information

## 技术特点 (Technical Features)

- 使用SwiftUI构建现代化用户界面 / Modern UI built with SwiftUI
- 采用MVVM架构模式 / MVVM architecture pattern
- 支持iOS系统 / iOS platform support
- 使用Vision框架实现OCR功能 / OCR functionality using Vision framework
- 实现数据持久化和版本控制 / Data persistence and version control
- 支持深色模式 / Dark mode support

## 系统要求 (System Requirements)

- iOS 14.0 或更高版本 / iOS 14.0 or later
- Xcode 13.0 或更高版本（用于开发）/ Xcode 13.0 or later (for development)
- Swift 5.0 或更高版本 / Swift 5.0 or later

## 安装与使用 (Installation & Usage)

1. 克隆此仓库到本地 / Clone this repository to local
```bash
git clone https://github.com/your-username/BookManager.git
```

2. 使用Xcode打开项目文件 `图书管理器.xcodeproj` / Open project file with Xcode

3. 选择目标设备或模拟器 / Select target device or simulator

4. 点击运行按钮开始使用 / Click run button to start using

## 贡献 (Contributing)

欢迎提交Issue和Pull Request来帮助改进这个项目。
Welcome to submit Issues and Pull Requests to help improve this project.

## 许可证 (License)

本项目采用**双重许可证模式** / This project uses **dual licensing**：

### 🆓 开源许可证（AGPL-3.0）/ Open Source License (AGPL-3.0)
本项目在AGPL-3.0下发布。任何人都可以使用、修改和分发本软件，但需要遵守AGPL-3.0的条款。
This project is released under AGPL-3.0. Anyone can use, modify and distribute this software, but must comply with AGPL-3.0 terms.

### 💼 商业许可证 / Commercial License
如果您希望在闭源商业产品中使用本软件，或者不希望遵守AGPL-3.0的开源要求，可以购买商业许可证。
If you wish to use this software in closed-source commercial products, or don't want to comply with AGPL-3.0 open-source requirements, you can purchase a commercial license.

### 📋 如何选择？/ How to Choose?

| 使用场景 (Use Case) | 推荐许可证 (Recommended License) | 说明 (Description) |
|---------|-----------|------|
| 个人学习使用 / Personal learning | AGPL-3.0 | 免费，需遵守开源条款 / Free, comply with open source terms |
| 教育机构研究 / Educational research | AGPL-3.0 | 免费，需遵守开源条款 / Free, comply with open source terms |
| 开源项目集成 / Open source integration | AGPL-3.0 | 免费，需遵守开源条款 / Free, comply with open source terms |
| 公司研究项目 / Corporate research | AGPL-3.0 | 免费，需遵守开源条款 / Free, comply with open source terms |
| 闭源商业产品 / Closed-source commercial | 商业许可证 / Commercial | 付费，无需开源 / Paid, no need to open source |
| SaaS服务(不开源) / SaaS (not open) | 商业许可证 / Commercial | 付费，无需开源 / Paid, no need to open source |

### 📞 商业许可证咨询 / Commercial License Inquiry
- **邮箱 / Email**：colin13909007335@outlook.com
- **咨询说明 / Inquiry Guide**：参见 [COMMERCIAL-PRICING.md](COMMERCIAL-PRICING.md)
- **许可证模板 / License Template**：参见 [LICENSES/COMMERCIAL.txt](LICENSES/COMMERCIAL.txt)

> 💡 **定价模式 / Pricing Model**：我们采用按需商榷的方式，根据您的具体使用场景、用户规模和技术支持需求提供定制化报价。欢迎咨询！
> 
> We adopt a consultative pricing approach, providing customized quotes based on your specific use case, user scale, and technical support requirements. Welcome to inquire!

### ❓ 常见问题 / FAQ

**Q：我在公司做研究需要开源吗？/ Do I need to open source for corporate research?**  
A：如果遵守AGPL-3.0条款，无需付费。但如果向外部用户提供服务，需要开源。/ No payment required if you comply with AGPL-3.0 terms. But if you provide services to external users, open sourcing is required.

**Q：什么情况下需要购买商业许可证？/ When do I need to purchase a commercial license?**  
A：当您希望在闭源产品中使用，或者提供SaaS服务但不想开源时。/ When you want to use in closed-source products, or provide SaaS services without open sourcing.

完整许可证条款请参阅 [LICENSE](LICENSE) 文件。
For complete license terms, please refer to the [LICENSE](LICENSE) file.

## 版本信息 (Version Information)

当前版本 / Current Version：2.1.0 