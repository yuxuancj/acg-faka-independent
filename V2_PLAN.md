# ACG-Faka v2.0 晨泽完整功能集成计划

## 📋 总览

基于ACG-Faka独立版v1.0，集成晨泽发卡系统的完整核心功能。

---

## 🗄️ 数据库结构设计 (v2.0 Migration)

### 用户相关表

**用户等级表 (`user_level`)**
```sql
CREATE TABLE `__PREFIX__user_level` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '等级名称',
  `icon` varchar(255) DEFAULT NULL COMMENT '等级图标',
  `min_points` int(11) NOT NULL DEFAULT '0' COMMENT '最低成长值',
  `discount` decimal(3,2) NOT NULL DEFAULT '1.00' COMMENT '折扣率',
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**用户积分记录表 (`user_points_log`)**
```sql
CREATE TABLE `__PREFIX__user_points_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` tinyint(1) NOT NULL COMMENT '1=获得,2=消费',
  `points` int(11) NOT NULL,
  `balance` int(11) NOT NULL COMMENT '变动后余额',
  `remark` varchar(255) DEFAULT NULL,
  `related_id` int(11) DEFAULT NULL,
  `related_type` varchar(50) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**签到记录表 (`user_checkin`)**
```sql
CREATE TABLE `__PREFIX__user_checkin` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `checkin_date` date NOT NULL,
  `continuous_days` int(11) NOT NULL DEFAULT '1',
  `points_reward` int(11) NOT NULL DEFAULT '0',
  `extra_reward` text,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`checkin_date`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 促销相关表

**优惠券表 (`coupon`)**
```sql
CREATE TABLE `__PREFIX__coupon` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '优惠券名称',
  `type` tinyint(1) NOT NULL COMMENT '1=满减,2=折扣,3=无门槛',
  `value` decimal(10,2) NOT NULL COMMENT '优惠金额/折扣率',
  `min_amount` decimal(10,2) DEFAULT '0.00' COMMENT '最低使用金额',
  `total_num` int(11) NOT NULL DEFAULT '0' COMMENT '总发放数量',
  `used_num` int(11) NOT NULL DEFAULT '0' COMMENT '已使用数量',
  `per_user_limit` int(11) DEFAULT '1' COMMENT '每人限领',
  `product_ids` text COMMENT '适用商品ID，逗号分隔',
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `valid_days` int(11) DEFAULT NULL COMMENT '领取后有效天数',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**用户优惠券表 (`user_coupon`)**
```sql
CREATE TABLE `__PREFIX__user_coupon` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `coupon_id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL COMMENT '兑换码',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0=未使用,1=已使用,2=已过期',
  `use_time` datetime DEFAULT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `get_time` datetime NOT NULL,
  `expire_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_coupon_id` (`coupon_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**秒杀活动表 (`flash_sale`)**
```sql
CREATE TABLE `__PREFIX__flash_sale` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL COMMENT '秒杀价格',
  `stock` int(11) NOT NULL DEFAULT '0' COMMENT '秒杀库存',
  `sold` int(11) NOT NULL DEFAULT '0',
  `per_user_limit` int(11) DEFAULT '1' COMMENT '每人限购',
  `warmup_minutes` int(11) DEFAULT '0' COMMENT '预热分钟数',
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**批发折扣表 (`wholesale_discount`)**
```sql
CREATE TABLE `__PREFIX__wholesale_discount` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `min_qty` int(11) NOT NULL,
  `max_qty` int(11) DEFAULT NULL,
  `discount` decimal(3,2) NOT NULL COMMENT '折扣率',
  `sort` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**积分抽奖表 (`lottery`)**
```sql
CREATE TABLE `__PREFIX__lottery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '奖品名称',
  `type` tinyint(1) NOT NULL COMMENT '1=积分,2=优惠券,3=卡密',
  `points_cost` int(11) NOT NULL DEFAULT '10' COMMENT '消耗积分',
  `prize_value` varchar(255) DEFAULT NULL COMMENT '奖品值',
  `probability` decimal(5,4) NOT NULL COMMENT '中奖概率',
  `stock` int(11) DEFAULT '-1' COMMENT '库存，-1无限',
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**抽奖记录表 (`lottery_log`)**
```sql
CREATE TABLE `__PREFIX__lottery_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `lottery_id` int(11) NOT NULL,
  `prize_type` tinyint(1) NOT NULL,
  `prize_value` varchar(255) DEFAULT NULL,
  `points_cost` int(11) NOT NULL,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 分销相关表

**推广海报模板表 (`poster_template`)**
```sql
CREATE TABLE `__PREFIX__poster_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `bg_image` varchar(255) NOT NULL,
  `qr_position` varchar(50) NOT NULL DEFAULT 'bottom' COMMENT '二维码位置',
  `qr_size` int(11) NOT NULL DEFAULT '150',
  `text_color` varchar(20) DEFAULT '#333333',
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**提现申请表 (`withdraw`)**
```sql
CREATE TABLE `__PREFIX__withdraw` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `type` tinyint(1) NOT NULL COMMENT '1=支付宝,2=微信,3=银行卡',
  `account` varchar(255) NOT NULL COMMENT '账号',
  `real_name` varchar(100) NOT NULL COMMENT '真实姓名',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0=待审核,1=已通过,2=已拒绝',
  `remark` varchar(255) DEFAULT NULL COMMENT '审核备注',
  `audit_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 工单系统表

**工单表 (`ticket`)**
```sql
CREATE TABLE `__PREFIX__ticket` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `type` tinyint(1) NOT NULL COMMENT '1=卡密补发,2=API授权,3=退款,4=其他',
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `tags` varchar(255) DEFAULT NULL COMMENT '标签，逗号分隔',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0=待处理,1=处理中,2=已解决,3=已关闭',
  `admin_id` int(11) DEFAULT NULL COMMENT '处理管理员',
  `last_reply_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**工单回复表 (`ticket_reply`)**
```sql
CREATE TABLE `__PREFIX__ticket_reply` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) NOT NULL,
  `user_type` tinyint(1) NOT NULL COMMENT '1=用户,2=管理员',
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `attachments` text COMMENT '附件JSON',
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 数据报表相关表

