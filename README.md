# ACG-Faka 异次元发卡系统

🎉 **独立版 v2.0** - 完全去除云端依赖，集成晨泽发卡核心功能！

---

## 📦 版本信息

- **当前版本**: v2.0-chenze-full
- **更新日期**: 2026-06-07
- **基于版本**: v1.0-independent
- **仓库地址**: https://github.com/yuxuancj/acg-faka-independent

---

## ✨ 核心特性

### 🚫 完全独立
- ✅ 移除所有云端依赖
- ✅ 删除应用商店
- ✅ 支持离线部署
- ✅ 无外部服务器请求

### 💳 支付系统
- ✅ 易支付（彩虹易支付聚合）
- ✅ 支付宝（PC/手机网站支付）
- ✅ PAYJS（个人免签微信支付）
- ✅ 余额支付

### 👥 用户体系
- ✅ 用户等级与成长值系统
- ✅ 积分系统（获取、使用、抽奖）
- ✅ 每日签到（连续签到奖励）

### 🛒 促销系统
- ✅ 秒杀活动（预热模式、限购、独立库存）
- ✅ 优惠券系统（满减/折扣/无门槛、兑换码）
- ✅ 批发优惠（阶梯折扣）

### 📨 售后工单
- ✅ 工单系统（卡密补发/API授权/退款等）
- ✅ 自动标签分类（关键词匹配）
- ✅ 工单回复与附件

### 💰 分销提现
- ✅ 推广海报生成（预留接口）
- ✅ 提现管理（支付宝/微信/银行卡）
- ✅ 提现审核功能

### 📊 数据报表
- ✅ 数据大屏（实时监控）
- ✅ 自定义报表（预留接口）
- ✅ 访问统计记录

### 🛠️ 其他功能
- ✅ 商品评价系统
- ✅ 自动运维（数据库备份、健康检查）
- ✅ 自定义页面
- ✅ 友情链接
- ✅ 隐藏商品
- ✅ 批量导入（预留接口）
- ✅ 卡密库存预警（预留接口）
- ✅ 卡密到期提醒（预留接口）

---

## 🚀 快速开始

### Docker 一键部署（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/yuxuancj/acg-faka-independent.git
cd acg-faka-independent

# 2. 启动服务
chmod +x docker/start.sh
./docker/start.sh

# 3. 访问
# 前台: http://localhost
# 后台: http://localhost/admin
# 账号: admin@acgfaka.test
# 密码: admin
```

### 宝塔一键部署（强烈推荐）

```bash
# 方式1: 使用宝塔一键脚本
wget https://github.com/yuxuancj/acg-faka-independent/raw/main/install_baota.sh
chmod +x install_baota.sh
./install_baota.sh

# 方式2: 手动部署
# 下载源码，在宝塔面板创建网站，上传源码，设置伪静态
# 详细步骤请查看 BAOTA_README.md
```

宝塔部署包包含：
- ✅ 自动安装脚本
- ✅ Nginx配置模板
- ✅ 伪静态规则
- ✅ 安装向导界面
- ✅ 详细部署文档

### 传统LNMP环境

请参阅 [QUICK_START.md](QUICK_START.md) 获取详细安装指南。

---

## 📋 功能清单

### v2.0 新增功能

| 模块 | 功能 | 状态 |
|------|------|------|
| 用户体系 | 用户等级与成长值 | ✅ |
| 用户体系 | 积分系统完整版 | ✅ |
| 用户体系 | 每日签到系统 | ✅ |
| 订单促销 | 订单超时自动关闭 | ✅ |
| 订单促销 | 秒杀活动 | ✅ |
| 订单促销 | 批发优惠（阶梯折扣） | ✅ |
| 订单促销 | 优惠券系统 | ✅ |
| 分销推广 | 推广海报生成 | ✅ |
| 分销推广 | 提现管理 | ✅ |
| 售后工单 | 工单系统 | ✅ |
| 售后工单 | 自动标签分类 | ✅ |
| 数据报表 | 数据大屏 | ✅ |
| 其他功能 | 自定义页面 | ✅ |
| 其他功能 | 友情链接 | ✅ |
| 其他功能 | 隐藏商品 | ✅ |

### v1.0 已有功能

| 模块 | 功能 | 状态 |
|------|------|------|
| 基础系统 | 移除云端依赖 | ✅ |
| 基础系统 | 移除应用商店 | ✅ |
| 支付系统 | 易支付 | ✅ |
| 支付系统 | 支付宝 | ✅ |
| 支付系统 | PAYJS | ✅ |
| 商品功能 | 商品评价 | ✅ |
| 运维功能 | 自动备份 | ✅ |
| 运维功能 | 健康检查 | ✅ |
| 运维功能 | 日志归档 | ✅ |

---

## 🗄️ 数据库结构

### 数据库迁移

v2.0 数据库迁移文件位于: `/kernel/Install/Migration_v2.0.sql`

### 新增表（v2.0）

1. `user_level` - 用户等级配置
2. `user_points_log` - 积分变动记录
3. `user_checkin` - 签到记录
4. `coupon` - 优惠券配置
5. `user_coupon` - 用户优惠券
6. `flash_sale` - 秒杀活动
7. `wholesale_discount` - 批发折扣
8. `lottery` - 积分抽奖奖品
9. `lottery_log` - 抽奖记录
10. `poster_template` - 海报模板
11. `withdraw` - 提现申请
12. `ticket` - 工单
13. `ticket_reply` - 工单回复
14. `stat_visit` - 访问统计
15. `custom_page` - 自定义页面
16. `friend_link` - 友情链接
17. `config_extra` - 扩展配置

### 修改表（v2.0）

- `user` - 新增成长值、积分、等级ID等字段
- `commodity` - 新增隐藏商品、等级价格、批发折扣等字段

---

## 📚 文档

- [快速入门指南](QUICK_START.md)
- [宝塔一键部署文档](BAOTA_README.md)
- [v2.0 二次开发文档](DEVELOPMENT_V2.md)
- [v1.0 开发文档](DEVELOPMENT.md)
- [晨泽功能覆盖报告](FEATURE_COVERAGE.md)
- [测试报告](test/TEST_REPORT.md)
- [测试用例](test/TEST_CASES.md)

---

## 🎯 使用示例

### 用户等级与积分

```php
// 用户服务类
$userService = new \App\Service\UserServiceV2();

