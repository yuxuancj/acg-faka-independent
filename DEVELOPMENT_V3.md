# ACG-Faka 独立版 v3.0 - 晨泽发卡功能扩展

## 📦 版本信息

- **当前版本**: v3.0-chenze-full
- **更新日期**: 2026-06-07
- **基于版本**: v2.0-chenze-full
- **仓库地址**: https://github.com/yuxuancj/acg-faka-independent

---

## ✨ 新增功能总览

### 一、支付与资金增强

| 功能 | 状态 | 说明 |
|------|------|------|
| 余额支付（完整版） | ✅ | 用户充值、余额消费、退款到余额 |
| 自动退款策略 | ✅ | 配置时间内可自助申请退款 |

### 二、商品与卡密高级功能

| 功能 | 状态 | 说明 |
|------|------|------|
| 卡密预选/靓号加价 | ✅ | 用户可选择心仪卡密，支付额外费用 |
| 多样化核销策略 | ✅ | 单次/有效期/设备绑定/IP绑定/次数限制 |
| 自定义卡密生成规则 | ✅ | 配置前缀、长度、字符集、分隔符、校验位 |
| 卡密导出加密 | ✅ | ZIP密码保护导出 |
| 商品套餐/组合购买 | ✅ | 打包销售、优惠结算 |

### 三、用户与会员增强

| 功能 | 状态 | 说明 |
|------|------|------|
| VIP会员卡系统 | ✅ | 月卡/季卡/年卡、商品折扣、积分倍率 |
| 订阅服务 | ✅ | 月付/季付/年付、周期自动扣费 |
| 用户注销与数据导出 | ✅ | GDPR合规、数据导出 |

### 四、营销与推广

| 功能 | 状态 | 说明 |
|------|------|------|
| 积分抽奖完善 | ✅ | 奖品池、每日次数限制 |

### 五、运维与扩展

| 功能 | 状态 | 说明 |
|------|------|------|
| Webhook事件订阅 | ✅ | 订单支付、用户注册等事件通知 |
| Redis缓存支持 | ✅ | 配置Redis作为缓存驱动 |
| 慢查询监控 | ✅ | SQL执行时间记录 |
| IP黑名单自动封禁 | ✅ | 异常IP自动封禁 |

### 六、易用性与体验

| 功能 | 状态 | 说明 |
|------|------|------|
| 手机短信验证码登录 | ✅ | 阿里云/腾讯云短信集成 |
| 多端模板切换 | ✅ | 多套前台模板支持 |
| 数据备份远程存储 | ✅ | SFTP/OSS/COS远程备份 |

---

## 🗄️ 数据库结构

### 新增表（20个）

#### 1. user_balance_log - 用户余额变动记录
```sql
- id: 主键
- user_id: 用户ID
- type: 类型（1=充值,2=消费,3=退款,4=管理员调整）
- amount: 变动金额
- balance_before: 变动前余额
- balance_after: 变动后余额
- description: 说明
- order_id: 关联订单ID
- create_time: 创建时间
```

#### 2. vip_card - VIP会员卡
```sql
- id: 主键
- name: 会员卡名称
- price: 价格
- days: 有效期天数
- discount: 商品折扣率
- points_multiplier: 积分倍率
- free_shipping: 是否免运费
- icon: 图标
- description: 特权说明
- sort: 排序
- status: 状态
- create_time: 创建时间
```

#### 3. user_vip - 用户VIP记录
```sql
- id: 主键
- user_id: 用户ID
- vip_card_id: 会员卡ID
- order_id: 订单ID
- start_time: 开始时间
- end_time: 结束时间
- status: 状态
- create_time: 创建时间
```

#### 4. subscription - 订阅服务
```sql
- id: 主键
- user_id: 用户ID
- commodity_id: 商品ID
- cycle_type: 周期类型（1=月付,2=季付,3=年付）
- price: 每次扣费金额
- next_pay_time: 下次扣费时间
- status: 状态
- last_pay_time: 最后扣费时间
- create_time: 创建时间
```

#### 5. card_verify_strategy - 卡密核销策略
```sql
- id: 主键
- name: 策略名称
- type: 核销类型（1=单次,2=有效期,3=设备绑定,4=IP绑定,5=次数限制）
- param_days: 有效期天数
- param_times: 最大使用次数
- status: 状态
- create_time: 创建时间
```

#### 6. card_use_log - 卡密使用记录
```sql
- id: 主键
- card_id: 卡密ID
- user_id: 使用用户ID
- order_id: 订单ID
- device_id: 设备ID
- ip: IP地址
- use_time: 使用时间
- content: 核销内容
```

#### 7. fancy_card - 靓号卡密
```sql
- id: 主键
- commodity_id: 商品ID
- card_no: 卡号
- extra_price: 额外价格
- status: 状态（0=待售,1=已售,2=锁定）
- create_time: 创建时间
```

