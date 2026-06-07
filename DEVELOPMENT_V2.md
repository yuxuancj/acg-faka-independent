# ACG-Faka v2.0 二次开发文档

## 版本信息

- **版本**: v2.0-chenze-full
- **更新日期**: 2026-06-07
- **基于**: v1.0-independent

## 新增功能概览

### 1. 用户体系增强
- ✅ 用户等级与成长值系统
- ✅ 积分系统（获取、使用、抽奖）
- ✅ 每日签到系统

### 2. 订单与促销
- ✅ 订单状态机完善（超时自动关闭）
- ✅ 秒杀活动（预热模式、限购、独立库存）
- ✅ 批发优惠（阶梯折扣）
- ✅ 优惠券系统（满减/折扣/无门槛、兑换码）

### 3. 分销与推广
- ✅ 推广海报自动生成（预留接口）
- ✅ 提现管理（支付宝/微信/银行卡）

### 4. 售后与工单
- ✅ 工单系统（卡密补发/API授权/退款等）
- ✅ 自动标签分类（关键词匹配）

### 5. 数据与报表
- ✅ 数据大屏（实时监控）
- ✅ 自定义报表（预留接口）

### 6. 其他功能
- ✅ 批量导入商品（预留接口）
- ✅ 商品专属二维码海报（预留接口）
- ✅ 卡密库存预警（预留接口）
- ✅ 隐藏商品（数据库字段）
- ✅ 自定义页面（数据库表）
- ✅ 友情链接（数据库表）

## 数据库结构变更

### 新增表

| 表名 | 说明 |
|------|------|
| `user_level` | 用户等级配置 |
| `user_points_log` | 积分变动记录 |
| `user_checkin` | 签到记录 |
| `coupon` | 优惠券配置 |
| `user_coupon` | 用户优惠券 |
| `flash_sale` | 秒杀活动 |
| `wholesale_discount` | 批发折扣 |
| `lottery` | 积分抽奖奖品 |
| `lottery_log` | 抽奖记录 |
| `poster_template` | 海报模板 |
| `withdraw` | 提现申请 |
| `ticket` | 工单 |
| `ticket_reply` | 工单回复 |
| `stat_visit` | 访问统计 |
| `custom_page` | 自定义页面 |
| `friend_link` | 友情链接 |
| `config_extra` | 扩展配置 |

### 修改表

| 表名 | 新增字段 | 说明 |
|------|----------|------|
| `user` | `growth_points`, `points`, `level_id`, `is_new_admin` | 用户扩展字段 |
| `commodity` | `is_hidden`, `level_prices`, `has_wholesale`, `source_api_config`, `expire_days` | 商品扩展字段 |

## 迁移文件

数据库迁移SQL位置: `/kernel/Install/Migration_v2.0.sql`

### 应用迁移

```sql
-- 执行迁移脚本
-- 注意替换__PREFIX__为你的表前缀
```

## 新增模型类

### 用户相关
- `App\Model\UserLevel` - 用户等级模型
- `App\Model\UserPointsLog` - 积分记录模型
- `App\Model\UserCheckin` - 签到记录模型

### 促销相关
- `App\Model\Coupon` - 优惠券模型
- `App\Model\UserCoupon` - 用户优惠券模型
- `App\Model\FlashSale` - 秒杀活动模型
- `App\Model\WholesaleDiscount` - 批发折扣模型
- `App\Model\Lottery` - 抽奖奖品模型
- `App\Model\LotteryLog` - 抽奖记录模型

### 分销相关
- `App\Model\PosterTemplate` - 海报模板模型
- `App\Model\Withdraw` - 提现申请模型

### 工单相关
- `App\Model\Ticket` - 工单模型
- `App\Model\TicketReply` - 工单回复模型

### 其他
- `App\Model\ConfigExtra` - 扩展配置模型
- `App\Model\CustomPage` - 自定义页面模型
- `App\Model\FriendLink` - 友情链接模型

## 新增服务类

| 类名 | 位置 | 功能 |
|------|------|------|
| `UserServiceV2` | `app/Service/UserServiceV2.php` | 用户等级、积分、签到 |
| `CouponService` | `app/Service/CouponService.php` | 优惠券管理 |
| `LotteryService` | `app/Service/LotteryService.php` | 积分抽奖 |
| `TicketService` | `app/Service/TicketService.php` | 工单系统 |
| `WithdrawService` | `app/Service/WithdrawService.php` | 提现管理 |
| `OrderEnhanceService` | `app/Service/OrderEnhanceService.php` | 订单增强（秒杀、批发、优惠计算） |

