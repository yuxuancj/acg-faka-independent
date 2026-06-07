-- ACG-Faka 测试数据库初始化
-- 包含完整的测试数据和配置

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 创建管理员账户
INSERT INTO `__PREFIX__manage` VALUES 
(1, 'admin@acgfaka.test', '21232f297a57a5a743894a0e4a801fc3', NULL, '系统管理员', '5a4d8e0c7e0c7e0c7e0c7e0c7e0c7e0c', '/favicon.ico', 1, 0, '2024-01-01 00:00:00', NULL, NULL, NULL, NULL, NULL);

-- 创建测试分类
INSERT INTO `__PREFIX__category` VALUES 
(1, '虚拟商品', 1, '2024-01-01 00:00:00', 0, '/favicon.ico', 1, 0, NULL, NULL),
(2, '游戏点卡', 2, '2024-01-01 00:00:00', 0, '/favicon.ico', 1, 0, NULL, NULL),
(3, '软件授权', 3, '2024-01-01 00:00:00', 0, '/favicon.ico', 1, 0, NULL, NULL);

-- 创建测试商品
INSERT INTO `__PREFIX__commodity` VALUES 
(1, 1, 'VIP会员卡', '<p>VIP会员体验卡，可享受全站9折优惠</p>', '/favicon.ico', 5.00, 10.00, 9.00, 1, 0, '2024-01-01 00:00:00', 0, 'TEST001', 1, 0, '', 0, 0, 1, 1, NULL, '', 0.00, NULL, 100, 0, 0, NULL, NULL, 0, 0.00, 0, NULL, 0, 0, 0, 0, 0, NULL, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0),
(2, 2, '游戏点卡50元', '<p>各大游戏平台通用点卡</p>', '/favicon.ico', 45.00, 50.00, 48.00, 1, 0, '2024-01-01 00:00:00', 0, 'TEST002', 1, 0, '', 0, 0, 2, 1, NULL, '', 0.00, NULL, 50, 0, 0, NULL, NULL, 0, 0.00, 0, NULL, 0, 0, 0, 0, 0, NULL, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0),
(3, 3, 'Office 365授权', '<p>一年期Office 365授权密钥</p>', '/favicon.ico', 180.00, 199.00, 189.00, 1, 0, '2024-01-01 00:00:00', 0, 'TEST003', 1, 0, '', 0, 0, 3, 1, NULL, '', 0.00, NULL, 30, 0, 0, NULL, NULL, 0, 0.00, 0, NULL, 0, 0, 0, 0, 0, NULL, NULL, 0, 0, 0, 0, NULL, 0, 0, 0, 0);

-- 创建测试卡密
INSERT INTO `__PREFIX__card` VALUES 
(1, 0, 1, NULL, 'VIP-001-ABCD-1234-EFGH', '2024-01-01 00:00:00', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00),
(2, 0, 1, NULL, 'VIP-002-IJKL-5678-MNOP', '2024-01-01 00:00:00', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00),
(3, 0, 1, NULL, 'VIP-003-QRST-9012-UVWX', '2024-01-01 00:00:00', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00),
(4, 0, 2, NULL, 'GAME-50-001-AAAA-BBBB', '2024-01-01 00:00:00', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00),
(5, 0, 2, NULL, 'GAME-50-002-CCCC-DDDD', '2024-01-01 00:00:00', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00),
(6, 0, 3, NULL, 'OFF365-001-KEY-XXXX-YYYY', '2024-01-01 00:00:00', NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 0.00, 0.00);

-- 创建测试支付配置
INSERT INTO `__PREFIX__pay` VALUES 
(1, '余额支付', '/assets/static/images/wallet.png', '#system', 1, 0, '2024-01-01 00:00:00', '#system', 999, 0, 0.000, 0),
(2, '支付宝', '/assets/static/images/alipay.png', 'alipay', 1, 1, '2024-01-01 00:00:00', 'Epay', 1, 0, 0.000, 0),
(3, '微信支付', '/assets/static/images/wx.png', 'wechat', 1, 1, '2024-01-01 00:00:00', 'Epay', 2, 0, 0.000, 0);

-- 创建测试评价
INSERT INTO `__PREFIX__review` VALUES 
(1, 1, 1000, 1, 5, '商品质量很好，发货速度快！', '感谢您的支持！', 1, '2024-01-15 10:30:00', '2024-01-15 11:00:00'),
(2, 1, 1001, 2, 4, '整体不错，但希望能有更多优惠', NULL, 1, '2024-01-16 14:20:00', NULL),
(3, 2, 1002, 3, 5, '点卡充值成功，很方便', NULL, 1, '2024-01-17 09:15:00', NULL);

-- 创建测试运维配置
INSERT INTO `__PREFIX__maintenance_config` VALUES 
(1, 'auto_backup_enabled', '1', '自动备份启用'),
(2, 'auto_backup_time', '03:00', '自动备份时间'),
(3, 'auto_backup_local', '1', '本地备份'),
(4, 'auto_backup_retention', '7', '备份保留天数'),
(5, 'health_check_enabled', '1', '健康检查启用'),
(6, 'health_check_webhook', '', '健康告警Webhook'),
(7, 'log_archive_enabled', '1', '日志归档启用'),
(8, 'log_archive_retention', '30', '日志保留天数');

SET FOREIGN_KEY_CHECKS = 1;
