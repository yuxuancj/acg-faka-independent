#!/bin/bash
# =============================================================
# ACG-Faka 独立版 v2.0 - 宝塔一键部署脚本
# =============================================================
# 脚本版本: 1.0
# 更新日期: 2026-06-07
# 系统要求: CentOS 7+ / Ubuntu 18.04+ / Debian 9+
# =============================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 脚本参数
INSTALL_DIR="/www/wwwroot"
DOMAIN=""
DB_NAME=""
DB_USER=""
DB_PASS=""
DB_HOST="localhost"
WEBSITE_NAME="ACG-Faka独立版"

# 打印标题
print_title() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE} ACG-Faka 独立版 v2.0 - 宝塔一键部署${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# 打印信息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

# 打印成功
print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

# 打印警告
print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

# 打印错误
print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用root用户运行此脚本"
        exit 1
    fi
}

# 检查系统
check_system() {
    print_info "检查系统环境..."
    
    if [ -f /etc/redhat-release ]; then
        SYSTEM="CentOS"
    elif [ -f /etc/debian_version ]; then
        SYSTEM="Debian"
    elif [ -f /etc/lsb-release ]; then
        SYSTEM="Ubuntu"
    else
        print_error "不支持的系统！"
        exit 1
    fi
    
    print_success "系统检查通过: $SYSTEM"
}

# 检查宝塔面板
check_baota() {
    print_info "检查宝塔面板..."
    
    if [ -f /www/server/panel/data/default.db ]; then
        print_success "检测到宝塔面板"
        BAOTA_INSTALLED=true
    else
        print_warning "未检测到宝塔面板，将使用LNMP方式安装"
        BAOTA_INSTALLED=false
    fi
}

# 获取用户输入
get_user_input() {
    echo ""
    echo -e "${CYAN}请输入网站配置信息：${NC}"
    echo ""
    
    # 获取域名
    read -p "请输入您的网站域名（例如：faka.example.com）: " DOMAIN
    if [ -z "$DOMAIN" ]; then
        print_error "域名不能为空！"
        exit 1
    fi
    
    # 获取数据库配置
    echo ""
    echo -e "${CYAN}请输入数据库配置信息（留空将自动创建）：${NC}"
    read -p "数据库名（默认为acg_faka）: " DB_NAME_INPUT
    read -p "数据库用户名（默认为acg_faka）: " DB_USER_INPUT
    read -p "数据库密码（将随机生成）: " DB_PASS_INPUT
    read -p "数据库主机（默认为localhost）: " DB_HOST_INPUT
    
    # 设置默认值
    DB_NAME=${DB_NAME_INPUT:-acg_faka}
    DB_USER=${DB_USER_INPUT:-acg_faka}
    DB_HOST=${DB_HOST_INPUT:-localhost}
    
    if [ -z "$DB_PASS_INPUT" ]; then
        # 生成随机密码
        DB_PASS=$(openssl rand -hex 12)
    else
        DB_PASS=$DB_PASS_INPUT
    fi
    
    # 确认信息
    echo ""
    echo -e "${YELLOW}请确认以下配置：${NC}"
    echo "--------------------------------------"
    echo "网站域名: $DOMAIN"
    echo "网站目录: $INSTALL_DIR/$DOMAIN"
    echo "数据库名: $DB_NAME"
    echo "数据库用户: $DB_USER"
    echo "数据库密码: $DB_PASS"
    echo "数据库主机: $DB_HOST"
    echo "--------------------------------------"
    echo ""
    
    read -p "确认继续吗？(y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        print_info "安装已取消"
        exit 0
    fi
}

# 安装依赖
install_dependencies() {
    print_info "安装必要的依赖..."
    
    if [ "$SYSTEM" = "CentOS" ]; then
        yum install -y wget git unzip zip net-tools
    else
        apt-get update
        apt-get install -y wget git unzip zip net-tools
    fi
    
    print_success "依赖安装完成"
}

# 下载源码
download_source() {
    print_info "下载 ACG-Faka 源码..."
    
    cd "$INSTALL_DIR"
    rm -rf "$DOMAIN"
    
    git clone https://github.com/yuxuancj/acg-faka-independent.git "$DOMAIN"
    
    if [ ! -d "$DOMAIN" ]; then
        print_error "源码下载失败！"
        exit 1
    fi
    
    cd "$DOMAIN"
    git checkout v2.0-chenze-full
    
    print_success "源码下载完成"
}

# 设置权限
set_permissions() {
    print_info "设置文件权限..."
    
    chown -R www:www "$INSTALL_DIR/$DOMAIN"
    chmod -R 755 "$INSTALL_DIR/$DOMAIN"
    chmod -R 777 "$INSTALL_DIR/$DOMAIN/runtime"
    chmod -R 777 "$INSTALL_DIR/$DOMAIN/public"
    chmod -R 777 "$INSTALL_DIR/$DOMAIN/install"
    
    print_success "权限设置完成"
}

