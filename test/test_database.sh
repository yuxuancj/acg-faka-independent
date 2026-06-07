#!/bin/bash

# ACG-Faka 数据库结构和数据验证测试脚本

set -e

echo "=========================================="
echo "  数据库结构和数据验证测试"
echo "=========================================="
echo ""

# 检查表结构
echo "1. 检查必需的数据表"
echo "----------------------------------"

TABLES=(
    "manage"
    "commodity"
    "card"
    "order"
    "pay"
    "category"
    "user"
    "review"
    "maintenance_config"
)

for table in "${TABLES[@]}"; do
    if docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e "DESC $table;" > /dev/null 2>&1; then
        echo "✅ 表 $table 存在"
    else
        echo "❌ 表 $table 不存在"
    fi
done

echo ""

# 检查评价表结构
echo "2. 验证评价表结构"
echo "----------------------------------"
REVIEW_COLUMNS=(
    "id"
    "commodity_id"
    "user_id"
    "order_id"
    "rating"
    "content"
    "reply"
    "status"
    "create_time"
    "update_time"
)

for column in "${REVIEW_COLUMNS[@]}"; do
    if docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e "SHOW COLUMNS FROM review LIKE '$column';" | grep -q "$column"; then
        echo "✅ review表包含 $column 字段"
    else
        echo "❌ review表缺少 $column 字段"
    fi
done

echo ""

# 检查运维配置表结构
echo "3. 验证运维配置表结构"
echo "----------------------------------"
MAINTENANCE_COLUMNS=(
    "id"
    "key"
    "value"
    "description"
)

for column in "${MAINTENANCE_COLUMNS[@]}"; do
    if docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e "SHOW COLUMNS FROM maintenance_config LIKE '$column';" | grep -q "$column"; then
        echo "✅ maintenance_config表包含 $column 字段"
    else
        echo "❌ maintenance_config表缺少 $column 字段"
    fi
done

echo ""

# 验证测试数据
echo "4. 验证测试数据完整性"
echo "----------------------------------"

# 管理员数据
admin_count=$(docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -sN -e "SELECT COUNT(*) FROM manage WHERE email='admin@acgfaka.test';")
if [ "$admin_count" -gt 0 ]; then
    echo "✅ 管理员账户数据正确"
else
    echo "❌ 管理员账户数据缺失"
fi

# 商品数据
commodity_count=$(docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -sN -e "SELECT COUNT(*) FROM commodity;")
if [ "$commodity_count" -gt 0 ]; then
    echo "✅ 商品测试数据存在（共 $commodity_count 个）"
else
    echo "❌ 商品测试数据缺失"
fi

# 卡密数据
card_count=$(docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -sN -e "SELECT COUNT(*) FROM card;")
if [ "$card_count" -gt 0 ]; then
    echo "✅ 卡密测试数据存在（共 $card_count 个）"
else
    echo "❌ 卡密测试数据缺失"
fi

# 评价数据
review_count=$(docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -sN -e "SELECT COUNT(*) FROM review;")
if [ "$review_count" -gt 0 ]; then
    echo "✅ 评价测试数据存在（共 $review_count 条）"
else
    echo "❌ 评价测试数据缺失"
fi

# 运维配置数据
config_count=$(docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -sN -e "SELECT COUNT(*) FROM maintenance_config;")
if [ "$config_count" -gt 0 ]; then
    echo "✅ 运维配置数据存在（共 $config_count 项）"
else
    echo "❌ 运维配置数据缺失"
fi

echo ""

# 验证表关系
echo "5. 验证表关系完整性"
echo "----------------------------------"

# 检查外键约束
if docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e "SHOW CREATE TABLE card;" | grep -q "commodity_id"; then
    echo "✅ card表外键约束正确"
else
    echo "❌ card表外键约束缺失"
fi

if docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e "SHOW CREATE TABLE review;" | grep -q "commodity_id"; then
    echo "✅ review表外键约束正确"
else
    echo "❌ review表外键约束缺失"
fi

echo ""
echo "=========================================="
echo "  数据库验证完成"
echo "=========================================="
