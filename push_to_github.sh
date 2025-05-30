#!/bin/bash

echo "🚀 图书管理器 - 推送到GitHub脚本"
echo "=================================="

# 检查当前状态
echo "📋 检查当前Git状态..."
git status

echo ""
echo "📝 请按照以下步骤操作："
echo ""
echo "1️⃣ 在GitHub上创建新仓库："
echo "   - 访问 https://github.com/new"
echo "   - 仓库名称建议: 'BookManager' 或 'ios-book-manager'"
echo "   - 描述: 'A powerful iOS book management app with dual licensing (AGPL-3.0 + Commercial)'"
echo "   - 设为Public"
echo "   - 不要勾选README、.gitignore或LICENSE (我们已经有了)"
echo ""
echo "2️⃣ 复制仓库URL，格式如下："
echo "   https://github.com/你的用户名/仓库名.git"
echo ""

# 读取用户输入的仓库URL
read -p "🔗 请输入您的GitHub仓库URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "❌ 错误: 请输入有效的仓库URL"
    exit 1
fi

echo ""
echo "🔧 配置远程仓库..."
git remote add origin "$REPO_URL"

echo "📤 推送到GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "✅ 推送完成!"
echo ""
echo "🎉 您的图书管理器项目已成功推送到GitHub!"
echo "📖 项目地址: $REPO_URL"
echo ""
echo "📋 接下来您可以："
echo "   1. 创建第一个Release (v2.1.0)"
echo "   2. 添加项目截图到README"
echo "   3. 邀请贡献者"
echo "   4. 开始处理商业许可证咨询"
echo ""
echo "💼 商业许可证咨询邮箱: colin13909007335@outlook.com"
echo ""
echo "🎊 开源之旅开始了!" 