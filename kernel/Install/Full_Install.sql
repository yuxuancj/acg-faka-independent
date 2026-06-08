SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `__PREFIX__bill`;
CREATE TABLE `__PREFIX__bill`  (
                                   `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                   `owner` int UNSIGNED NOT NULL COMMENT '用户id',
                                   `amount` decimal(10, 2) UNSIGNED NOT NULL COMMENT '金额',
                                   `balance` decimal(14, 2) UNSIGNED NOT NULL COMMENT '余额',
                                   `type` tinyint NOT NULL COMMENT '类型：0=支出，1=收入',
                                   `currency` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '货币：0=余额，1=硬币',
                                   `log` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '日志',
                                   `create_time` datetime NOT NULL COMMENT '创建时间',
                                   PRIMARY KEY (`id`) USING BTREE,
                                   INDEX `owner`(`owner` ASC) USING BTREE,
                                   INDEX `type`(`type` ASC) USING BTREE,
                                   CONSTRAINT `__PREFIX__bill_ibfk_1` FOREIGN KEY (`owner`) REFERENCES `__PREFIX__user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

DROP TABLE IF EXISTS `__PREFIX__business`;
CREATE TABLE `__PREFIX__business`  (
                                       `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                       `user_id` int UNSIGNED NOT NULL COMMENT '用户id',
                                       `shop_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺名称',
                                       `title` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '浏览器标题',
                                       `notice` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '店铺公告',
                                       `service_qq` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '客服QQ',
                                       `service_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '网页客服链接',
                                       `subdomain` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '子域名',
                                       `topdomain` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '顶级域名',
                                       `master_display` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '主站显示：0=否，1=是',
                                       `create_time` datetime NOT NULL COMMENT '创建时间',
                                       PRIMARY KEY (`id`) USING BTREE,
                                       UNIQUE INDEX `user_id`(`user_id` ASC) USING BTREE,
                                       UNIQUE INDEX `subdomain`(`subdomain` ASC) USING BTREE,
                                       UNIQUE INDEX `topdomain`(`topdomain` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__business_level`;
CREATE TABLE `__PREFIX__business_level`  (
                                             `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                             `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '等级名称',
                                             `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图标',
                                             `cost` decimal(4, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '商家自己的商品，抽成百分比',
                                             `accrual` decimal(4, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '主站商品，分给商家的收益百分比',
                                             `substation` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '分站：0=关闭，1=启用',
                                             `top_domain` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '顶级域名：0=关闭，1=启用',
                                             `price` decimal(10, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '购买价格',
                                             `supplier` tinyint UNSIGNED NOT NULL DEFAULT 1 COMMENT '供货商权限：0=关闭，1=启用',
                                             PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


INSERT INTO `__PREFIX__business_level` VALUES (1, '体验版', '/assets/static/images/business/v1.png', 0.30, 0.10, 1, 0, 188.00, 1);
INSERT INTO `__PREFIX__business_level` VALUES (3, '普通版', '/assets/static/images/business/v2.png', 0.25, 0.15, 1, 0, 288.00, 1);
INSERT INTO `__PREFIX__business_level` VALUES (4, '专业版', '/assets/static/images/business/v3.png', 0.20, 0.20, 1, 1, 388.00, 1);

DROP TABLE IF EXISTS `__PREFIX__card`;
CREATE TABLE `__PREFIX__card`  (
                                   `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                   `owner` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属会员：0=系统，其他等于会员UID',
                                   `commodity_id` int UNSIGNED NOT NULL COMMENT '商品id',
                                   `draft` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '预选信息',
                                   `secret` varchar(760) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '卡密信息',
                                   `create_time` datetime NOT NULL COMMENT '添加时间',
                                   `purchase_time` datetime NULL DEFAULT NULL COMMENT '购买时间',
                                   `order_id` int UNSIGNED NULL DEFAULT NULL COMMENT '订单id',
                                   `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=未出售，1=已出售，2=已锁定',
                                   `note` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注信息',
                                   `race` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品种类',
                                   `sku` json DEFAULT NULL COMMENT 'SKU',
                                   `draft_premium` decimal(10,2) unsigned DEFAULT NULL COMMENT '预选加价',
                                   `cost` decimal(10,2) unsigned DEFAULT 0 COMMENT '预选成本',
                                   PRIMARY KEY (`id`) USING BTREE,
                                   INDEX `owner`(`owner` ASC) USING BTREE,
                                   INDEX `commodity_id`(`commodity_id` ASC) USING BTREE,
                                   INDEX `order_id`(`order_id` ASC) USING BTREE,
                                   INDEX `secret`(`secret` ASC) USING BTREE,
                                   INDEX `status`(`status` ASC) USING BTREE,
                                   INDEX `note`(`note` ASC) USING BTREE,
                                   INDEX `race`(`race` ASC) USING BTREE,
                                   CONSTRAINT `__PREFIX__card_ibfk_1` FOREIGN KEY (`commodity_id`) REFERENCES `__PREFIX__commodity` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__cash`;
CREATE TABLE `__PREFIX__cash`  (
                                   `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                   `user_id` int UNSIGNED NOT NULL COMMENT '用户id',
                                   `amount` decimal(14, 2) UNSIGNED NOT NULL COMMENT '提现金额',
                                   `type` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '类型：0=自动提现，1=手动提现',
                                   `card` tinyint UNSIGNED NOT NULL COMMENT '收款：0=支付宝，1=微信',
                                   `create_time` datetime NOT NULL COMMENT '提现时间',
                                   `arrive_time` datetime NULL DEFAULT NULL COMMENT '到账时间',
                                   `cost` decimal(10, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '手续费',
                                   `status` tinyint UNSIGNED NOT NULL COMMENT '状态：0=处理中，1=成功，2=失败，3=冻结期',
                                   `message` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '消息',
                                   PRIMARY KEY (`id`) USING BTREE,
                                   INDEX `user_id`(`user_id` ASC) USING BTREE,
                                   INDEX `type`(`type` ASC) USING BTREE,
                                   INDEX `message`(`message` ASC) USING BTREE,
                                   CONSTRAINT `__PREFIX__cash_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__category`;
CREATE TABLE `__PREFIX__category`  (
                                       `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                       `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品分类名称',
                                       `sort` smallint UNSIGNED NOT NULL DEFAULT 0 COMMENT '排序',
                                       `create_time` datetime NOT NULL COMMENT '创建时间',
                                       `owner` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属会员：0=系统，其他等于会员UID',
                                       `icon` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '分类图标',
                                       `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=停用，1=启用',
                                       `hide` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '隐藏：1=隐藏，0=不隐藏',
                                       `user_level_config` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '会员配置',
                                       `pid` int UNSIGNED DEFAULT NULL COMMENT '上级ID',
                                       PRIMARY KEY (`id`) USING BTREE,
                                       INDEX `owner`(`owner` ASC) USING BTREE,
                                       INDEX `idx_category_pid`(`pid`) USING BTREE,
                                       INDEX `sort`(`sort` ASC) USING BTREE,
                                       CONSTRAINT `ibfk_category_pid_in_id` FOREIGN KEY (`pid`) REFERENCES `__PREFIX__category`(`id`) ON DELETE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;


INSERT INTO `__PREFIX__category` VALUES (1, 'DEMO', 1, '2021-11-26 17:59:45', 0, '/favicon.ico', 1, 0, NULL , NULL);


DROP TABLE IF EXISTS `__PREFIX__commodity`;
CREATE TABLE `__PREFIX__commodity`  (
                                        `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                        `category_id` int UNSIGNED NOT NULL COMMENT '商品分类ID',
                                        `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
                                        `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '商品说明',
                                        `cover` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '商品封面图片',
                                        `factory_price` decimal(10, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '成本单价',
                                        `price` decimal(10, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '商品单价(未登录)',
                                        `user_price` decimal(10, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '商品单价(会员价)',
                                        `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=下架，1=上架',
                                        `owner` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属会员：0=系统，其他等于会员UID',
                                        `create_time` datetime NOT NULL COMMENT '创建时间',
                                        `api_status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT 'API对接：0=关闭，1=启用',
                                        `code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '商品代码(API对接)',
                                        `delivery_way` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '发货方式：0=自动发货，1=手动发货/插件发货',
                                        `delivery_auto_mode` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '自动发卡模式：0=旧卡先发，1=随机发卡，2=新卡先发',
                                        `delivery_message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手动发货显示信息',
                                        `contact_type` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '联系方式：0=任意，1=手机，2=邮箱，3=QQ',
                                        `password_status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单密码：0=关闭，1=启用',
                                        `sort` smallint UNSIGNED NOT NULL DEFAULT 0 COMMENT '排序',
                                        `coupon` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '优惠卷：0=关闭，1=启用',
                                        `shared_id` int UNSIGNED NULL DEFAULT NULL COMMENT '共享平台ID',
                                        `shared_code` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '共享平台-商品代码',
                                        `shared_premium` float(10, 2) UNSIGNED NULL DEFAULT 0.00 COMMENT '商品加价',
                                        `shared_stock` json DEFAULT NULL COMMENT '库存信息',
                                        `stock` int(11) DEFAULT NULL COMMENT '库存',
                                        `shared_premium_type` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '加价模式',
                                        `seckill_status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '商品秒杀：0=关闭，1=开启',
                                        `seckill_start_time` datetime NULL DEFAULT NULL COMMENT '秒杀开始时间',
                                        `seckill_end_time` datetime NULL DEFAULT NULL COMMENT '秒杀结束时间',
                                        `draft_status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '指定卡密购买：0=关闭，1=启用',
                                        `draft_premium` decimal(10, 2) UNSIGNED NULL DEFAULT 0.00 COMMENT '指定卡密购买时溢价',
                                        `inventory_hidden` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '隐藏库存：0=否，1=是',
                                        `leave_message` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '发货留言',
                                        `recommend` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '推荐商品：0=否，1=是',
                                        `send_email` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '发送邮件：0=否，1=是',
                                        `only_user` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '限制登录购买：0=否，1=是',
                                        `purchase_count` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '限制购买数量：0=无限制',
                                        `widget` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '控件',
                                        `level_price` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '会员等级-定制价格',
                                        `level_disable` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '禁用会员等级折扣，0=关闭，1=启用',
                                        `minimum` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '最低购买数量，0=无限制',
                                        `maximum` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '最大购买数量，0=无限制',
                                        `shared_sync` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '同步平台价格：0=关，1=开',
                                        `config` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '配置文件',
                                        `hide` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '隐藏：1=隐藏，0=不隐藏',
                                        `inventory_sync` tinyint NOT NULL DEFAULT 0 COMMENT '同步库存数量: 0=关，1=开',
                                        `shared_amount_sync` tinyint UNSIGNED DEFAULT 0 COMMENT '同步金额',
                                        `shared_config_sync` tinyint UNSIGNED DEFAULT 0 COMMENT '同步配置参数',
                                        PRIMARY KEY (`id`) USING BTREE,
                                        UNIQUE INDEX `code`(`code` ASC) USING BTREE,
                                        INDEX `owner`(`owner` ASC) USING BTREE,
                                        INDEX `status`(`status` ASC) USING BTREE,
                                        INDEX `sort`(`sort` ASC) USING BTREE,
                                        INDEX `category_id`(`category_id` ASC) USING BTREE,
                                        INDEX `shared_id`(`shared_id` ASC) USING BTREE,
                                        INDEX `seckill_status`(`seckill_status` ASC) USING BTREE,
                                        INDEX `api_status`(`api_status` ASC) USING BTREE,
                                        INDEX `recommend`(`recommend` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

INSERT INTO `__PREFIX__commodity` VALUES (1, 1, 'DEMO', '<p>该商品是演示商品</p>', '/favicon.ico', 0.00, 1.00, 0.90, 1, 0, '2021-11-26 18:01:30', 1, '8AE80574F3CA98BE', 1, 0, '', 0, 0, 1, 1, NULL, '', 0.00 , NULL,999999, 0, 0, NULL, NULL, 0, 0.00, 0, NULL, 0, 0, 0, 0, NULL, NULL, 0, 0, 0, 0, NULL, 0, 0 ,0 ,0);



DROP TABLE IF EXISTS `__PREFIX__config`;
CREATE TABLE `__PREFIX__config`  (
                                     `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
                                     `key` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '配置键名称',
                                     `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置内容',
                                     PRIMARY KEY (`id`) USING BTREE,
                                     UNIQUE INDEX `key`(`key`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 45 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;


INSERT INTO `__PREFIX__config` VALUES (1, 'shop_name', '异次元店铺');
INSERT INTO `__PREFIX__config` VALUES (2, 'title', '异次元店铺 - 最适合你的个人店铺系统！');
INSERT INTO `__PREFIX__config` VALUES (3, 'description', '');
INSERT INTO `__PREFIX__config` VALUES (4, 'keywords', '');
INSERT INTO `__PREFIX__config` VALUES (14, 'user_theme', 'Cartoon');
INSERT INTO `__PREFIX__config` VALUES (5, 'registered_state', '1');
INSERT INTO `__PREFIX__config` VALUES (6, 'registered_type', '0');
INSERT INTO `__PREFIX__config` VALUES (7, 'registered_verification', '1');
INSERT INTO `__PREFIX__config` VALUES (8, 'registered_phone_verification', '0');
INSERT INTO `__PREFIX__config` VALUES (9, 'registered_email_verification', '0');
INSERT INTO `__PREFIX__config` VALUES (10, 'sms_config', '{\"accessKeyId\":\"\",\"accessKeySecret\":\"\",\"signName\":\"\",\"templateCode\":\"\"}');
INSERT INTO `__PREFIX__config` VALUES (11, 'email_config', '{\"smtp\":\"\",\"port\":\"\",\"username\":\"\",\"password\":\"\"}');
INSERT INTO `__PREFIX__config` VALUES (12, 'login_verification', '1');
INSERT INTO `__PREFIX__config` VALUES (13, 'forget_type', '0');
INSERT INTO `__PREFIX__config` VALUES (15, 'notice', '<p><b><font color=\"#f9963b\">本程序为开源程序，使用者造成的一切法律后果与作者无关。</font></b></p>');
INSERT INTO `__PREFIX__config` VALUES (16, 'trade_verification', '1');
INSERT INTO `__PREFIX__config` VALUES (17, 'recharge_welfare', '0');
INSERT INTO `__PREFIX__config` VALUES (18, 'recharge_welfare_config', '');
INSERT INTO `__PREFIX__config` VALUES (19, 'promote_rebate_v1', '0.1');
INSERT INTO `__PREFIX__config` VALUES (20, 'promote_rebate_v2', '0.2');
INSERT INTO `__PREFIX__config` VALUES (21, 'promote_rebate_v3', '0.3');
INSERT INTO `__PREFIX__config` VALUES (22, 'substation_display', '1');
INSERT INTO `__PREFIX__config` VALUES (24, 'domain', '');
INSERT INTO `__PREFIX__config` VALUES (25, 'service_qq', '');
INSERT INTO `__PREFIX__config` VALUES (26, 'service_url', '');
INSERT INTO `__PREFIX__config` VALUES (27, 'cash_type_alipay', '1');
INSERT INTO `__PREFIX__config` VALUES (28, 'cash_type_wechat', '1');
INSERT INTO `__PREFIX__config` VALUES (29, 'cash_cost', '5');
INSERT INTO `__PREFIX__config` VALUES (30, 'cash_min', '100');
INSERT INTO `__PREFIX__config` VALUES (31, 'cname', '');
INSERT INTO `__PREFIX__config` VALUES (32, 'background_url', '/assets/admin/images/login/bg.jpg');
INSERT INTO `__PREFIX__config` VALUES (33, 'default_category', '0');
INSERT INTO `__PREFIX__config` VALUES (34, 'substation_display_list', '[]');
INSERT INTO `__PREFIX__config` VALUES (35, 'closed', '0');
INSERT INTO `__PREFIX__config` VALUES (36, 'closed_message', '我们正在升级，请耐心等待完成。');
INSERT INTO `__PREFIX__config` VALUES (37, 'recharge_min', '10');
INSERT INTO `__PREFIX__config` VALUES (38, 'recharge_max', '1000');
INSERT INTO `__PREFIX__config` VALUES (39, 'user_mobile_theme', '0');
INSERT INTO `__PREFIX__config` VALUES (40, 'commodity_recommend', '0');
INSERT INTO `__PREFIX__config` VALUES (41, 'commodity_name', '推荐');
INSERT INTO `__PREFIX__config` VALUES (42, 'background_mobile_url', '');
INSERT INTO `__PREFIX__config` VALUES (43, 'username_len', '6');
INSERT INTO `__PREFIX__config` VALUES (44, 'cash_type_balance', '0');
INSERT INTO `__PREFIX__config` VALUES (45, 'callback_domain', '');
INSERT INTO `__PREFIX__config` VALUES (46, 'session_expire', '0');
INSERT INTO `__PREFIX__config` VALUES (47, 'cash_type_usdt', '1');
INSERT INTO `__PREFIX__config` VALUES (48, 'user_center_theme', 'MountFuji');


DROP TABLE IF EXISTS `__PREFIX__coupon`;
CREATE TABLE `__PREFIX__coupon`  (
                                     `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                     `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '优惠卷代码',
                                     `commodity_id` int UNSIGNED NOT NULL COMMENT '商品id',
                                     `owner` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属会员：0=系统，其他等于会员UID',
                                     `create_time` datetime NOT NULL COMMENT '创建时间',
                                     `expire_time` datetime NULL DEFAULT NULL COMMENT '过期时间',
                                     `service_time` datetime NULL DEFAULT NULL COMMENT '使用时间',
                                     `money` decimal(10, 2) UNSIGNED NOT NULL COMMENT '抵扣金额',
                                     `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=未使用，1=已使用，2=锁定',
                                     `trade_no` char(22) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单号',
                                     `note` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注信息',
                                     `mode` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '抵扣模式',
                                     `category_id` int UNSIGNED NULL DEFAULT 0 COMMENT '商品分类ID',
                                     `life` int UNSIGNED NOT NULL DEFAULT 1 COMMENT '卡密使用寿命',
                                     `use_life` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '已使用次数',
                                     `race` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品类别',
                                     `sku` json DEFAULT NULL COMMENT 'SKU',
                                     PRIMARY KEY (`id`) USING BTREE,
                                     UNIQUE INDEX `code`(`code` ASC) USING BTREE,
                                     INDEX `commodity_id`(`commodity_id` ASC) USING BTREE,
                                     INDEX `owner`(`owner` ASC) USING BTREE,
                                     INDEX `create_time`(`create_time` ASC) USING BTREE,
                                     INDEX `money`(`money` ASC) USING BTREE,
                                     INDEX `status`(`status` ASC) USING BTREE,
                                     INDEX `order_id`(`trade_no` ASC) USING BTREE,
                                     INDEX `note`(`note` ASC) USING BTREE,
                                     INDEX `race`(`race` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__manage`;
CREATE TABLE `__PREFIX__manage`  (
                                     `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
                                     `email` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '邮箱',
                                     `password` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '密码',
                                     `security_password` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '安全密码',
                                     `nickname` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
                                     `salt` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '盐',
                                     `avatar` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '头像',
                                     `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=冻结，1=正常',
                                     `type` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '类型：0=系统账号，1=普通账号(全天)，2=日间账号，3=夜间账号',
                                     `create_time` datetime NOT NULL COMMENT '创建时间',
                                     `login_time` datetime NULL DEFAULT NULL COMMENT '登录时间',
                                     `last_login_time` datetime NULL DEFAULT NULL COMMENT '上一次登录时间',
                                     `login_ip` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '登录IP',
                                     `last_login_ip` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '上一次登录IP',
                                     `note` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '备注',
                                     PRIMARY KEY (`id`) USING BTREE,
                                     UNIQUE INDEX `username`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;


INSERT INTO `__PREFIX__manage` VALUES (1, '__MANAGE_EMAIL__', '__MANAGE_PASSWORD__', NULL, '__MANAGE_NICKNAME__', '__MANAGE_SALT__', '/favicon.ico', 1, 0, '1997-01-01 00:00:00', NULL , NULL, NULL, NULL, NULL);


DROP TABLE IF EXISTS `__PREFIX__order`;
CREATE TABLE `__PREFIX__order`  (
                                    `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                    `owner` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属会员：0=游客，其他等于会员UID',
                                    `user_id` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '商户ID：0=系统，其他等于会员ID',
                                    `trade_no` char(19) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
                                    `amount` decimal(10, 2) UNSIGNED NOT NULL COMMENT '订单金额',
                                    `commodity_id` int UNSIGNED NOT NULL COMMENT '商品id',
                                    `card_id` int UNSIGNED NULL DEFAULT NULL COMMENT '预选卡密id',
                                    `card_num` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '卡密数量',
                                    `pay_id` int UNSIGNED NOT NULL COMMENT '支付方式id',
                                    `create_time` datetime NOT NULL COMMENT '下单时间',
                                    `create_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '下单IP',
                                    `create_device` tinyint UNSIGNED NOT NULL COMMENT '下单设备：0=电脑,1=安卓,2=IOS,3=IPAD',
                                    `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
                                    `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单状态：0=未支付，1=已支付',
                                    `secret` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '卡密信息',
                                    `password` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '查询密码',
                                    `contact` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系方式',
                                    `delivery_status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '发货状态：0=未发货，1=已发货',
                                    `pay_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                                    `coupon_id` int UNSIGNED NULL DEFAULT NULL COMMENT '优惠卷id',
                                    `cost` decimal(10, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '手续费',
                                    `from` int UNSIGNED NULL DEFAULT NULL COMMENT '推广人id',
                                    `premium` decimal(10, 2) UNSIGNED NULL DEFAULT 0.00 COMMENT '加价',
                                    `widget` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '控件内容',
                                    `rent` decimal(10, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '成本价',
                                    `race` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品种类',
                                    `rebate` decimal(10, 2) UNSIGNED NULL DEFAULT 0.00 COMMENT '返利金额',
                                    `pay_cost` decimal(10, 2) UNSIGNED NULL DEFAULT 0.00 COMMENT '支付接口手续费',
                                    `sku` json DEFAULT NULL COMMENT 'SKU',
                                    `divide_amount` decimal(10,2) unsigned DEFAULT NULL COMMENT '推广者分成金额',
                                    `substation_user_id` int(10) unsigned DEFAULT NULL COMMENT '子站ID',
                                    `request_no` char(19) COMMENT '请求id',
                                    PRIMARY KEY (`id`) USING BTREE,
                                    UNIQUE INDEX `trade_no`(`trade_no` ASC) USING BTREE,
                                    UNIQUE INDEX `request_no`(`request_no` ASC) USING BTREE,
                                    INDEX `commodity_id`(`commodity_id` ASC) USING BTREE,
                                    INDEX `pay_id`(`pay_id` ASC) USING BTREE,
                                    INDEX `contact`(`contact` ASC) USING BTREE,
                                    INDEX `create_ip`(`create_ip` ASC) USING BTREE,
                                    INDEX `owner`(`owner` ASC) USING BTREE,
                                    INDEX `from`(`from` ASC) USING BTREE,
                                    INDEX `user_id`(`user_id` ASC) USING BTREE,
                                    INDEX `card_id`(`card_id` ASC) USING BTREE,
                                    INDEX `create_time`(`create_time` ASC) USING BTREE,
                                    INDEX `delivery_status`(`delivery_status` ASC) USING BTREE,
                                    INDEX `substation_user_id`(`substation_user_id`) USING BTREE,
                                    INDEX `coupon_id`(`coupon_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__order_option`;
CREATE TABLE `__PREFIX__order_option`  (
                                           `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                           `order_id` int UNSIGNED NOT NULL COMMENT '订单id',
                                           `option` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '配置数据',
                                           PRIMARY KEY (`id`) USING BTREE,
                                           UNIQUE INDEX `order_id`(`order_id` ASC) USING BTREE,
                                           CONSTRAINT `__PREFIX__order_option_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `__PREFIX__order` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__pay`;
CREATE TABLE `__PREFIX__pay`  (
                                  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                  `name` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '支付名称',
                                  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '图标',
                                  `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '支付代码',
                                  `commodity` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '前台状态：0=停用，1=启用',
                                  `recharge` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '充值状态：0=停用，1=启用',
                                  `create_time` datetime NOT NULL COMMENT '添加时间',
                                  `handle` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '支付平台',
                                  `sort` smallint UNSIGNED NOT NULL DEFAULT 0 COMMENT '排序',
                                  `equipment` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '设备：0=通用，1=手机，2=电脑',
                                  `cost` decimal(10, 3) UNSIGNED NULL DEFAULT 0.000 COMMENT '手续费',
                                  `cost_type` tinyint UNSIGNED NULL DEFAULT 0 COMMENT '手续费模式：0=单笔固定，1=百分比',
                                  PRIMARY KEY (`id`) USING BTREE,
                                  INDEX `commodity`(`commodity` ASC) USING BTREE,
                                  INDEX `recharge`(`recharge` ASC) USING BTREE,
                                  INDEX `sort`(`sort` ASC) USING BTREE,
                                  INDEX `equipment`(`equipment` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


INSERT INTO `__PREFIX__pay` VALUES (1, '余额', '/assets/static/images/wallet.png', '#system', 1, 0, '1997-01-01 00:00:00', '#system', 999, 0, 0.000, 0);
INSERT INTO `__PREFIX__pay` VALUES (2, '支付宝', '/assets/user/images/cash/alipay.png', 'alipay', 1, 1, '1997-01-01 00:00:00', 'Epay', 1, 0, 0.000, 0);


DROP TABLE IF EXISTS `__PREFIX__shared`;
CREATE TABLE `__PREFIX__shared`  (
                                     `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                     `type` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '对接类型：0=内置，其他待扩展',
                                     `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '店铺名称',
                                     `domain` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '店铺地址',
                                     `app_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商户ID',
                                     `app_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '密钥',
                                     `create_time` datetime NOT NULL COMMENT '创建时间',
                                     `balance` decimal(14, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '余额(缓存)',
                                     PRIMARY KEY (`id`) USING BTREE,
                                     UNIQUE INDEX `domain`(`domain` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__user`;
CREATE TABLE `__PREFIX__user`  (
                                   `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                   `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '会员名',
                                   `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
                                   `phone` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机',
                                   `qq` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'QQ号',
                                   `password` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录密码',
                                   `salt` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '盐',
                                   `app_key` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '对接密钥',
                                   `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像',
                                   `balance` decimal(14, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '余额',
                                   `coin` decimal(14, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '硬币，可提现的币',
                                   `integral` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '积分',
                                   `create_time` datetime NOT NULL COMMENT '注册时间',
                                   `login_time` datetime NULL DEFAULT NULL COMMENT '登录时间',
                                   `last_login_time` datetime NULL DEFAULT NULL COMMENT '上一次登录时间',
                                   `login_ip` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '登录IP',
                                   `last_login_ip` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '上一次登录IP',
                                   `pid` int UNSIGNED NULL DEFAULT 0 COMMENT '上级ID',
                                   `recharge` decimal(14, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '累计充值',
                                   `total_coin` decimal(14, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '累计获得的硬币',
                                   `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=封禁，1=正常',
                                   `business_level` int UNSIGNED NULL DEFAULT NULL COMMENT '商户等级id',
                                   `nicename` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真实姓名',
                                   `alipay` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '支付宝账号',
                                   `wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '微信收款二维码',
                                   `wallet_address` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '钱包地址',
                                   `settlement` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '自动结算：0=支付宝，1=微信',
                                   PRIMARY KEY (`id`) USING BTREE,
                                   UNIQUE INDEX `username`(`username` ASC) USING BTREE,
                                   UNIQUE INDEX `email`(`email` ASC) USING BTREE,
                                   UNIQUE INDEX `phone`(`phone` ASC) USING BTREE,
                                   INDEX `pid`(`pid` ASC) USING BTREE,
                                   INDEX `business_level`(`business_level` ASC) USING BTREE,
                                   INDEX `coin`(`coin` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1000 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__user_category`;
CREATE TABLE `__PREFIX__user_category`  (
                                            `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                            `user_id` int UNSIGNED NOT NULL COMMENT '商家id',
                                            `category_id` int UNSIGNED NOT NULL COMMENT '分类id',
                                            `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '自定义分类名称',
                                            `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=屏蔽，1=显示',
                                            PRIMARY KEY (`id`) USING BTREE,
                                            UNIQUE INDEX `user_id`(`user_id` ASC, `category_id` ASC) USING BTREE,
                                            INDEX `status`(`status` ASC) USING BTREE,
                                            INDEX `__PREFIX__user_category_ibfk_2`(`category_id` ASC) USING BTREE,
                                            INDEX `user_id_2`(`user_id` ASC) USING BTREE,
                                            CONSTRAINT `__PREFIX__user_category_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                                            CONSTRAINT `__PREFIX__user_category_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `__PREFIX__category` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__user_commodity`;
CREATE TABLE `__PREFIX__user_commodity`  (
                                             `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                             `user_id` int UNSIGNED NOT NULL COMMENT '商家id',
                                             `commodity_id` int UNSIGNED NOT NULL COMMENT '商品id',
                                             `premium` float(10, 2) UNSIGNED NULL DEFAULT 0.00 COMMENT '商品加价',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '自定义名称',
  `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=隐藏，1=显示',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC, `commodity_id` ASC) USING BTREE,
  INDEX `commodity_id`(`commodity_id` ASC) USING BTREE,
  INDEX `user_id_2`(`user_id` ASC) USING BTREE,
  INDEX `status`(`status` ASC) USING BTREE,
  CONSTRAINT `__PREFIX__user_commodity_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `__PREFIX__user_commodity_ibfk_2` FOREIGN KEY (`commodity_id`) REFERENCES `__PREFIX__commodity` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__user_group`;
CREATE TABLE `__PREFIX__user_group`  (
                                         `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                         `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '等级名称',
                                         `icon` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '等级图标',
                                         `discount_config` TEXT DEFAULT NULL COMMENT '折扣配置',
                                         `cost` decimal(4, 2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT '抽成比例',
                                         `recharge` decimal(14, 2) UNSIGNED NOT NULL COMMENT '累计充值(达到该等级)',
                                         PRIMARY KEY (`id`) USING BTREE,
                                         UNIQUE INDEX `recharge`(`recharge` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


INSERT INTO `__PREFIX__user_group` VALUES (1, '一贫如洗', '/assets/static/images/group/ic_user level_1.png', null, 0.30, 0.00);
INSERT INTO `__PREFIX__user_group` VALUES (2, '小康之家', '/assets/static/images/group/ic_user level_2.png', null, 0.25, 50.00);
INSERT INTO `__PREFIX__user_group` VALUES (3, '腰缠万贯', '/assets/static/images/group/ic_user level_3.png', null, 0.20, 100.00);
INSERT INTO `__PREFIX__user_group` VALUES (4, '富甲一方', '/assets/static/images/group/ic_user level_4.png', null, 0.15, 200.00);
INSERT INTO `__PREFIX__user_group` VALUES (5, '富可敌国', '/assets/static/images/group/ic_user level_5.png', null, 0.10, 300.00);
INSERT INTO `__PREFIX__user_group` VALUES (6, '至尊', '/assets/static/images/group/ic_user level_6.png', null, 0.05, 500.00);

DROP TABLE IF EXISTS `__PREFIX__user_recharge`;
CREATE TABLE `__PREFIX__user_recharge`  (
                                            `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                            `trade_no` char(22) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
                                            `user_id` int UNSIGNED NOT NULL COMMENT '用户id',
                                            `amount` decimal(10, 2) UNSIGNED NOT NULL COMMENT '充值金额',
                                            `pay_id` int UNSIGNED NOT NULL COMMENT '支付id',
                                            `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=未支付，1=已支付',
                                            `create_time` datetime NOT NULL COMMENT '创建时间',
                                            `create_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '下单IP',
                                            `pay_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '支付地址',
                                            `pay_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
                                            `option` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '配置参数',
                                            PRIMARY KEY (`id`) USING BTREE,
                                            UNIQUE INDEX `trade_no`(`trade_no` ASC) USING BTREE,
                                            INDEX `user_id`(`user_id` ASC) USING BTREE,
                                            INDEX `pay_id`(`pay_id` ASC) USING BTREE,
                                            INDEX `status`(`status` ASC) USING BTREE,
                                            CONSTRAINT `__PREFIX__user_recharge_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;


DROP TABLE IF EXISTS `__PREFIX__manage_log`;
CREATE TABLE `__PREFIX__manage_log`  (
                                         `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
                                         `email` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理员邮箱',
                                         `nickname` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '管理员呢称',
                                         `content` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '日志内容',
                                         `create_time` datetime NOT NULL COMMENT '创建时间',
                                         `create_ip` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'IP地址',
                                         `ua` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '浏览器UA',
                                         `risk` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '风险：0=正常，1=异常',
                                         PRIMARY KEY (`id`) USING BTREE,
                                         INDEX `create_ip`(`create_ip`) USING BTREE,
                                         INDEX `create_time`(`create_time`) USING BTREE,
                                         INDEX `risk`(`risk`) USING BTREE,
                                         INDEX `email`(`email`) USING BTREE,
                                         INDEX `nickname`(`nickname`) USING BTREE,
                                         INDEX `content`(`content`) USING BTREE
) ENGINE = MyISAM CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `__PREFIX__commodity_group`;
CREATE TABLE IF NOT EXISTS `__PREFIX__commodity_group` (
                                                           `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
    `name` varchar(32) NOT NULL COMMENT '组名称',
    `commodity_list` json DEFAULT NULL COMMENT '商品列表',
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `__PREFIX__upload`;
CREATE TABLE `__PREFIX__upload` (
                                    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
                                    `user_id` int(11) unsigned DEFAULT NULL COMMENT 'null=后台',
                                    `hash` varchar(32) NOT NULL COMMENT '文件MD5',
                                    `type` varchar(8) NOT NULL COMMENT '文件类型',
                                    `path` varchar(255) NOT NULL COMMENT '文件路径',
                                    `create_time` datetime NOT NULL COMMENT '上传时间',
                                    `note` varchar(32) DEFAULT NULL COMMENT '文件备注',
                                    PRIMARY KEY (`id`) USING BTREE,
                                    UNIQUE KEY `hash` (`hash`) USING BTREE,
                                    KEY `user_id` (`user_id`) USING BTREE,
                                    KEY `type` (`type`) USING BTREE,
                                    KEY `create_time` (`create_time`) USING BTREE,
                                    KEY `note` (`note`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;-- =========================================
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
ADD COLUMN `growth_points` int(11) NOT NULL DEFAULT '0' COMMENT '成长值' AFTER `balance`,
ADD COLUMN `points` int(11) NOT NULL DEFAULT '0' COMMENT '积分' AFTER `growth_points`,
ADD COLUMN `level_id` int(11) DEFAULT '1' COMMENT '等级ID' AFTER `points`,
ADD COLUMN `is_new_admin` tinyint(1) NOT NULL DEFAULT '1' COMMENT '是否首次登录后台' AFTER `level_id`,
ADD KEY `idx_level_id` (`level_id`);

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
ADD COLUMN `is_hidden` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否隐藏' AFTER `stock`,
ADD COLUMN `level_prices` text COMMENT '等级价格JSON' AFTER `is_hidden`,
ADD COLUMN `has_wholesale` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否有批发折扣' AFTER `level_prices`,
ADD COLUMN `source_api_config` text COMMENT '货源API配置JSON' AFTER `has_wholesale`,
ADD COLUMN `expire_days` int(11) DEFAULT NULL COMMENT '卡密有效期天数' AFTER `source_api_config`;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================
-- 迁移完成！
-- =========================================
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
