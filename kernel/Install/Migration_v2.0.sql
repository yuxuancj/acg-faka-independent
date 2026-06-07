-- =========================================
-- ACG-Faka v2.0 数据库迁移文件
-- 晨泽发卡核心功能完整集成
-- =========================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =========================================
-- 一、用户体系表
-- =========================================

-- 1. 用户等级表
CREATE TABLE IF NOT EXISTS `__PREFIX__user_level` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '等级名称',
  `icon` varchar(255) DEFAULT NULL COMMENT '等级图标',
  `min_points` int(11) NOT NULL DEFAULT '0' COMMENT '最低成长值',
  `discount` decimal(3,2) NOT NULL DEFAULT '1.00' COMMENT '折扣率',
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_min_points` (`min_points`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户等级表';

-- 插入默认等级
INSERT INTO `__PREFIX__user_level` (`name`, `min_points`, `discount`, `sort`, `status`) VALUES
('普通会员', 0, 1.00, 1, 1),
('白银会员', 1000, 0.98, 2, 1),
('黄金会员', 5000, 0.95, 3, 1),
('铂金会员', 20000, 0.90, 4, 1);

-- 2. 用户积分记录表
CREATE TABLE IF NOT EXISTS `__PREFIX__user_points_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` tinyint(1) NOT NULL COMMENT '1=获得,2=消费',
  `points` int(11) NOT NULL,
  `balance` int(11) NOT NULL COMMENT '变动后余额',
  `remark` varchar(255) DEFAULT NULL,
  `related_id` int(11) DEFAULT NULL,
  `related_type` varchar(50) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户积分记录表';

-- 3. 签到记录表
CREATE TABLE IF NOT EXISTS `__PREFIX__user_checkin` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `checkin_date` date NOT NULL,
  `continuous_days` int(11) NOT NULL DEFAULT '1',
  `points_reward` int(11) NOT NULL DEFAULT '0',
  `extra_reward` text COMMENT '额外奖励JSON',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_date` (`user_id`,`checkin_date`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='签到记录表';

-- 给user表添加成长值和积分字段
ALTER TABLE `__PREFIX__user` 
ADD COLUMN IF NOT EXISTS `growth_points` int(11) NOT NULL DEFAULT '0' COMMENT '成长值' AFTER `balance`,
ADD COLUMN IF NOT EXISTS `points` int(11) NOT NULL DEFAULT '0' COMMENT '积分' AFTER `growth_points`,
ADD COLUMN IF NOT EXISTS `level_id` int(11) DEFAULT '1' COMMENT '等级ID' AFTER `points`,
ADD COLUMN IF NOT EXISTS `is_new_admin` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否首次登录后台' AFTER `level_id`,
ADD KEY IF NOT EXISTS `idx_level_id` (`level_id`);

-- =========================================
-- 二、促销系统表
-- =========================================

-- 4. 优惠券表
CREATE TABLE IF NOT EXISTS `__PREFIX__coupon` (
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
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券表';

-- 5. 用户优惠券表
CREATE TABLE IF NOT EXISTS `__PREFIX__user_coupon` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `coupon_id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL COMMENT '兑换码',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0=未使用,1=已使用,2=已过期',
  `use_time` datetime DEFAULT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `get_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expire_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- 6. 秒杀活动表
CREATE TABLE IF NOT EXISTS `__PREFIX__flash_sale` (
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
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='秒杀活动表';

-- 7. 批发折扣表
CREATE TABLE IF NOT EXISTS `__PREFIX__wholesale_discount` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `min_qty` int(11) NOT NULL,
  `max_qty` int(11) DEFAULT NULL,
  `discount` decimal(3,2) NOT NULL COMMENT '折扣率',
  `sort` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='批发折扣表';

-- 8. 积分抽奖表
CREATE TABLE IF NOT EXISTS `__PREFIX__lottery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '奖品名称',
  `type` tinyint(1) NOT NULL COMMENT '1=积分,2=优惠券,3=卡密',
  `points_cost` int(11) NOT NULL DEFAULT '10' COMMENT '消耗积分',
  `prize_value` varchar(255) DEFAULT NULL COMMENT '奖品值',
  `probability` decimal(5,4) NOT NULL COMMENT '中奖概率',
  `stock` int(11) DEFAULT '-1' COMMENT '库存，-1无限',
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分抽奖表';

-- 9. 抽奖记录表
CREATE TABLE IF NOT EXISTS `__PREFIX__lottery_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `lottery_id` int(11) NOT NULL,
  `prize_type` tinyint(1) NOT NULL,
  `prize_value` varchar(255) DEFAULT NULL,
  `points_cost` int(11) NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='抽奖记录表';

-- =========================================
-- 三、分销与推广表
-- =========================================

-- 10. 推广海报模板表
CREATE TABLE IF NOT EXISTS `__PREFIX__poster_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `bg_image` varchar(255) NOT NULL,
  `qr_position` varchar(50) NOT NULL DEFAULT 'bottom' COMMENT '二维码位置',
  `qr_size` int(11) NOT NULL DEFAULT '150',
  `text_color` varchar(20) DEFAULT '#333333',
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推广海报模板表';

-- 11. 提现申请表
CREATE TABLE IF NOT EXISTS `__PREFIX__withdraw` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `type` tinyint(1) NOT NULL COMMENT '1=支付宝,2=微信,3=银行卡',
  `account` varchar(255) NOT NULL COMMENT '账号',
  `real_name` varchar(100) NOT NULL COMMENT '真实姓名',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0=待审核,1=已通过,2=已拒绝',
  `remark` varchar(255) DEFAULT NULL COMMENT '审核备注',
  `audit_time` datetime DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='提现申请表';

-- =========================================
-- 四、工单系统表
-- =========================================

-- 12. 工单表
CREATE TABLE IF NOT EXISTS `__PREFIX__ticket` (
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
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工单表';

-- 13. 工单回复表
CREATE TABLE IF NOT EXISTS `__PREFIX__ticket_reply` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) NOT NULL,
  `user_type` tinyint(1) NOT NULL COMMENT '1=用户,2=管理员',
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `attachments` text COMMENT '附件JSON',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ticket_id` (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='工单回复表';

-- =========================================
-- 五、数据报表表
-- =========================================

-- 14. 访问统计记录表
CREATE TABLE IF NOT EXISTS `__PREFIX__stat_visit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `page` varchar(100) NOT NULL,
  `uv` int(11) NOT NULL DEFAULT '0',
  `pv` int(11) NOT NULL DEFAULT '0',
  `ip` varchar(50) DEFAULT NULL,
  `utm_source` varchar(100) DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_date` (`date`),
  KEY `idx_utm` (`utm_source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='访问统计记录表';

-- =========================================
-- 六、其他功能表
-- =========================================

-- 15. 自定义页面表
CREATE TABLE IF NOT EXISTS `__PREFIX__custom_page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `slug` varchar(100) NOT NULL COMMENT 'URL别名',
  `content` longtext NOT NULL,
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='自定义页面表';

-- 16. 友情链接表
CREATE TABLE IF NOT EXISTS `__PREFIX__friend_link` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `url` varchar(255) NOT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `sort` int(11) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='友情链接表';

-- 17. 系统配置扩展表
CREATE TABLE IF NOT EXISTS `__PREFIX__config_extra` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置扩展表';

-- 插入默认配置
INSERT INTO `__PREFIX__config_extra` (`group`, `key`, `value`, `type`, `description`, `sort`) VALUES
('user', 'level_enabled', '1', 'bool', '启用用户等级', 1),
('user', 'points_enabled', '1', 'bool', '启用积分系统', 2),
('user', 'checkin_enabled', '1', 'bool', '启用每日签到', 3),
('user', 'checkin_base_points', '10', 'number', '签到基础积分', 4),
('user', 'checkin_continuous_bonus', '5', 'number', '连续签到额外积分', 5),
('coupon', 'enabled', '1', 'bool', '启用优惠券', 10),
('flash_sale', 'enabled', '1', 'bool', '启用秒杀活动', 11),
('wholesale', 'enabled', '1', 'bool', '启用批发折扣', 12),
('lottery', 'enabled', '1', 'bool', '启用积分抽奖', 13),
('ticket', 'enabled', '1', 'bool', '启用工单系统', 20),
('withdraw', 'enabled', '1', 'bool', '启用提现功能', 21),
('withdraw', 'min_amount', '10', 'number', '最低提现金额', 22),
('poster', 'enabled', '1', 'bool', '启用推广海报', 30),
('order', 'auto_close_minutes', '30', 'number', '订单超时自动关闭分钟数', 40),
('stock', 'alert_threshold', '10', 'number', '库存预警阈值', 50),
('card', 'expire_reminder_days', '3,1', 'text', '卡密到期提醒天数', 51);

-- 给商品表添加字段
ALTER TABLE `__PREFIX__commodity` 
ADD COLUMN IF NOT EXISTS `is_hidden` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否隐藏' AFTER `stock`,
ADD COLUMN IF NOT EXISTS `level_prices` text COMMENT '等级价格JSON' AFTER `is_hidden`,
ADD COLUMN IF NOT EXISTS `has_wholesale` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否有批发折扣' AFTER `level_prices`,
ADD COLUMN IF NOT EXISTS `source_api_config` text COMMENT '货源API配置JSON' AFTER `has_wholesale`,
ADD COLUMN IF NOT EXISTS `expire_days` int(11) DEFAULT NULL COMMENT '卡密有效期天数' AFTER `source_api_config`;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================
-- 迁移完成！
-- =========================================
