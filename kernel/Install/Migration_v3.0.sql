-- ============================================================
-- ACG-Faka 独立版 v3.0 - 数据库迁移脚本
-- 晨泽发卡剩余核心功能集成
-- 日期: 2026-06-07
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 用户余额表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__user_balance_log`;
CREATE TABLE `__PREFIX__user_balance_log` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` int(11) UNSIGNED NOT NULL COMMENT '用户ID',
    `type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '类型：1=充值，2=消费，3=退款，4=管理员调整',
    `amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '变动金额',
    `balance_before` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '变动前余额',
    `balance_after` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '变动后余额',
    `description` varchar(255) NULL COMMENT '说明',
    `order_id` int(11) UNSIGNED NULL COMMENT '关联订单ID',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户余额变动记录';

-- ----------------------------
-- 2. VIP会员卡表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__vip_card`;
CREATE TABLE `__PREFIX__vip_card` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` varchar(50) NOT NULL COMMENT '会员卡名称',
    `price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '价格',
    `days` int(11) NOT NULL DEFAULT 30 COMMENT '有效期天数',
    `discount` decimal(3,2) NOT NULL DEFAULT '1.00' COMMENT '商品折扣率',
    `points_multiplier` decimal(3,2) NOT NULL DEFAULT '1.00' COMMENT '积分倍率',
    `free_shipping` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否免运费：0=否，1=是',
    `icon` varchar(255) NULL COMMENT '图标',
    `description` text NULL COMMENT '特权说明',
    `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=启用',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='VIP会员卡';

-- ----------------------------
-- 3. 用户VIP记录表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__user_vip`;
CREATE TABLE `__PREFIX__user_vip` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` int(11) UNSIGNED NOT NULL COMMENT '用户ID',
    `vip_card_id` int(11) UNSIGNED NOT NULL COMMENT '会员卡ID',
    `order_id` int(11) UNSIGNED NULL COMMENT '订单ID',
    `start_time` datetime NOT NULL COMMENT '开始时间',
    `end_time` datetime NOT NULL COMMENT '结束时间',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=过期，1=有效',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_end_time` (`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户VIP记录';

-- ----------------------------
-- 4. 订阅服务表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__subscription`;
CREATE TABLE `__PREFIX__subscription` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` int(11) UNSIGNED NOT NULL COMMENT '用户ID',
    `commodity_id` int(11) UNSIGNED NOT NULL COMMENT '商品ID',
    `cycle_type` tinyint(1) NOT NULL COMMENT '周期类型：1=月付，2=季付，3=年付',
    `price` decimal(10,2) NOT NULL COMMENT '每次扣费金额',
    `next_pay_time` datetime NOT NULL COMMENT '下次扣费时间',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=暂停，1=正常',
    `last_pay_time` datetime NULL COMMENT '最后扣费时间',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_next_pay_time` (`next_pay_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订阅服务';

-- ----------------------------
-- 5. 卡密核销策略表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__card_verify_strategy`;
CREATE TABLE `__PREFIX__card_verify_strategy` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` varchar(50) NOT NULL COMMENT '策略名称',
    `type` tinyint(1) NOT NULL COMMENT '核销类型：1=单次，2=有效期，3=设备绑定，4=IP绑定，5=次数限制',
    `param_days` int(11) NULL COMMENT '有效期天数（类型2）',
    `param_times` int(11) NULL COMMENT '最大使用次数（类型5）',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=启用',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡密核销策略';