**访问统计记录表 (`stat_visit`)**
```sql
CREATE TABLE `__PREFIX__stat_visit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `page` varchar(100) NOT NULL,
  `uv` int(11) NOT NULL DEFAULT '0',
  `pv` int(11) NOT NULL DEFAULT '0',
  `ip` varchar(50) DEFAULT NULL,
  `utm_source` varchar(100) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_date` (`date`),
  KEY `idx_utm` (`utm_source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 其他功能表

**自定义页面表 (`custom_page`)**
```sql
CREATE TABLE `__PREFIX__custom_page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `slug` varchar(100) NOT NULL COMMENT 'URL别名',
  `content` longtext NOT NULL,
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**友情链接表 (`friend_link`)**
```sql
CREATE TABLE `__PREFIX__friend_link` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `url` varchar(255) NOT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**系统配置扩展表 (`config_extra`)**
```sql
CREATE TABLE `__PREFIX__config_extra` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group` varchar(50) NOT NULL DEFAULT 'general',
  `key` varchar(100) NOT NULL,
  `value` text,
  `type` varchar(20) NOT NULL DEFAULT 'text' COMMENT 'text,number,bool,select,textarea',
  `options` text COMMENT '选项JSON',
  `description` varchar(255) DEFAULT NULL,
  `sort` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 📦 功能模块清单

### ✅ 用户体系增强 (3项)
1. 用户等级与成长值系统
2. 积分系统完整版
3. 每日签到系统

### ✅ 订单与促销 (4项)
4. 订单状态机完善
5. 秒杀活动
6. 批发优惠（阶梯折扣）
7. 优惠券系统

### ✅ 分销与推广 (2项)
8. 推广海报生成
9. 提现管理

### ✅ 售后与工单 (2项)
10. 工单系统
11. 自动标签分类

### ✅ 数据报表 (2项)
12. 数据报表
13. 数据大屏

### ✅ 其他功能 (7项)
14. 演示数据导入
15. 新手引导
16. 批量导入商品
17. 商品专属二维码
18. 库存预警通知
19. 货源API补货
20. 卡密到期提醒
21. 订单导出字段自定义
22. 小程序订阅消息 (预留)
23. 移动端后台
24. 自定义页面
25. 友情链接
26. 隐藏商品

---

## 📝 实现策略

1. **数据库优先**：先创建完整的数据库迁移文件
2. **模型层**：创建所有新增模型
3. **服务层**：实现核心业务逻辑
4. **控制器层**：前后台接口
5. **视图层**：模板文件
6. **配置开关**：每个功能独立开关
