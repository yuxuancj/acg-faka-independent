#!/bin/bash

# ACG-Faka 独立版打包脚本
# 生成一键安装包

set -e

echo "=========================================="
echo "  ACG-Faka 独立版 - 打包工具"
echo "=========================================="
echo ""

# 版本信息
VERSION="v1.0-independent"
BUILD_DATE=$(date +%Y%m%d)
PACKAGE_NAME="acg-faka-${VERSION}-${BUILD_DATE}"

# 创建临时目录
TEMP_DIR="/tmp/${PACKAGE_NAME}"
PACKAGE_DIR="/workspace/packages"

echo "📦 开始打包..."
echo "版本：${VERSION}"
echo "日期：${BUILD_DATE}"
echo "包名：${PACKAGE_NAME}"
echo ""

# 创建目录
mkdir -p "${PACKAGE_DIR}"
mkdir -p "${TEMP_DIR}"

# 复制源码
echo "📁 复制源码..."
cp -r /workspace/* "${TEMP_DIR}/"

# 清理不需要的文件
echo "🧹 清理临时文件..."
cd "${TEMP_DIR}"
rm -rf .git
rm -rf test/*.sh
find . -name "*.log" -delete
find . -name ".DS_Store" -delete
find . -name "Thumbs.db" -delete

# 复制测试文件（但不包含执行权限的）
echo "📋 复制测试文件..."
mkdir -p "${TEMP_DIR}/test"
cp /workspace/test/TEST_REPORT.md "${TEMP_DIR}/test/"
cp /workspace/test/TEST_CASES.md "${TEMP_DIR}/test/"

# 创建安装说明
echo "📝 创建安装说明..."
cat > "${TEMP_DIR}/INSTALL.txt" << 'EOF'
================================================================================
                    ACG-Faka 独立版安装指南
================================================================================

版本：v1.0-independent
日期：${BUILD_DATE}

================================================================================
                              快速安装
================================================================================

方法1：Docker一键部署（推荐）
------------------------------
1. 解压本包
2. 进入目录：cd acg-faka-${VERSION}
3. 启动服务：chmod +x docker/start.sh && ./docker/start.sh
4. 等待30秒
5. 访问：http://localhost
6. 后台：http://localhost/admin

方法2：传统LNMP环境
-------------------
1. 环境要求：
   - PHP 8.0+
   - MySQL 5.7+
   - Nginx/Apache
   - mod_rewrite支持

2. 上传源码到Web目录

3. 配置Nginx伪静态：
   location / {
       try_files $uri $uri/ /index.php?_url=$uri&$args;
   }

4. 访问安装向导完成安装

================================================================================
                            重要提示
================================================================================

1. 安装完成后，请立即修改管理员密码
2. 生产环境请配置HTTPS
3. 定期执行数据库备份：php backup.php
4. 查看运维配置：test/TEST_REPORT.md

================================================================================
                          数据库扩展安装
================================================================================

安装主程序后，需要手动执行扩展SQL：
- 文件：kernel/Install/Extension.sql
- 包含：评价表、运维配置表

================================================================================
                            支付配置
================================================================================

后台 → 支付管理 → 支付插件

可用的支付插件：
1. 易支付（Epay）- 彩虹易支付聚合接口
2. 支付宝 - 官方PC/手机网站支付
3. PAYJS - 个人免签约微信支付

================================================================================
                            技术支持
================================================================================

文档：
- 二次开发文档：DEVELOPMENT.md
- 快速入门：QUICK_START.md
- 测试报告：test/TEST_REPORT.md
- 测试用例：test/TEST_CASES.md

================================================================================
EOF

# 创建压缩包
echo "📦 创建压缩包..."
cd /tmp
tar -czvf "${PACKAGE_DIR}/${PACKAGE_NAME}.tar.gz" "${PACKAGE_NAME}"

# 创建ZIP版本（如果zip可用）
if command -v zip &> /dev/null; then
    echo "📦 创建ZIP包..."
    cd /tmp
    zip -r "${PACKAGE_DIR}/${PACKAGE_NAME}.zip" "${PACKAGE_NAME}"
fi

# 计算文件大小
SIZE=$(du -h "${PACKAGE_DIR}/${PACKAGE_NAME}.tar.gz" | cut -f1)

# 清理临时目录
rm -rf "${TEMP_DIR}"

echo ""
echo "=========================================="
echo "  ✅ 打包完成！"
echo "=========================================="
echo ""
echo "输出文件："
echo "  📦 ${PACKAGE_DIR}/${PACKAGE_NAME}.tar.gz (${SIZE})"
if command -v zip &> /dev/null; then
    echo "  📦 ${PACKAGE_DIR}/${PACKAGE_NAME}.zip"
fi
echo ""
echo "包含内容："
echo "  ✅ 完整源码"
echo "  ✅ Docker配置"
echo "  ✅ 测试数据"
echo "  ✅ 维护脚本"
echo "  ✅ 完整文档"
echo "  ✅ 安装说明"
echo ""
echo "下一步："
echo "  1. 下载打包文件"
echo "  2. 上传到服务器"
echo "  3. 解压并执行安装"
echo ""
