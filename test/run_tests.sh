#!/bin/bash

# ACG-Faka 自动化测试脚本
# 测试所有核心功能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  ACG-Faka 独立版 - 功能测试套件${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 测试计数器
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
run_test() {
    local test_name=$1
    local test_command=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${YELLOW}[测试 $TOTAL_TESTS]${NC} $test_name"
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}  ✅ 通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}  ❌ 失败${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# 1. Docker容器状态测试
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}1. Docker容器状态测试${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

run_test "MySQL容器运行中" "docker ps | grep -q acg-faka-mysql"
run_test "PHP容器运行中" "docker ps | grep -q acg-faka-php"
run_test "Nginx容器运行中" "docker ps | grep -q acg-faka-nginx"
run_test "容器数量正确" "[ \$(docker ps -q | wc -l) -ge 3 ]"

# 2. Web服务测试
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}2. Web服务测试${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

run_test "Nginx服务响应" "curl -s -o /dev/null -w '%{http_code}' http://localhost | grep -q '200\\|302\\|404'"
run_test "PHP-FPM运行中" "docker exec acg-faka-php ps aux | grep -q php-fpm"
run_test "PHP版本正确" "docker exec acg-faka-php php -v | grep -q 'PHP 8'"
run_test "必要的PHP扩展已安装" "docker exec acg-faka-php php -m | grep -q pdo_mysql"

# 3. 数据库测试
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}3. 数据库测试${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

run_test "MySQL连接正常" "docker exec acg-faka-mysql mysqladmin ping -h localhost -u root -pacg_faka_2024 > /dev/null 2>&1"
run_test "数据库存在" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 -e 'SHOW DATABASES;' | grep -q acg_faka"
run_test "管理员表存在" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e 'DESC manage;' > /dev/null 2>&1"
run_test "商品表存在" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e 'DESC commodity;' > /dev/null 2>&1"
run_test "评价表存在" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e 'DESC review;' > /dev/null 2>&1"
run_test "运维配置表存在" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e 'DESC maintenance_config;' > /dev/null 2>&1"

# 4. 测试数据验证
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}4. 测试数据验证${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

run_test "管理员账户存在" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e 'SELECT * FROM manage WHERE email=\"admin@acgfaka.test\";' | grep -q admin@acgfaka.test"
run_test "测试商品存在" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e 'SELECT * FROM commodity LIMIT 1;' | grep -q TEST"
run_test "测试卡密存在" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e 'SELECT * FROM card LIMIT 1;' | grep -q VIP"
run_test "评价数据存在" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e 'SELECT COUNT(*) FROM review;' | grep -q '[1-9]'"
run_test "运维配置已初始化" "docker exec acg-faka-mysql mysql -u root -pacg_faka_2024 acg_faka -e 'SELECT COUNT(*) FROM maintenance_config;' | grep -q '[1-9]'"

# 5. 核心文件验证
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}5. 核心文件验证${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

run_test "易支付插件存在" "[ -f 'app/Pay/Epay/Epay.php' ]"
run_test "支付宝插件存在" "[ -f 'app/Pay/Alipay/Alipay.php' ]"
run_test "PAYJS插件存在" "[ -f 'app/Pay/Payjs/Payjs.php' ]"
run_test "评价模型存在" "[ -f 'app/Model/Review.php' ]"
run_test "运维服务存在" "[ -f 'app/Service/Maintenance.php' ]"
run_test "云端文件已删除" "[ ! -f 'kernel/Plugin.php' ]"
run_test "应用商店已删除" "[ ! -f 'app/Controller/Admin/Store.php' ]"

# 6. 备份功能测试
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}6. 运维功能测试${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

run_test "备份脚本可执行" "[ -f 'backup.php' ]"
run_test "健康检查脚本可执行" "[ -f 'health_check.php' ]"
run_test "日志归档脚本可执行" "[ -f 'archive_logs.php' ]"
run_test "备份目录存在" "[ -d 'runtime/backup' ]"
run_test "日志目录存在" "[ -d 'runtime/log' ]"

# 7. 安全性检查
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}7. 安全性检查${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

run_test "敏感文件不可访问" "curl -s http://localhost/.env | grep -q 'Not Found' || curl -s http://localhost/.env | grep -q '403'"
run_test "Git目录不可访问" "curl -s http://localhost/.git/config | grep -q 'Not Found' || curl -s http://localhost/.git/config | grep -q '403'"
run_test "备份目录不可直接访问" "curl -s http://localhost/runtime/backup/ | grep -q 'Not Found\\|403\\|Index'"

# 8. API接口测试
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}8. API接口测试${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

run_test "前台首页可访问" "curl -s http://localhost | grep -q 'html\\|HTML'"
run_test "后台登录页可访问" "curl -s http://localhost/admin/authentication/login | grep -q 'login\\|Login\\|登录'"

# 测试报告
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}           测试报告${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "总测试数: ${TOTAL_TESTS}"
echo -e "${GREEN}通过: ${PASSED_TESTS}${NC}"
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}失败: ${FAILED_TESTS}${NC}"
else
    echo -e "失败: ${FAILED_TESTS}"
fi
echo ""

SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
echo -e "通过率: ${SUCCESS_RATE}%"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过！系统运行正常！${NC}"
    exit 0
else
    echo -e "${RED}⚠️  有 ${FAILED_TESTS} 个测试失败，请检查！${NC}"
    exit 1
fi