#### 8. card_gen_rule - 卡密生成规则
```sql
- id: 主键
- commodity_id: 商品ID
- prefix: 前缀
- date_format: 日期格式
- length: 随机字符串长度
- charset: 字符集
- separator: 分隔符
- separator_interval: 分隔符间隔
- has_checkcode: 是否有校验位
- quantity: 生成数量
- create_time: 创建时间
```

#### 9. package - 商品套餐
```sql
- id: 主键
- name: 套餐名称
- price: 套餐价格
- original_price: 原价
- description: 套餐说明
- cover: 封面图
- status: 状态
- sort: 排序
- create_time: 创建时间
```

#### 10. package_item - 套餐商品关联
```sql
- id: 主键
- package_id: 套餐ID
- commodity_id: 商品ID
- quantity: 数量
- create_time: 创建时间
```

#### 11. refund - 退款记录
```sql
- id: 主键
- order_id: 订单ID
- user_id: 用户ID
- amount: 退款金额
- reason: 退款原因
- type: 退款方式（1=原路返回,2=退余额）
- status: 状态
- admin_id: 处理管理员ID
- admin_remark: 管理员备注
- create_time: 申请时间
- handle_time: 处理时间
```

#### 12. webhook - Webhook配置
```sql
- id: 主键
- name: 名称
- url: 回调URL
- secret: 密钥
- events: 订阅事件
- status: 状态
- retry_times: 重试次数
- create_time: 创建时间
```

#### 13. webhook_log - Webhook日志
```sql
- id: 主键
- webhook_id: Webhook ID
- event: 事件类型
- payload: 发送数据
- response: 响应内容
- status: 状态
- retry_count: 重试次数
- error_msg: 错误信息
- create_time: 创建时间
- send_time: 发送时间
```

#### 14. ip_blacklist - IP黑名单
```sql
- id: 主键
- ip: IP地址
- reason: 封禁原因
- expire_time: 过期时间
- type: 类型（1=自动,2=手动）
- admin_id: 操作管理员ID
- create_time: 创建时间
```

#### 15. sms_config - 短信配置
```sql
- id: 主键
- type: 类型（aliyun/qcloud）
- access_key: AccessKey
- access_secret: AccessSecret
- sign_name: 签名
- template_code: 模板CODE
- status: 状态
- update_time: 更新时间
```

#### 16. sms_log - 短信发送记录
```sql
- id: 主键
- phone: 手机号
- code: 验证码
- type: 用途
- ip: IP地址
- expire_time: 过期时间
- status: 状态
- create_time: 创建时间
```

#### 17. system_config - 系统配置
```sql
- id: 主键
- group: 分组
- key: 键
- value: 值
- type: 类型
- title: 标题
- description: 说明
- sort: 排序
```

#### 18. slow_query_log - 慢查询日志
```sql
- id: 主键
- sql: SQL语句
- execute_time: 执行时间
- trace: 调用栈
- create_time: 创建时间
```

#### 19. user_cancel - 用户注销记录
```sql
- id: 主键
- user_id: 用户ID
- email: 邮箱
- reason: 注销原因
- data_export_path: 数据导出文件路径
- status: 状态
- admin_id: 处理管理员ID
- create_time: 申请时间
- handle_time: 处理时间
```

#### 20. backup_remote - 远程备份配置
```sql
- id: 主键
- type: 类型（sftp/oss/cos）
- host: 主机
- port: 端口
- username: 用户名
- password: 密码
- bucket: Bucket
- region: 区域
- path: 路径
- access_key: AccessKey
- access_secret: AccessSecret
- status: 状态
- update_time: 更新时间
```

### 修改的表

#### user - 用户表新增字段
- phone: 手机号
- phone_verified: 手机号已验证
- vip_expire_time: VIP过期时间
- auto_refund_minutes: 自动退款时间
- data_export_token: 数据导出Token
- cancel_time: 注销时间
- cancel_status: 注销状态

#### commodity - 商品表新增字段
- verify_strategy_id: 核销策略ID
- package_id: 所属套餐ID
- is_subscription: 是否订阅商品
- subscription_cycle: 订阅周期
- subscription_price: 订阅价格
- allow_fancy: 允许靓号选择
- fancy_extra_rate: 靓号加价比例

#### card - 卡密表新增字段
- verify_strategy_id: 核销策略ID
- expire_days: 有效期天数
- max_uses: 最大使用次数
- current_uses: 当前使用次数
- activated_time: 激活时间
- device_id: 绑定设备ID
- is_fancy: 是否靓号

#### order - 订单表新增字段
- use_balance: 使用余额
- refund_id: 退款记录ID
- auto_refund_deadline: 自动退款截止时间
- is_refunded: 是否已退款
- vip_card_id: 购买VIP卡ID
- subscription_id: 订阅ID