# 创建数据库
create_database() {
    print_info "创建数据库..."
    
    if [ "$BAOTA_INSTALLED" = true ]; then
        # 使用宝塔数据库管理
        print_warning "请手动在宝塔面板中创建数据库"
        print_info "数据库名: $DB_NAME"
        print_info "数据库用户: $DB_USER"
        print_info "数据库密码: $DB_PASS"
        echo ""
        read -p "数据库创建完成后按回车继续..."
    else
        # 使用本地MySQL
        mysql -u root -p <<MYSQL
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'$DB_HOST';
FLUSH PRIVILEGES;
MYSQL
        
        if [ $? -ne 0 ]; then
            print_error "数据库创建失败！"
            exit 1
        fi
    fi
    
    print_success "数据库配置完成"
}

# 创建宝塔网站
create_baota_site() {
    if [ "$BAOTA_INSTALLED" = true ]; then
        print_info "创建宝塔网站..."
        
        # 检查Python环境
        if command -v python &> /dev/null; then
            PYTHON_CMD="python"
        elif command -v python3 &> /dev/null; then
            PYTHON_CMD="python3"
        else
            print_warning "未检测到Python环境，跳过宝塔自动创建"
            return
        fi
        
        # 使用宝塔API创建网站（需要进一步实现）
        print_warning "请在宝塔面板手动创建网站"
        print_info "网站域名: $DOMAIN"
        print_info "网站根目录: $INSTALL_DIR/$DOMAIN"
        print_info "PHP版本: 8.0+"
        echo ""
        read -p "网站创建完成后按回车继续..."
        
        print_success "网站配置完成"
    fi
}

# 创建Nginx配置
create_nginx_config() {
    print_info "创建Nginx配置..."
    
    if [ "$BAOTA_INSTALLED" = true ]; then
        # 宝塔面板会自动创建配置
        print_info "请在宝塔面板设置伪静态规则"
        cat > "$INSTALL_DIR/$DOMAIN/nginx.txt" <<NGINX
# 伪静态规则
location / {
    if (!-e \$request_filename) {
        rewrite ^(.*)$ /index.php?s=\$1 last;
    }
}

location ~* (runtime|application)/.*\\.php$ {
    deny all;
}
NGINX
        print_success "伪静态规则已生成，请复制到宝塔面板"
    else
        # 直接创建Nginx配置
        cat > /etc/nginx/conf.d/$DOMAIN.conf <<NGINX
server {
    listen 80;
    server_name $DOMAIN;
    root $INSTALL_DIR/$DOMAIN/public;
    index index.php index.html index.htm;
    
    location / {
        try_files \$uri \$uri/ /index.php?s=\$uri&\$args;
    }
    
    location ~ \\.php$ {
        fastcgi_pass unix:/dev/shm/php-cgi.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
    }
    
    location ~* (runtime|application)/.*\\.php$ {
        deny all;
    }
    
    location ~ /\\. {
        deny all;
    }
}
NGINX
        nginx -t && nginx -s reload
    fi
    
    print_success "Nginx配置完成"
}

# 导入数据库
import_database() {
    print_info "导入数据库..."
    
    cd "$INSTALL_DIR/$DOMAIN"
    
    # 查找SQL文件
    if [ -f "kernel/Install/install.sql" ]; then
        SQL_FILE="kernel/Install/install.sql"
    elif [ -f "install/install.sql" ]; then
        SQL_FILE="install/install.sql"
    else
        print_error "找不到安装SQL文件！"
        return
    fi
    
    # 复制配置文件
    if [ -f "config.php.example" ]; then
        cp config.php.example config.php
    fi
    
    if [ -f "config/database.php.example" ]; then
        cp config/database.php.example config/database.php
        
        # 配置数据库
        sed -i "s/'database' => '.*'/'database' => '$DB_NAME'/g" config/database.php
        sed -i "s/'username' => '.*'/'username' => '$DB_USER'/g" config/database.php
        sed -i "s/'password' => '.*'/'password' => '$DB_PASS'/g" config/database.php
        sed -i "s/'hostname' => '.*'/'hostname' => '$DB_HOST'/g" config/database.php
    fi
    
    print_success "数据库配置完成"
    print_warning "请访问 http://$DOMAIN 完成安装向导"
}

# 显示安装信息
show_install_info() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}      ACG-Faka 安装完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${CYAN}网站信息：${NC}"
    echo "  网站地址: http://$DOMAIN"
    echo "  后台地址: http://$DOMAIN/admin"
    echo "  安装目录: $INSTALL_DIR/$DOMAIN"
    echo ""
    echo -e "${CYAN}数据库信息：${NC}"
    echo "  数据库名: $DB_NAME"
    echo "  数据库用户: $DB_USER"
    echo "  数据库密码: $DB_PASS"
    echo "  数据库主机: $DB_HOST"
    echo ""
    echo -e "${CYAN}默认账号：${NC}"
    echo "  管理员账号: admin@acgfaka.test"
    echo "  管理员密码: admin"
    echo ""
    echo -e "${YELLOW}安全提示：${NC}"
    echo "  1. 请立即修改管理员密码"
    echo "  2. 请删除install目录"
    echo "  3. 请配置HTTPS证书"
    echo ""
    echo -e "${CYAN}下一步：${NC}"
    echo "  访问 http://$DOMAIN 完成安装向导"
    echo ""
}

# 主函数
main() {
    print_title
    check_root
    check_system
    check_baota
    get_user_input
    install_dependencies
    download_source
    set_permissions
    create_database
    create_baota_site
    create_nginx_config
    import_database
    show_install_info
}

# 启动安装
main
