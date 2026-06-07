SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 商品评价表
DROP TABLE IF EXISTS `__PREFIX__review`;
CREATE TABLE `__PREFIX__review` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `commodity_id` int UNSIGNED NOT NULL COMMENT '商品id',
  `user_id` int UNSIGNED NULL DEFAULT 0 COMMENT '用户id，0=游客',
  `order_id` int UNSIGNED NOT NULL COMMENT '订单id',
  `rating` tinyint UNSIGNED NOT NULL DEFAULT 5 COMMENT '评分：1-5星',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '评价内容',
  `reply` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '商家回复',
  `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0=待审核，1=已通过，2=已拒绝',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `commodity_id`(`commodity_id` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE,
  INDEX `status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- 自动运维配置表
DROP TABLE IF EXISTS `__PREFIX__maintenance_config`;
CREATE TABLE `__PREFIX__maintenance_config` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `key` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '配置键',
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `key`(`key` ASC) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = DYNAMIC;

-- 插入默认运维配置
INSERT INTO `__PREFIX__maintenance_config` VALUES 
(1, 'auto_backup_enabled', '0', '自动备份启用：0=否，1=是'),
(2, 'auto_backup_time', '03:00', '自动备份时间（HH:MM）'),
(3, 'auto_backup_local', '1', '本地备份：0=否，1=是'),
(4, 'auto_backup_remote', '0', '远程备份：0=否，1=是'),
(5, 'auto_backup_retention', '7', '备份保留天数'),
(6, 'health_check_enabled', '0', '健康检查启用：0=否，1=是'),
(7, 'health_check_webhook', '', '健康告警Webhook地址'),
(8, 'log_archive_enabled', '0', '日志归档启用：0=否，1=是'),
(9, 'log_archive_retention', '30', '日志保留天数');

SET FOREIGN_KEY_CHECKS = 1;
