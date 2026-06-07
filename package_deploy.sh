#!/bin/bash
# =============================================================
# ACG-Faka 独立版 v2.0 - 打包脚本
# =============================================================
# 用途：打包完整项目，方便上传到宝塔面板覆盖部署
# =============================================================

VERSION="v2.0-chenze-full"
BUILD_DATE=$(date +%Y%m%d)
PACKAGE_DIR="release"
PACKAGE_NAME="acg-faka-deploy"

echo "=========================================="
echo "  ACG-Faka 独立版 $VERSION - 打包脚本"
echo "=========================================="
echo ""

# 创建目录
mkdir -p "$PACKAGE_DIR"

# 清理旧文件
rm -rf "$PACKAGE_DIR/$PACKAGE_NAME"
rm -f "$PACKAGE_DIR/$PACKAGE_NAME.tar.gz"
rm -f "$PACKAGE_DIR/$PACKAGE_NAME.zip"

echo "📦 开始打包..."

# 创建项目目录
mkdir -p "$PACKAGE_DIR/$PACKAGE_NAME"

# 复制核心文件
echo "  复制核心文件..."
cp -r app "$PACKAGE_DIR/$PACKAGE_NAME/"
cp -r assets "$PACKAGE_DIR/$PACKAGE_NAME/"
cp -r baota "$PACKAGE_DIR/$PACKAGE_NAME/"
cp -r config "$PACKAGE_DIR/$PACKAGE_NAME/"
cp -r kernel "$PACKAGE_DIR/$PACKAGE_NAME/"
cp -r vendor "$PACKAGE_DIR/$PACKAGE_NAME/"
cp .htaccess "$PACKAGE_DIR/$PACKAGE_NAME/"
cp BAOTA_README.md "$PACKAGE_DIR/$PACKAGE_NAME/"
cp LICENSE "$PACKAGE_DIR/$PACKAGE_NAME/"
cp QUICK_START.md "$PACKAGE_DIR/$PACKAGE_NAME/"
cp README.md "$PACKAGE_DIR/$PACKAGE_NAME/"
cp composer.json "$PACKAGE_DIR/$PACKAGE_NAME/"
cp composer.lock "$PACKAGE_DIR/$PACKAGE_NAME/"
cp favicon.ico "$PACKAGE_DIR/$PACKAGE_NAME/"
cp index.php "$PACKAGE_DIR/$PACKAGE_NAME/"
cp install.php "$PACKAGE_DIR/$PACKAGE_NAME/"
cp install_submit.php "$PACKAGE_DIR/$PACKAGE_NAME/"

# 创建运行时目录（空目录需要创建）
mkdir -p "$PACKAGE_DIR/$PACKAGE_NAME/runtime"
mkdir -p "$PACKAGE_DIR/$PACKAGE_NAME/public"

# 设置权限文件
echo "  设置权限..."
touch "$PACKAGE_DIR/$PACKAGE_NAME/runtime/.gitkeep"
touch "$PACKAGE_DIR/$PACKAGE_NAME/public/.gitkeep"

# 打包为tar.gz
echo "  打包为 tar.gz..."
cd "$PACKAGE_DIR"
tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME/"

# 打包为zip
if command -v zip &> /dev/null; then
    echo "  打包为 zip..."
    zip -r "$PACKAGE_NAME.zip" "$PACKAGE_NAME/"
fi

cd ..

echo ""
echo "=========================================="
echo "  ✅ 打包完成！"
echo "=========================================="
echo ""
echo "输出文件："
echo "  - $PACKAGE_DIR/$PACKAGE_NAME.tar.gz"
if command -v zip &> /dev/null; then
    echo "  - $PACKAGE_DIR/$PACKAGE_NAME.zip"
fi
echo ""
echo "下一步："
echo "  1. 下载打包文件"
echo "  2. 在宝塔面板上传到网站根目录"
echo "  3. 解压覆盖现有文件"
echo "  4. 设置伪静态规则"
echo "  5. 访问 install.php 完成安装"
echo ""
echo "📁 包含的文件结构："
echo "  app/           - 应用代码"
echo "  assets/        - 静态资源"
echo "  baota/         - 宝塔配置文件"
echo "  config/        - 配置文件"
echo "  kernel/        - 核心框架"
echo "  vendor/        - Composer依赖"
echo "  install.php    - 安装入口"
echo "  index.php      - 网站入口"
echo ""