---

## 📚 核心服务类

### BalanceService - 余额服务
```php
use App\Service\BalanceService;

$service = new BalanceService();

// 获取余额
$balance = $service->getBalance($userId);

// 增加余额
$service->increase($userId, 100, '充值');

// 余额支付
$result = $service->pay($userId, 50, $orderId);

// 退款到余额
$service->refund($userId, 100, $orderId);

// 管理员调整
$service->adjust($userId, -50, '错误扣除');
```

### VipService - VIP会员服务
```php
use App\Service\VipService;

$service = new VipService();

// 检查VIP状态
$check = $service->check($userId);

// 获取折扣
$discount = $service->getDiscount($userId);

// 购买VIP
$result = $service->buy($userId, $vipCardId, $orderId);
```

### CardVerifyService - 卡密核销服务
```php
use App\Service\CardVerifyService;

$service = new CardVerifyService();

// 验证卡密
$verify = $service->verify($card, $userId, $deviceId, $ip);

// 使用卡密
$result = $service->use($card, $userId, $deviceId, $ip, $content);
```

### CardGeneratorService - 卡密生成服务
```php
use App\Service\CardGeneratorService;

$service = new CardGeneratorService();

// 生成卡密
$cards = $service->generate(
    $commodityId,
    100,                    // 数量
    'VIP-',                 // 前缀
    'Ymd',                  // 日期格式
    16,                     // 长度
    'alnum',                // 字符集
    '-',                    // 分隔符
    4,                      // 分隔符间隔
    true                    // 有校验位
);

// 导出ZIP
$zipFile = $service->exportToZip($cardIds, 'password123');
```

### IpSecurityService - IP安全服务
```php
use App\Service\IpSecurityService;

// 检查IP是否封禁
if (IpSecurityService::isBlocked($ip)) {
    exit('IP已被封禁');
}

// 记录错误（达到阈值自动封禁）
IpSecurityService::recordError($ip, 'login_failed');

// 手动封禁
IpSecurityService::block($ip, '违规操作', 1440);

// 解封
IpSecurityService::unblock($ip);
```

---

## ⚙️ 系统配置

### 配置获取/设置
```php
use App\Model\SystemConfig;

// 获取配置
$enabled = SystemConfig::getValue('auto_refund_enabled', 'refund', 1);

// 设置配置
SystemConfig::setValue('auto_refund_minutes', 30, 'refund');

// 获取分组配置
$configs = SystemConfig::getGroup('refund');
```

### 配置文件
| 配置项 | 分组 | 类型 | 说明 |
|--------|------|------|------|
| auto_refund_enabled | refund | switch | 启用自动退款 |
| auto_refund_minutes | refund | number | 自动退款时间(分钟) |
| refund_to_balance | refund | switch | 退款退至余额 |
| fancy_enabled | fancy | switch | 启用靓号功能 |
| fancy_show_last | fancy | number | 靓号预览位数 |
| ip_block_enabled | security | switch | 启用IP自动封禁 |
| ip_block_threshold | security | number | 封禁阈值 |
| ip_block_minutes | security | number | 自动封禁时间 |
| slow_query_enabled | system | switch | 启用慢查询日志 |
| slow_query_threshold | system | number | 慢查询阈值 |
| cache_driver | cache | select | 缓存驱动 |
| redis_host | cache | text | Redis主机 |
| redis_port | cache | number | Redis端口 |
| redis_password | cache | text | Redis密码 |
| queue_driver | queue | select | 队列驱动 |

---

## 🚀 数据库迁移

### 执行迁移
1. 备份现有数据库
2. 导入迁移脚本：
```bash
mysql -u username -p database_name < kernel/Install/Migration_v3.0.sql
```

### 或使用命令行
```bash
php kernel/Console.php migrate
```

---

## 📝 更新日志

### v3.0-chenze-full (2026-06-07)

#### 新增功能
- ✅ 余额支付完整版
- ✅ 自动退款策略
- ✅ VIP会员卡系统
- ✅ 订阅服务
- ✅ 卡密核销策略
- ✅ 靓号卡密
- ✅ 卡密生成规则
- ✅ 商品套餐
- ✅ Webhook事件订阅
- ✅ IP黑名单自动封禁
- ✅ Redis缓存支持
- ✅ 慢查询监控
- ✅ 短信验证码登录
- ✅ 用户注销与数据导出
- ✅ 远程备份存储

#### 数据库变更
- ✅ 新增20个数据表
- ✅ 修改4个现有表

---

## 📄 许可证

本项目基于 ACG-Faka 开源版本二次开发。

---

**项目地址**: https://github.com/yuxuancj/acg-faka-independent
**最新版本**: v3.0-chenze-full
**最后更新**: 2026-06-07