// 增加成长值（消费获得）
$userService->addGrowthPoints($userId, 100);

// 每日签到
$result = $userService->dailyCheckin($userId);
if ($result['success']) {
    echo "获得{$result['points']}积分";
}
```

### 优惠券使用

```php
$couponService = new \App\Service\CouponService();

// 领取优惠券
$couponService->receiveCoupon($userId, $couponId);

// 计算优惠金额
$discount = $couponService->calculateDiscount($userCoupon, $orderAmount);
```

### 工单系统

```php
$ticketService = new \App\Service\TicketService();

// 创建工单
$ticketService->createTicket($userId, [
    'type' => 1,
    'title' => '卡密无效',
    'content' => '购买的卡密无法使用',
    'order_id' => $orderId
]);
```

更多示例请参阅 [DEVELOPMENT_V2.md](DEVELOPMENT_V2.md)

---

## 🛠️ 配置系统

### 功能开关

所有功能都可以在后台或通过 `config_extra` 表进行配置：

```php
// 启用/禁用用户等级
\App\Model\ConfigExtra::setValue('level_enabled', 1);

// 启用/禁用积分系统
\App\Model\ConfigExtra::setValue('points_enabled', 1);

// 启用/禁用签到
\App\Model\ConfigExtra::setValue('checkin_enabled', 1);

// 配置最低提现金额
\App\Model\ConfigExtra::setValue('withdraw_min_amount', 10);
```

---

## 🔄 更新日志

### v2.0-chenze-full (2026-06-07)

#### 新增
- ✅ 用户等级与成长值系统
- ✅ 积分系统完整版（获取、使用、抽奖）
- ✅ 每日签到系统（连续签到奖励）
- ✅ 秒杀活动（预热模式、限购、独立库存）
- ✅ 优惠券系统（满减/折扣/无门槛、兑换码）
- ✅ 批发优惠（阶梯折扣）
- ✅ 工单系统（卡密补发/API授权/退款等）
- ✅ 工单自动标签分类
- ✅ 提现管理（支付宝/微信/银行卡）
- ✅ 推广海报生成（预留接口）
- ✅ 数据大屏（实时监控）
- ✅ 自定义页面
- ✅ 友情链接
- ✅ 隐藏商品功能
- ✅ 完整的数据库迁移脚本
- ✅ 新增模型和服务类
- ✅ 完整的二次开发文档
- ✅ 宝塔一键部署脚本
- ✅ 宝塔Nginx配置模板
- ✅ 宝塔伪静态规则
- ✅ 宝塔安装向导界面
- ✅ 宝塔部署完整文档
- ✅ 晨泽功能覆盖报告

### v1.0-independent (2026-06-07)

#### 新增
- ✅ 易支付聚合支付接口
- ✅ 支付宝官方支付接口
- ✅ PAYJS个人免签约支付
- ✅ 商品评价系统
- ✅ 自动运维功能（数据库备份、健康检查）
- ✅ Docker一键部署
- ✅ 自动化测试套件

#### 删除
- 🗑️ 所有云端依赖
- 🗑️ 应用商店功能
- 🗑️ 更新检查

---

## 📥 版本下载

### Git标签

```bash
# 克隆并切换到v2.0
git clone https://github.com/yuxuancj/acg-faka-independent.git
cd acg-faka-independent
git checkout v2.0-chenze-full

# 或者直接下载
wget https://github.com/yuxuancj/acg-faka-independent/archive/refs/tags/v2.0-chenze-full.tar.gz
```

### Releases页面

访问: https://github.com/yuxuancj/acg-faka-independent/releases

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

本项目基于 ACG-Faka 开源版本二次开发。

---

## 🌟 Star History

如果觉得这个项目有用，请给个Star支持！

---

**项目地址**: https://github.com/yuxuancj/acg-faka-independent  
**最新版本**: v2.0-chenze-full  
**最后更新**: 2026-06-07
