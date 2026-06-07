#!/bin/bash

# ACG-Faka 支付功能专项测试脚本
# 测试所有支付插件的集成情况

set -e

echo "=========================================="
echo "  支付功能专项测试"
echo "=========================================="
echo ""

# 检查易支付插件
echo "1. 易支付（Epay）插件测试"
echo "----------------------------------"
if [ -f "app/Pay/Epay/Epay.php" ]; then
    echo "✅ 易支付插件文件存在"
    
    # 检查配置
    if [ -f "app/Pay/Epay/Config/Info.php" ]; then
        echo "✅ 易支付配置信息存在"
        
        # 检查必要配置项
        if grep -q "api_url" app/Pay/Epay/Config/Info.php && \
           grep -q "pid" app/Pay/Epay/Config/Info.php && \
           grep -q "key" app/Pay/Epay/Config/Info.php; then
            echo "✅ 易支付必需配置项完整"
        else
            echo "❌ 易支付配置项不完整"
        fi
    else
        echo "❌ 易支付配置文件不存在"
    fi
    
    # 检查核心类
    if grep -q "class Epay extends Base implements Pay" app/Pay/Epay/Epay.php; then
        echo "✅ 易支付核心类定义正确"
    else
        echo "❌ 易支付核心类定义错误"
    fi
    
    # 检查必需方法
    if grep -q "function trade()" app/Pay/Epay/Epay.php && \
       grep -q "function verify()" app/Pay/Epay/Epay.php && \
       grep -q "function tradeNo()" app/Pay/Epay/Epay.php; then
        echo "✅ 易支付必需方法完整"
    else
        echo "❌ 易支付必需方法缺失"
    fi
else
    echo "❌ 易支付插件文件不存在"
fi

echo ""

# 检查支付宝插件
echo "2. 支付宝（Alipay）插件测试"
echo "----------------------------------"
if [ -f "app/Pay/Alipay/Alipay.php" ]; then
    echo "✅ 支付宝插件文件存在"
    
    # 检查配置
    if [ -f "app/Pay/Alipay/Config/Info.php" ]; then
        echo "✅ 支付宝配置信息存在"
        
        # 检查必要配置项
        if grep -q "app_id" app/Pay/Alipay/Config/Info.php && \
           grep -q "merchant_private_key" app/Pay/Alipay/Config/Info.php && \
           grep -q "alipay_public_key" app/Pay/Alipay/Config/Info.php; then
            echo "✅ 支付宝必需配置项完整"
        else
            echo "❌ 支付宝配置项不完整"
        fi
    else
        echo "❌ 支付宝配置文件不存在"
    fi
    
    # 检查核心类
    if grep -q "class Alipay extends Base implements Pay" app/Pay/Alipay/Alipay.php; then
        echo "✅ 支付宝核心类定义正确"
    else
        echo "❌ 支付宝核心类定义错误"
    fi
    
    # 检查必需方法
    if grep -q "function trade()" app/Pay/Alipay/Alipay.php && \
       grep -q "function verify()" app/Pay/Alipay/Alipay.php && \
       grep -q "function generateSign()" app/Pay/Alipay/Alipay.php; then
        echo "✅ 支付宝必需方法完整"
    else
        echo "❌ 支付宝必需方法缺失"
    fi
    
    # 检查支付方式
    if grep -q "alipay.trade.wap.pay" app/Pay/Alipay/Alipay.php && \
       grep -q "alipay.trade.page.pay" app/Pay/Alipay/Alipay.php; then
        echo "✅ 支持电脑网站支付和手机网站支付"
    else
        echo "❌ 支付方式支持不完整"
    fi
else
    echo "❌ 支付宝插件文件不存在"
fi

echo ""

# 检查PAYJS插件
echo "3. PAYJS插件测试"
echo "----------------------------------"
if [ -f "app/Pay/Payjs/Payjs.php" ]; then
    echo "✅ PAYJS插件文件存在"
    
    # 检查配置
    if [ -f "app/Pay/Payjs/Config/Info.php" ]; then
        echo "✅ PAYJS配置信息存在"
        
        # 检查必要配置项
        if grep -q "mchid" app/Pay/Payjs/Config/Info.php && \
           grep -q "key" app/Pay/Payjs/Config/Info.php; then
            echo "✅ PAYJS必需配置项完整"
        else
            echo "❌ PAYJS配置项不完整"
        fi
    else
        echo "❌ PAYJS配置文件不存在"
    fi
    
    # 检查核心类
    if grep -q "class Payjs extends Base implements Pay" app/Pay/Payjs/Payjs.php; then
        echo "✅ PAYJS核心类定义正确"
    else
        echo "❌ PAYJS核心类定义错误"
    fi
    
    # 检查必需方法
    if grep -q "function trade()" app/Pay/Payjs/Payjs.php && \
       grep -q "function verify()" app/Pay/Payjs/Payjs.php && \
       grep -q "function generateSign()" app/Pay/Payjs/Payjs.php; then
        echo "✅ PAYJS必需方法完整"
    else
        echo "❌ PAYJS必需方法缺失"
    fi
    
    # 检查PAYJS API调用
    if grep -q "payjs.cn" app/Pay/Payjs/Payjs.php; then
        echo "✅ PAYJS API地址正确"
    else
        echo "❌ PAYJS API地址错误"
    fi
else
    echo "❌ PAYJS插件文件不存在"
fi

echo ""

# 检查支付基类
echo "4. 支付基类测试"
echo "----------------------------------"
if [ -f "app/Pay/Base.php" ]; then
    echo "✅ 支付基类文件存在"
    
    # 检查接口实现
    if grep -q "interface Pay" app/Pay/Pay.php; then
        echo "✅ Pay接口定义存在"
    else
        echo "❌ Pay接口定义不存在"
    fi
    
    # 检查基类属性
    if grep -q "public float \$amount" app/Pay/Base.php && \
       grep -q "public string \$tradeNo" app/Pay/Base.php && \
       grep -q "public array \$config" app/Pay/Base.php; then
        echo "✅ 支付基类属性定义正确"
    else
        echo "❌ 支付基类属性定义错误"
    fi
    
    # 检查工具方法
    if grep -q "function log()" app/Pay/Base.php && \
       grep -q "function http()" app/Pay/Base.php; then
        echo "✅ 支付基类工具方法存在"
    else
        echo "❌ 支付基类工具方法缺失"
    fi
else
    echo "❌ 支付基类文件不存在"
fi

echo ""
echo "=========================================="
echo "  支付插件测试完成"
echo "=========================================="