-- ----------------------------
-- 6. 卡密使用记录表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__card_use_log`;
CREATE TABLE `__PREFIX__card_use_log` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `card_id` int(11) UNSIGNED NOT NULL COMMENT '卡密ID',
    `user_id` int(11) UNSIGNED NULL COMMENT '使用用户ID',
    `order_id` int(11) UNSIGNED NULL COMMENT '订单ID',
    `device_id` varchar(128) NULL COMMENT '设备ID',
    `ip` varchar(45) NULL COMMENT 'IP地址',
    `use_time` datetime NOT NULL COMMENT '使用时间',
    `content` text NULL COMMENT '核销内容/授权信息',
    PRIMARY KEY (`id`),
    INDEX `idx_card_id` (`card_id`),
    INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡密使用记录';

-- ----------------------------
-- 7. 靓号卡密表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__fancy_card`;
CREATE TABLE `__PREFIX__fancy_card` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `commodity_id` int(11) UNSIGNED NOT NULL COMMENT '商品ID',
    `card_no` varchar(128) NOT NULL COMMENT '卡号',
    `extra_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '额外价格',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=待售，1=已售，2=锁定',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_card_no` (`card_no`),
    INDEX `idx_commodity_id` (`commodity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='靓号卡密';

-- ----------------------------
-- 8. 卡密生成规则表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__card_gen_rule`;
CREATE TABLE `__PREFIX__card_gen_rule` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `commodity_id` int(11) UNSIGNED NOT NULL COMMENT '商品ID',
    `prefix` varchar(20) NULL COMMENT '卡密前缀',
    `date_format` varchar(20) NULL COMMENT '日期格式',
    `length` int(11) NOT NULL DEFAULT 16 COMMENT '随机字符串长度',
    `charset` varchar(50) NOT NULL DEFAULT 'alnum' COMMENT '字符集：num=纯数字，alpha=纯字母，alnum=混合',
    `separator` varchar(10) NULL COMMENT '分隔符',
    `separator_interval` int(11) NOT NULL DEFAULT 4 COMMENT '分隔符间隔',
    `has_checkcode` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否有校验位：0=无，1=有',
    `quantity` int(11) NOT NULL DEFAULT 10 COMMENT '生成数量',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_commodity_id` (`commodity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='卡密生成规则';

-- ----------------------------
-- 9. 商品套餐表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__package`;
CREATE TABLE `__PREFIX__package` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` varchar(100) NOT NULL COMMENT '套餐名称',
    `price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '套餐价格',
    `original_price` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '原价',
    `description` text NULL COMMENT '套餐说明',
    `cover` varchar(255) NULL COMMENT '封面图',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=下架，1=上架',
    `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品套餐';

-- ----------------------------
-- 10. 套餐商品关联表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__package_item`;
CREATE TABLE `__PREFIX__package_item` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `package_id` int(11) UNSIGNED NOT NULL COMMENT '套餐ID',
    `commodity_id` int(11) UNSIGNED NOT NULL COMMENT '商品ID',
    `quantity` int(11) NOT NULL DEFAULT 1 COMMENT '数量',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_package_id` (`package_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='套餐商品关联';

-- ----------------------------
-- 11. 退款记录表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__refund`;
CREATE TABLE `__PREFIX__refund` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `order_id` int(11) UNSIGNED NOT NULL COMMENT '订单ID',
    `user_id` int(11) UNSIGNED NOT NULL COMMENT '用户ID',
    `amount` decimal(10,2) NOT NULL COMMENT '退款金额',
    `reason` varchar(255) NULL COMMENT '退款原因',
    `type` tinyint(1) NOT NULL COMMENT '退款方式：1=原路返回，2=退余额',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=待处理，1=已退款，2=已拒绝',
    `admin_id` int(11) UNSIGNED NULL COMMENT '处理管理员ID',
    `admin_remark` varchar(255) NULL COMMENT '管理员备注',
    `create_time` datetime NOT NULL COMMENT '申请时间',
    `handle_time` datetime NULL COMMENT '处理时间',
    PRIMARY KEY (`id`),
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款记录';

-- ----------------------------
-- 12. Webhook配置表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__webhook`;
CREATE TABLE `__PREFIX__webhook` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` varchar(100) NOT NULL COMMENT '名称',
    `url` varchar(255) NOT NULL COMMENT '回调URL',
    `secret` varchar(64) NULL COMMENT '密钥',
    `events` varchar(255) NOT NULL COMMENT '订阅事件，多个用逗号分隔',
    `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '状态：0=禁用，1=启用',
    `retry_times` tinyint(1) NOT NULL DEFAULT 3 COMMENT '重试次数',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Webhook配置';

-- ----------------------------
-- 13. Webhook日志表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__webhook_log`;
CREATE TABLE `__PREFIX__webhook_log` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `webhook_id` int(11) UNSIGNED NOT NULL COMMENT 'Webhook ID',
    `event` varchar(50) NOT NULL COMMENT '事件类型',
    `payload` text NOT NULL COMMENT '发送数据',
    `response` text NULL COMMENT '响应内容',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=待发送，1=成功，2=失败',
    `retry_count` tinyint(1) NOT NULL DEFAULT 0 COMMENT '重试次数',
    `error_msg` varchar(255) NULL COMMENT '错误信息',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    `send_time` datetime NULL COMMENT '发送时间',
    PRIMARY KEY (`id`),
    INDEX `idx_webhook_id` (`webhook_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Webhook日志';

-- ----------------------------
-- 14. IP黑名单表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__ip_blacklist`;
CREATE TABLE `__PREFIX__ip_blacklist` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `ip` varchar(45) NOT NULL COMMENT 'IP地址',
    `reason` varchar(255) NULL COMMENT '封禁原因',
    `expire_time` datetime NULL COMMENT '过期时间，为空则永久',
    `type` tinyint(1) NOT NULL DEFAULT 1 COMMENT '类型：1=自动，2=手动',
    `admin_id` int(11) UNSIGNED NULL COMMENT '操作管理员ID',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='IP黑名单';

-- ----------------------------
-- 15. 短信配置表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__sms_config`;
CREATE TABLE `__PREFIX__sms_config` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `type` varchar(20) NOT NULL COMMENT '类型：aliyun=阿里云，qcloud=腾讯云',
    `access_key` varchar(100) NOT NULL COMMENT 'AccessKey',
    `access_secret` varchar(100) NOT NULL COMMENT 'AccessSecret',
    `sign_name` varchar(50) NOT NULL COMMENT '签名',
    `template_code` varchar(50) NOT NULL COMMENT '模板CODE',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=禁用，1=启用',
    `update_time` datetime NOT NULL COMMENT '更新时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='短信配置';

-- ----------------------------
-- 16. 短信发送记录表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__sms_log`;
CREATE TABLE `__PREFIX__sms_log` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `phone` varchar(20) NOT NULL COMMENT '手机号',
    `code` varchar(10) NOT NULL COMMENT '验证码',
    `type` varchar(20) NOT NULL COMMENT '用途：login=登录，register=注册，bind=绑定',
    `ip` varchar(45) NOT NULL COMMENT 'IP地址',
    `expire_time` datetime NOT NULL COMMENT '过期时间',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=未验证，1=已验证，2=已过期',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_phone` (`phone`),
    INDEX `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='短信发送记录';

-- ----------------------------
-- 17. 系统配置表（扩展）
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__system_config`;
CREATE TABLE `__PREFIX__system_config` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `group` varchar(50) NOT NULL COMMENT '分组',
    `key` varchar(100) NOT NULL COMMENT '键',
    `value` text NULL COMMENT '值',
    `type` varchar(20) NOT NULL DEFAULT 'text' COMMENT '类型：text=文本，number=数字，switch=开关，textarea=多行文本',
    `title` varchar(100) NOT NULL COMMENT '标题',
    `description` varchar(255) NULL COMMENT '说明',
    `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_group_key` (`group`, `key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置';

-- ----------------------------
-- 18. 慢查询日志表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__slow_query_log`;
CREATE TABLE `__PREFIX__slow_query_log` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `sql` text NOT NULL COMMENT 'SQL语句',
    `execute_time` decimal(10,3) NOT NULL COMMENT '执行时间(秒)',
    `trace` text NULL COMMENT '调用栈',
    `create_time` datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='慢查询日志';

-- ----------------------------
-- 19. 用户注销记录表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__user_cancel`;
CREATE TABLE `__PREFIX__user_cancel` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id` int(11) UNSIGNED NOT NULL COMMENT '用户ID',
    `email` varchar(64) NOT NULL COMMENT '邮箱',
    `reason` varchar(255) NULL COMMENT '注销原因',
    `data_export_path` varchar(255) NULL COMMENT '数据导出文件路径',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=待处理，1=已导出，2=已删除',
    `admin_id` int(11) UNSIGNED NULL COMMENT '处理管理员ID',
    `create_time` datetime NOT NULL COMMENT '申请时间',
    `handle_time` datetime NULL COMMENT '处理时间',
    PRIMARY KEY (`id`),
    INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户注销记录';

-- ----------------------------
-- 20. 远程备份配置表
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__backup_remote`;
CREATE TABLE `__PREFIX__backup_remote` (
    `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `type` varchar(20) NOT NULL COMMENT '类型：sftp=SFTP，oss=阿里云OSS，cos=腾讯云COS',
    `host` varchar(255) NULL COMMENT '主机',
    `port` int(11) NULL DEFAULT 22 COMMENT '端口',
    `username` varchar(100) NULL COMMENT '用户名',
    `password` varchar(255) NULL COMMENT '密码',
    `bucket` varchar(100) NULL COMMENT 'Bucket',
    `region` varchar(50) NULL COMMENT '区域',
    `path` varchar(255) NULL COMMENT '路径',
    `access_key` varchar(100) NULL COMMENT 'AccessKey',
    `access_secret` varchar(100) NULL COMMENT 'AccessSecret',
    `status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '状态：0=禁用，1=启用',
    `update_time` datetime NOT NULL COMMENT '更新时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='远程备份配置';

-- ----------------------------
-- 修改现有表
-- ----------------------------

-- 修改商品表，添加新字段
ALTER TABLE `__PREFIX__commodity` 
ADD COLUMN `verify_strategy_id` int(11) UNSIGNED NULL COMMENT '核销策略ID' AFTER `confine_ip`,
ADD COLUMN `package_id` int(11) UNSIGNED NULL COMMENT '所属套餐ID' AFTER `verify_strategy_id`,
ADD COLUMN `is_subscription` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否订阅商品：0=否，1=是' AFTER `package_id`,
ADD COLUMN `subscription_cycle` tinyint(1) NULL COMMENT '订阅周期：1=月付，2=季付，3=年付' AFTER `is_subscription`,
ADD COLUMN `subscription_price` decimal(10,2) NULL COMMENT '订阅价格' AFTER `subscription_cycle`,
ADD COLUMN `allow_fancy` tinyint(1) NOT NULL DEFAULT 0 COMMENT '允许靓号选择：0=否，1=是' AFTER `subscription_price`,
ADD COLUMN `fancy_extra_rate` decimal(5,2) NOT NULL DEFAULT 0 COMMENT '靓号加价比例(%)' AFTER `allow_fancy`;

-- 修改用户表，添加新字段
ALTER TABLE `__PREFIX__user` 
ADD COLUMN `phone` varchar(20) NULL COMMENT '手机号' AFTER `email`,
ADD COLUMN `phone_verified` tinyint(1) NOT NULL DEFAULT 0 COMMENT '手机号已验证：0=否，1=是' AFTER `phone`,
ADD COLUMN `vip_expire_time` datetime NULL COMMENT 'VIP过期时间' AFTER `phone_verified`,
ADD COLUMN `auto_refund_minutes` int(11) NOT NULL DEFAULT 30 COMMENT '自动退款时间(分钟)' AFTER `vip_expire_time`,
ADD COLUMN `data_export_token` varchar(64) NULL COMMENT '数据导出Token' AFTER `auto_refund_minutes`,
ADD COLUMN `cancel_time` datetime NULL COMMENT '注销时间' AFTER `data_export_token`,
ADD COLUMN `cancel_status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '注销状态：0=正常，1=申请中，2=已注销' AFTER `cancel_time`;

-- 修改卡密表，添加新字段
ALTER TABLE `__PREFIX__card` 
ADD COLUMN `verify_strategy_id` int(11) UNSIGNED NULL COMMENT '核销策略ID' AFTER `status`,
ADD COLUMN `expire_days` int(11) NULL COMMENT '有效期天数（从激活开始）' AFTER `verify_strategy_id`,
ADD COLUMN `max_uses` int(11) NULL COMMENT '最大使用次数' AFTER `expire_days`,
ADD COLUMN `current_uses` int(11) NOT NULL DEFAULT 0 COMMENT '当前使用次数' AFTER `max_uses`,
ADD COLUMN `activated_time` datetime NULL COMMENT '激活时间' AFTER `current_uses`,
ADD COLUMN `device_id` varchar(128) NULL COMMENT '绑定设备ID' AFTER `activated_time`,
ADD COLUMN `is_fancy` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否靓号：0=否，1=是' AFTER `device_id`;

-- 修改订单表，添加新字段
ALTER TABLE `__PREFIX__order` 
ADD COLUMN `use_balance` decimal(10,2) NOT NULL DEFAULT 0 COMMENT '使用余额' AFTER `real_price`,
ADD COLUMN `refund_id` int(11) UNSIGNED NULL COMMENT '退款记录ID' AFTER `use_balance`,
ADD COLUMN `auto_refund_deadline` datetime NULL COMMENT '自动退款截止时间' AFTER `refund_id`,
ADD COLUMN `is_refunded` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否已退款：0=否，1=是' AFTER `auto_refund_deadline`,
ADD COLUMN `vip_card_id` int(11) UNSIGNED NULL COMMENT '购买VIP卡ID' AFTER `is_refunded`,
ADD COLUMN `subscription_id` int(11) UNSIGNED NULL COMMENT '订阅ID' AFTER `vip_card_id`;

-- 创建索引
CREATE INDEX idx_user_vip_expire ON `__PREFIX__user`(`vip_expire_time`);
CREATE INDEX idx_order_auto_refund ON `__PREFIX__order`(`auto_refund_deadline`);
CREATE INDEX idx_card_expire ON `__PREFIX__card`(`expire_days`);

-- ----------------------------
-- 初始化系统配置
-- ----------------------------
INSERT INTO `__PREFIX__system_config` (`group`, `key`, `value`, `type`, `title`, `description`, `sort`) VALUES
-- 退款配置
('refund', 'auto_refund_enabled', '1', 'switch', '启用自动退款', '开启后用户在规定时间内可自助申请退款', 1),
('refund', 'auto_refund_minutes', '30', 'number', '自动退款时间', '订单完成后多少分钟内可申请退款（分钟）', 2),
('refund', 'refund_to_balance', '1', 'switch', '退款退至余额', '开启后退款金额将退至用户余额，否则原路返回', 3),

-- 靓号配置
('fancy', 'fancy_enabled', '1', 'switch', '启用靓号功能', '开启后用户可选择心仪的卡密号', 1),
('fancy', 'fancy_show_last', '4', 'number', '靓号预览位数', '卡密预览时显示后几位', 2),

-- IP黑名单配置
('security', 'ip_block_enabled', '1', 'switch', '启用IP自动封禁', '开启后异常IP自动加入黑名单', 1),
('security', 'ip_block_threshold', '5', 'number', '封禁阈值', '触发多少次异常后封禁', 2),
('security', 'ip_block_minutes', '1440', 'number', '自动封禁时间', '自动封禁持续时间（分钟），0=永久', 3),

-- 慢查询配置
('system', 'slow_query_enabled', '1', 'switch', '启用慢查询日志', '记录执行时间过长的SQL', 1),
('system', 'slow_query_threshold', '0.5', 'number', '慢查询阈值', '超过多少秒记录（秒）', 2),

-- 缓存配置
('cache', 'cache_driver', 'file', 'select', '缓存驱动', '缓存方式：file=文件，redis=Redis', 1),
('cache', 'redis_host', '127.0.0.1', 'text', 'Redis主机', 'Redis服务器地址', 2),
('cache', 'redis_port', '6379', 'number', 'Redis端口', 'Redis服务端口', 3),
('cache', 'redis_password', '', 'text', 'Redis密码', 'Redis访问密码', 4),
('cache', 'redis_database', '0', 'number', 'Redis数据库', 'Redis数据库编号', 5),

-- 队列配置
('queue', 'queue_driver', 'sync', 'select', '队列驱动', '队列方式：sync=同步，redis=Redis', 1),

-- Webhook配置
('webhook', 'webhook_enabled', '1', 'switch', '启用Webhook', '开启后发送事件通知', 1);

SET FOREIGN_KEY_CHECKS = 1;