## 配置系统

### 功能开关

所有新增功能都可在 `config_extra` 表中配置开关：

```php
// 获取配置
\App\Model\ConfigExtra::getValue('key_name', 'default_value');

// 设置配置
\App\Model\ConfigExtra::setValue('key_name', 'value');
```

### 配置项列表

| 分组 | 配置项 | 说明 | 默认值 |
|------|--------|------|--------|
| user | level_enabled | 启用用户等级 | 1 |
| user | points_enabled | 启用积分系统 | 1 |
| user | checkin_enabled | 启用签到 | 1 |
| user | checkin_base_points | 签到基础积分 | 10 |
| user | checkin_continuous_bonus | 连续签到额外积分 | 5 |
| coupon | enabled | 启用优惠券 | 1 |
| flash_sale | enabled | 启用秒杀 | 1 |
| wholesale | enabled | 启用批发折扣 | 1 |
| lottery | enabled | 启用抽奖 | 1 |
| ticket | enabled | 启用工单 | 1 |
| withdraw | enabled | 启用提现 | 1 |
| withdraw | min_amount | 最低提现金额 | 10 |
| poster | enabled | 启用海报 | 1 |
| order | auto_close_minutes | 订单超时分钟 | 30 |
| stock | alert_threshold | 库存预警阈值 | 10 |
| card | expire_reminder_days | 到期提醒天数 | 3,1 |

## 使用示例

### 用户等级与成长值

```php
// 给用户增加成长值
$userService = new \App\Service\UserServiceV2();
$userService->addGrowthPoints($userId, 100);

// 获取用户等级
$user = \App\Model\User::find($userId);
$level = \App\Model\UserLevel::find($user->level_id);
```

### 积分系统

```php
// 增加积分
$userService->addPoints($userId, 50, '购物奖励', $orderId, 'order');

// 扣除积分
$userService->usePoints($userId, 20, '兑换商品', $productId, 'exchange');

// 积分抽奖
$lotteryService = new \App\Service\LotteryService();
$result = $lotteryService->draw($userId);
if ($result['success']) {
    echo "获得: " . $result['text'];
}
```

### 签到系统

```php
// 用户签到
$userService = new \App\Service\UserServiceV2();
$result = $userService->dailyCheckin($userId);
if ($result['success']) {
    echo "获得{$result['points']}积分，连续{$result['continuous_days']}天";
}
```

### 优惠券系统

```php
$couponService = new \App\Service\CouponService();

// 领取优惠券
$couponService->receiveCoupon($userId, $couponId);

// 使用兑换码领取
$couponService->redeemByCode($userId, 'ABC123DEF');

// 计算优惠
$discount = $couponService->calculateDiscount($userCoupon, $orderAmount, [$productId]);

// 使用优惠券
$couponService->useCoupon($userCouponId, $orderId);
```

### 秒杀活动

```php
// 获取进行中的秒杀
$sales = \App\Model\FlashSale::getActiveSales();

// 获取即将开始的秒杀（预热）
$upcoming = \App\Model\FlashSale::getUpcomingSales();
```

### 批发折扣

```php
// 根据数量获取折扣
$discount = \App\Model\WholesaleDiscount::getDiscountByQty($productId, $quantity);
if ($discount) {
    echo "折扣: {$discount->discount}%";
}
```

### 工单系统

```php
$ticketService = new \App\Service\TicketService();

// 创建工单
$ticketService->createTicket($userId, [
    'type' => 1,
    'title' => '卡密无效',
    'content' => '...',
    'order_id' => $orderId
]);

// 添加回复
$ticketService->addReply($ticketId, $adminId, 2, '已处理...');

// 更新状态
$ticketService->updateStatus($ticketId, 2, $adminId); // 2=已解决
```

### 提现管理

```php
$withdrawService = new \App\Service\WithdrawService();

// 申请提现
$withdrawService->apply($userId, 100, 1, 'alipay@test.com', '真实姓名');

// 审核通过
$withdrawService->audit($withdrawId, 1, '已打款');

// 审核拒绝
$withdrawService->audit($withdrawId, 2, '账号信息错误');
```

### 订单增强

