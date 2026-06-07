# ACG-Faka 独立版 - 快速入门指南

## 🎯 5分钟快速启动

### 第一步：检查环境
```bash
# 检查Docker
docker --version

# 检查docker-compose
docker-compose --version
```

如果未安装，请参考安装文档或使用在线安装脚本。

### 第二步：一键启动
```bash
# 进入项目目录
cd /workspace

# 启动所有服务
chmod +x docker/start.sh
./docker/start.sh
```

等待30秒，服务自动启动完成。

### 第三步：访问测试
```
🌐 前台页面：http://localhost
🔧 后台管理：http://localhost/admin
```

**测试账号**：
- 管理员：admin@acgfaka.test
- 密　码：admin

### 第四步：运行测试
```bash
# 完整测试
chmod +x test/*.sh
./test/run_tests.sh

# 查看测试报告
cat test/TEST_REPORT.md
```

---

## 📋 完整功能测试清单

### ✅ 已实现的支付插件
1. **易支付（Epay）** - 彩虹易支付聚合
   - 支持：支付宝、微信、QQ钱包
   - 配置：API地址、商户号、密钥

2. **支付宝** - 官方支付
   - 支持：电脑网站支付、手机网站支付
   - 配置：AppID、私钥、公钥

3. **PAYJS** - 个人免签约
   - 支持：微信扫码支付
   - 配置：商户号、通信密钥

### ✅ 商品评价功能
- 用户可对已购买商品评分
- 支持文字评价
- 商家可回复评价
- 后台审核评价

### ✅ 自动运维功能
- 数据库自动备份
- 系统健康检查
- 日志自动归档
- 钉钉/飞书Webhook告警

---

## 🔧 常用运维命令

### 启动服务
```bash
docker-compose up -d
```

### 停止服务
```bash
docker-compose stop
```

### 重启服务
```bash
docker-compose restart
```

### 查看日志
```bash
# Nginx日志
docker-compose logs nginx

# PHP日志
docker-compose logs php

# MySQL日志
docker-compose logs mysql
```

### 进入容器
```bash
# 进入PHP容器
docker exec -it acg-faka-php bash

# 进入MySQL容器
docker exec -it acg-faka-mysql bash
```

### 数据库连接
```bash
docker exec -it acg-faka-mysql mysql -u root -pacg_faka_2024
```

### 手动备份数据库
```bash
php backup.php
```

### 健康检查
```bash
php health_check.php
```

### 日志归档
```bash
php archive_logs.php
```

---

## 🌐 数据库信息

| 项目 | 值 |
|------|-----|
| 主机 | localhost:3306 |
| 用户 | acgfaka |
| 密码 | acgfaka123 |
| 数据库 | acg_faka |
| Root密码 | acg_faka_2024 |

---

## 📁 重要文件位置

### 配置
- Docker配置：`docker-compose.yml`
- Nginx配置：`docker/nginx/conf.d/default.conf`
- PHP配置：容器内

### 源码
- 应用代码：`app/`
- 核心框架：`kernel/`
- 静态资源：`assets/`
- 配置文件：`config/`

### 测试
- 测试脚本：`test/`
- 测试报告：`test/TEST_REPORT.md`
- 测试用例：`test/TEST_CASES.md`

### 维护脚本
- 数据库备份：`backup.php`
- 健康检查：`health_check.php`
- 日志归档：`archive_logs.php`

---

## 🚀 生产环境部署

### 1. 环境要求
- CPU: 2核+
- 内存: 4GB+
- 硬盘: 50GB+
- 系统: Ubuntu 20.04 / CentOS 7+

### 2. 安装Docker
```bash
curl -fsSL https://get.docker.com | sh
systemctl enable docker
```

### 3. 部署步骤
```bash
# 1. 上传源码
scp -r acg-faka user@your-server:/var/www/

# 2. 配置HTTPS（推荐）
# 编辑docker/nginx/conf.d/default.conf添加SSL配置

# 3. 修改数据库密码
# 编辑docker-compose.yml修改MYSQL_ROOT_PASSWORD

# 4. 启动服务
cd /var/www/acg-faka
docker-compose up -d

# 5. 配置防火墙
ufw allow 80
ufw allow 443
```

### 4. 配置Cron定时任务
```bash
# 编辑crontab
crontab -e

# 添加以下任务
0 3 * * * php /var/www/acg-faka/backup.php >> /var/log/backup.log 2>&1
0 * * * * php /var/www/acg-faka/health_check.php >> /var/log/health.log 2>&1
0 4 * * * php /var/www/acg-faka/archive_logs.php >> /var/log/archive.log 2>&1
```

---

## 🔒 安全建议

### 1. 修改默认密码
- 管理员密码
- 数据库密码
- 所有支付接口密钥

### 2. 配置HTTPS
```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    # ... 其他配置
}
```

### 3. 限制敏感目录访问
```nginx
location ~ /\. {
    deny all;
}

location ~ ^/(runtime|vendor|.env) {
    deny all;
}
```

### 4. 定期备份
```bash
# 建议每天备份
0 3 * * * php /path/to/backup.php

# 异地备份
0 4 * * * rsync -avz /var/www/acg-faka/runtime/backup/ user@backup-server:/backup/
```

### 5. 监控和日志
- 配置日志轮转
- 监控容器状态
- 定期检查健康报告

---

## 📞 故障排除

### 容器启动失败
```bash
# 查看日志
docker-compose logs

# 重建容器
docker-compose down
docker-compose up -d
```

### 数据库连接失败
```bash
# 检查MySQL容器
docker ps | grep mysql

# 重启MySQL
docker-compose restart mysql

# 检查连接
docker exec -it acg-faka-php php -r "new PDO('mysql:host=mysql', 'root', 'acg_faka_2024');"
```

### Web服务无响应
```bash
# 检查Nginx状态
docker-compose logs nginx

# 重启Nginx
docker-compose restart nginx

# 检查端口占用
netstat -tlnp | grep 80
```

---

## 📚 更多文档

- **二次开发文档**：`DEVELOPMENT.md`
- **测试报告**：`test/TEST_REPORT.md`
- **测试用例**：`test/TEST_CASES.md`
- **数据库结构**：`kernel/Install/`
- **扩展SQL**：`kernel/Install/Extension.sql`

---

**版本**：v1.0-independent  
**更新日期**：2026-06-07  
**测试状态**：✅ 全部通过
