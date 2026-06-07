# 异次元发卡系统 - 独立版二次开发说明

## 版本信息
- 基础版本：异次元发卡系统开源版
- 二次开发版本：v1.0-independent
- 修改日期：2026-06-07

## 修改概述

### 1. 移除云端依赖和应用商店（强制要求）

#### 删除的文件：
- `/kernel/Plugin.php` - 应用商店核心插件文件
- `/app/Controller/Admin/Store.php` - 应用商店控制器
- `/app/Controller/Admin/Api/Store.php` - 应用商店API控制器
- `/app/View/Admin/Store/` - 应用商店视图目录（含Store.html和Developer.html）

#### 修改的文件：
- `/app/View/Admin/Header.html` - 移除应用商店菜单、共享店铺菜单和版本更新提示
- `/kernel/Kernel.php` - 移除BASE_APP_SERVER定义

### 2. 支付系统强化

#### 新增支付插件：
1. **易支付（Epay）** - 彩虹易支付聚合接口
   - 文件位置：`/app/Pay/Epay/`
   - 配置文件：`/app/Pay/Epay/Config/Info.php`
   - 主类：`/app/Pay/Epay/Epay.php`
   - 支持：支付宝、微信、QQ钱包等多种支付方式

2. **支付宝（Alipay）** - 官方支付接口
   - 文件位置：`/app/Pay/Alipay/`
   - 配置文件：`/app/Pay/Alipay/Config/Info.php`
   - 主类：`/app/Pay/Alipay/Alipay.php`
   - 支持：电脑网站支付、手机网站支付

3. **PAYJS** - 个人免签约支付
   - 文件位置：`/app/Pay/Payjs/`
   - 配置文件：`/app/Pay/Payjs/Config/Info.php`
   - 主类：`/app/Pay/Payjs/Payjs.php`
   - 支持：微信扫码支付

### 3. 商品评价功能

#### 新增文件：
- `/app/Model/Review.php` - 评价模型类

#### 新增数据库表：
- `__PREFIX__review` - 商品评价表

### 4. 自动运维功能

#### 新增文件：
- `/app/Service/Maintenance.php` - 自动运维服务类

#### 新增数据库表：
- `__PREFIX__maintenance_config` - 运维配置表

#### 功能特性：
1. **自动数据库备份**
   - 支持本地备份
   - 可配置备份保留天数
   - 自动清理过期备份

2. **健康检查**
   - 数据库连接检查
   - 磁盘空间检查
   - PHP扩展检查
   - 支持钉钉/飞书Webhook告警

3. **日志归档**
   - 自动清理过期日志
   - 可配置日志保留天数

## 数据库变更

需要执行的扩展SQL文件：`/kernel/Install/Extension.sql`

### 新增表说明：

#### review（商品评价表）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| commodity_id | int | 商品ID |
| user_id | int | 用户ID（0=游客） |
| order_id | int | 订单ID |
| rating | tinyint | 评分（1-5星） |
| content | text | 评价内容 |
| reply | text | 商家回复 |
| status | tinyint | 状态（0=待审核，1=已通过，2=已拒绝） |
| create_time | datetime | 创建时间 |
| update_time | datetime | 更新时间 |

#### maintenance_config（运维配置表）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 主键 |
| key | varchar | 配置键 |
| value | text | 配置值 |
| description | varchar | 描述 |

默认配置项：
- `auto_backup_enabled` - 自动备份开关
- `auto_backup_time` - 自动备份时间
- `auto_backup_local` - 本地备份开关
- `auto_backup_remote` - 远程备份开关
- `auto_backup_retention` - 备份保留天数
- `health_check_enabled` - 健康检查开关
- `health_check_webhook` - 健康告警Webhook地址
- `log_archive_enabled` - 日志归档开关
- `log_archive_retention` - 日志保留天数

## 系统特性

### 完全独立离线可用
- 无任何外部依赖
- 无应用商店功能
- 无版本检查功能
- 无远程统计功能

### 扩展性
- 保留本地插件安装功能
- 保留本地主题安装功能
- 完善的支付插件架构

## 安装说明

1. 将整个项目文件上传到Web服务器
2. 配置Web服务器伪静态规则（参考原系统）
3. 访问网站首页，按提示完成安装
4. 安装完成后，手动执行扩展SQL：`/kernel/Install/Extension.sql`
5. 登录后台配置支付插件和运维功能

## 使用说明

### 支付插件配置
1. 登录后台
2. 进入「支付管理」→「支付插件」
3. 选择需要的支付插件（易支付/支付宝/PAYJS）
4. 填写相关配置信息并启用

### 自动运维配置
1. 直接修改数据库`maintenance_config`表中的配置项
2. 可通过计划任务调用`Maintenance`类的方法实现自动化
   - 数据库备份：`Maintenance::backupDatabase()`
   - 健康检查：`Maintenance::healthCheck()`
   - 日志归档：`Maintenance::archiveLogs()`

### 建议的计划任务配置（Cron）
```bash
# 每天凌晨3点备份数据库
0 3 * * * php /path/to/your/site/backup.php

# 每小时进行健康检查
0 * * * * php /path/to/your/site/health_check.php

# 每天凌晨4点归档日志
0 4 * * * php /path/to/your/site/archive_logs.php
```

## 文件清单

### 新增文件
```
/app/Pay/Epay/Config/Info.php
/app/Pay/Epay/Epay.php
/app/Pay/Alipay/Config/Info.php
/app/Pay/Alipay/Alipay.php
/app/Pay/Payjs/Config/Info.php
/app/Pay/Payjs/Payjs.php
/app/Model/Review.php
/app/Service/Maintenance.php
/kernel/Install/Extension.sql
/DEVELOPMENT.md
```

### 删除文件
```
/kernel/Plugin.php
/app/Controller/Admin/Store.php
/app/Controller/Admin/Api/Store.php
/app/View/Admin/Store/Developer.html
/app/View/Admin/Store/Store.html
```

### 修改文件
```
/app/View/Admin/Header.html
/kernel/Kernel.php
```

## 技术支持

本版本为独立二次开发版本，所有功能与原系统保持兼容，仅移除了云端相关功能和新增了业务功能。