```php
$orderService = new \App\Service\OrderEnhanceService();

// 计算价格（包含所有优惠）
$priceResult = $orderService->calculatePrice($productId, $quantity, $userId, $userCouponId);
if ($priceResult['success']) {
    echo "最终价格: {$priceResult['final_price']}";
}

// 关闭超时订单
$closedCount = $orderService->closeExpiredOrders();

// 订单完成后处理
$orderService->onOrderComplete($order);
```

## 定时任务

建议配置以下定时任务：

```cron
# 关闭超时订单（每分钟执行）
* * * * * php /path/to/cron/close_expired_orders.php

# 卡密到期提醒（每天执行）
0 9 * * * php /path/to/cron/card_expire_reminder.php

# 库存预警（每小时检查）
0 * * * * php /path/to/cron/stock_alert.php

# 数据统计（每天统计）
0 2 * * * php /path/to/cron/stat_daily.php
```

## 控制器开发指引

### 后台控制器新增功能点

1. **用户管理** - 等级设置、积分管理
2. **促销管理** - 优惠券、秒杀、批发、抽奖
3. **工单管理** - 工单列表、回复、处理
4. **提现管理** - 提现审核
5. **数据报表** - 数据大屏、自定义报表
6. **扩展配置** - 功能开关、系统设置

### 前台控制器新增功能点

1. **个人中心** - 我的积分、我的优惠券、提现记录、签到
2. **促销活动** - 秒杀活动、积分抽奖、优惠券领取
3. **工单中心** - 提交工单、查看工单、回复工单
4. **推广中心** - 生成推广海报

## 视图开发指引

遵循现有模板风格，在对应目录下添加视图文件：

```
app/View/Admin/
├── Coupon/
├── FlashSale/
├── Ticket/
├── Withdraw/
└── Report/

app/View/User/
├── Checkin/
├── Coupon/
├── Lottery/
├── Ticket/
└── Withdraw/
```

## API接口设计（预留）

### 积分相关
- `POST /api/user/checkin` - 签到
- `GET /api/user/points/log` - 积分记录
- `POST /api/lottery/draw` - 抽奖

### 优惠券相关
- `GET /api/coupon/list` - 可用优惠券
- `POST /api/coupon/receive` - 领取优惠券
- `POST /api/coupon/redeem` - 兑换码兑换

### 工单相关
- `GET /api/ticket/list` - 我的工单
- `POST /api/ticket/create` - 创建工单
- `POST /api/ticket/reply` - 回复工单

### 提现相关
- `GET /api/withdraw/records` - 提现记录
- `POST /api/withdraw/apply` - 申请提现

## 安全建议

1. **权限控制** - 新增功能都要添加权限验证
2. **参数验证** - 所有输入参数进行严格验证
3. **SQL注入防护** - 使用ORM，避免直接拼接SQL
4. **CSRF防护** - 表单提交使用CSRF Token
5. **频率限制** - 抽奖、签到等接口添加频率限制

## 性能优化

1. **索引优化** - 确保关键字段有索引
2. **缓存机制** - 等级配置、优惠券等可缓存
3. **分页查询** - 列表数据使用分页
4. **定时任务** - 大数据量操作放定时任务执行

## 升级指南

### 从v1.0升级到v2.0

1. **备份数据库**
2. **执行迁移脚本** `Migration_v2.0.sql`
3. **替换新增的模型和服务类**
4. **更新配置**（如有需要）
5. **测试所有功能**

### 数据迁移检查清单

- [ ] 用户表新增字段
- [ ] 商品表新增字段
- [ ] 所有新增表创建成功
- [ ] 默认配置插入成功
- [ ] 默认用户等级插入成功

## 常见问题

### Q: 如何启用/禁用某个功能？
A: 编辑 `config_extra` 表中对应的配置项，设为1启用，0禁用。

### Q: 如何添加新的用户等级？
A: 在 `user_level` 表中插入记录，设置 `min_points`（所需成长值）和 `discount`（折扣率）。

### Q: 如何配置库存预警？
A: 修改 `config_extra` 表中的 `stock_alert_threshold` 配置项。

### Q: 如何自定义标签关键词？
A: 修改 `App\Service\TicketService` 中的 `$tagKeywords` 属性。

## 后续开发建议

1. 实现完整的后台管理界面
2. 实现前台用户界面
3. 添加单元测试
4. 优化性能和稳定性
5. 添加更多支付方式
6. 实现数据大屏可视化
7. 完善推广海报生成功能
8. 添加更多抽奖奖品类型

## 技术支持

如有问题，请提交Issue或联系开发团队。

---

**文档版本**: v1.0  
**最后更新**: 2026-06-07
