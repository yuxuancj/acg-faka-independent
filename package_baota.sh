#!/bin/bash
# =============================================================
# ACG-Faka 独立版 v2.0 - 宝塔部署包打包脚本
# =============================================================

VERSION="v2.0-chenze-full"
BUILD_DATE=$(date +%Y%m%d)
PACKAGE_DIR="release"
PACKAGE_NAME="acg-faka-$VERSION-baota"

echo "=========================================="
echo "  ACG-Faka 独立版 $VERSION - 打包脚本"
echo "=========================================="
echo ""

# 创建目录
mkdir -p "$PACKAGE_DIR"

# 清理旧文件
rm -f "$PACKAGE_DIR/$PACKAGE_NAME.tar.gz"
rm -f "$PACKAGE_DIR/$PACKAGE_NAME.zip"

echo "📦 开始打包..."

# 复制源码
echo "  复制源码..."
cp -r README.md "$PACKAGE_DIR/"
cp -r QUICK_START.md "$PACKAGE_DIR/"
cp -r DEVELOPMENT_V2.md "$PACKAGE_DIR/"
cp -r FEATURE_COVERAGE.md "$PACKAGE_DIR/"
cp -r install_baota.sh "$PACKAGE_DIR/"
cp -r BAOTA_README.md "$PACKAGE_DIR/README.md"
cp -r baota "$PACKAGE_DIR/baota/"

# 打包为tar.gz
echo "  打包为 tar.gz..."
cd "$PACKAGE_DIR"
tar -czf "$PACKAGE_NAME.tar.gz" ./* --exclude="*.tar.gz" --exclude="*.zip"

# 打包为zip
if command -v zip &> /dev/null; then
    echo "  打包为 zip..."
    zip -r "$PACKAGE_NAME.zip" ./* -x "*.tar.gz" -x "*.zip"
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
echo "  1. 上传到服务器"
echo "  2. 解压到网站目录"
echo "  3. 按照 BAOTA_README.md 操作"
echo ""
