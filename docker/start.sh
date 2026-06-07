#!/bin/bash

# ACG-Faka 测试环境一键启动脚本
# 作者：独立开发版
# 日期：2026-06-07

set -e

echo "=========================================="
echo "  ACG-Faka 独立版 - 测试环境启动器"
echo "=========================================="
echo ""

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，正在安装Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl start docker
    systemctl enable docker
fi

# 检查docker-compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose未安装，正在安装..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

echo "✅ Docker环境检查完成"
echo ""

# 创建必要的目录
echo "📁 创建必要的目录..."
mkdir -p docker/nginx/logs
mkdir -p docker/mysql/init
mkdir -p runtime/backup
mkdir -p runtime/log
echo "✅ 目录创建完成"
echo ""

# 启动Docker服务
echo "🚀 启动Docker服务..."
systemctl start docker 2>/dev/null || true

# 停止并删除旧容器（如果存在）
echo "🧹 清理旧容器..."
docker-compose down -v 2>/dev/null || true

# 启动新容器
echo "📦 拉取镜像并启动容器..."
docker-compose up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 15

# 检查容器状态
echo ""
echo "📊 容器状态检查："
docker-compose ps

# 检查服务健康状态
echo ""
echo "🔍 健康检查："
if curl -s http://localhost > /dev/null 2>&1; then
    echo "✅ Nginx服务正常"
else
    echo "❌ Nginx服务异常"
fi

if docker exec acg-faka-mysql mysqladmin ping -h localhost > /dev/null 2>&1; then
    echo "✅ MySQL服务正常"
else
    echo "❌ MySQL服务异常"
fi

echo ""
echo "=========================================="
echo "  🎉 启动完成！"
echo "=========================================="
echo ""
echo "访问地址："
echo "  🌐 前台页面：http://localhost"
echo "  🔧 后台管理：http://localhost/admin"
echo ""
echo "测试账号："
echo "  管理员：admin@acgfaka.test"
echo "  密  码：admin"
echo ""
echo "数据库信息："
echo "  主机：localhost:3306"
echo "  用户：acgfaka"
echo "  密码：acgfaka123"
echo "  数据库：acg_faka"
echo ""
echo "=========================================="
echo ""
echo "📋 常用命令："
echo "  启动：docker-compose start"
echo "  停止：docker-compose stop"
echo "  重启：docker-compose restart"
echo "  清理：docker-compose down -v"
echo ""
echo "🧪 运行测试："
echo "  ./test/run_tests.sh"
echo ""
