# ACG-Faka 独立版 v1.0

🎉 **异次元发卡系统完全独立版本！** 

完全去除云端依赖和应用商店功能，支持离线部署，集成多种支付插件！

---

## ✨ 主要特性

### 🚫 完全独立
- ✅ 彻底去除云端依赖
- ✅ 删除应用商店和插件市场
- ✅ 支持完全离线部署
- ✅ 无任何外部请求

### 💳 支付系统强化
- ✅ **易支付（Epay）** - 彩虹易支付聚合接口
- ✅ **支付宝** - 官方PC/手机网站支付
- ✅ **PAYJS** - 个人免签约微信支付

### 🛒 增强功能
- ✅ **商品评价** - 用户可评分和文字评价
- ✅ **自动运维** - 数据库备份、健康检查、日志归档
- ✅ **容器化部署** - Docker一键启动

---

## 🚀 快速开始

### Docker一键部署（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/yuxuancj/acg-faka-independent.git
cd acg-faka-independent

# 2. 一键启动
chmod +x docker/start.sh
./docker/start.sh

# 3. 访问服务
# 前台：http://localhost
# 后台：http://localhost/admin
# 账号：admin@acgfaka.test
# 密码：admin
```

### 传统部署
参见 [QUICK_START.md](QUICK_START.md)

---

## 📦 功能模块

### 支付插件
| 插件 | 类型 | 状态 |
|------|------|------|
| 易支付 | 聚合支付 | ✅ |
| 支付宝 | 官方 | ✅ |
| PAYJS | 个人免签 | ✅ |

### 运维功能
| 功能 | 描述 | 状态 |
|------|------|------|
| 自动备份 | 本地/远程备份 | ✅ |
| 健康检查 | 系统监控 | ✅ |
| 日志归档 | 定期归档 | ✅ |
| Webhook告警 | 钉钉/飞书 | ✅ |

---

## 📖 文档

- [快速入门指南](QUICK_START.md)
- [二次开发文档](DEVELOPMENT.md)
- [测试报告](test/TEST_REPORT.md)
- [测试用例](test/TEST_CASES.md)

---

## 🧪 测试

```bash
# 运行完整测试套件
cd test && chmod +x *.sh
./run_tests.sh
```

---

## 📝 更新日志

### v1.0-independent (2026-06-07)
- 移除所有云端依赖和更新检查
- 删除应用商店和插件市场
- 集成易支付、支付宝、PAYJS插件
- 新增商品评价功能
- 新增自动运维功能
- 完整的Docker支持
- 自动化测试套件

---

## 🤝 贡献

欢迎提交Issue和PR！

---

## 📄 许可证

本项目基于ACG-Faka开源版本二次开发。

---

## 🌟 项目信息

- 📦 版本：v1.0-independent
- 📅 更新：2026-06-07
- 🏷️ Tag：[v1.0-independent](https://github.com/yuxuancj/acg-faka-independent/releases/tag/v1.0-independent)
- 🌐 仓库：https://github.com/yuxuancj/acg-faka-independent

---

## 📧 联系

如有问题，请提交Issue！
