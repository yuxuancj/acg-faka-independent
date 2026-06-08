<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>安装程序</title>
    <script src="/assets/static/jquery.min.js"></script>
    <script src="/assets/static/layer/layer.js"></script>
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
            font-family: 微软雅黑, serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
            width: 100%;
            max-width: 500px;
            margin: 50px auto;
            background: rgba(255,255,255,0.95);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
        }
        .steps {
            list-style: none;
            padding: 0;
            display: flex;
            justify-content: center;
            margin-bottom: 30px;
        }
        .steps li {
            margin: 0 15px;
            padding-bottom: 10px;
            color: #999;
            border-bottom: 2px solid transparent;
        }
        .steps li.active {
            color: #ff6b9d;
            border-bottom-color: #ff6b9d;
        }
        h3 {
            text-align: center;
            color: #ff6b9d;
            margin-bottom: 20px;
        }
        .gridtable {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        .gridtable th, .gridtable td {
            padding: 10px;
            border: 1px solid #ffd6d6;
            text-align: center;
        }
        .gridtable th {
            background: #ffeaea;
        }
        input {
            display: block;
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            box-sizing: border-box;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
        }
        input:focus {
            outline: none;
            border-color: #ff6b9d;
        }
        .button {
            background: #ff6b9d;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 30px;
            cursor: pointer;
            font-size: 16px;
            display: block;
            margin: 20px auto;
            transition: all 0.3s;
        }
        .button:hover {
            background: #ff4d8a;
            transform: translateY(-2px);
        }
        .button:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        .disabled {
            background: #999 !important;
            cursor: not-allowed;
        }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
    </style>
</head>
<body>
<div class="container">
    <ul class="steps">
        <li class="active" data-step="0">🚜 环境检查</li>
        <li data-step="1">📀 数据库配置</li>
        <li data-step="2">🔐 管理员设置</li>
    </ul>
    
    <form class="install-form">
        <!-- 步骤0: 环境检查 -->
        <div class="section" data-step="0">
            <h3>程序版本：v3.4.9</h3>
            <table class="gridtable">
                <tr><th>依赖模块</th><th>是否支持</th></tr>
                <tr><td>php-8.0+</td><td><span id="php_version" class="error">检测中...</span></td></tr>
                <tr><td>gd</td><td><span id="ext_gd" class="error">检测中...</span></td></tr>
                <tr><td>curl</td><td><span id="ext_curl" class="error">检测中...</span></td></tr>
                <tr><td>pdo_mysql</td><td><span id="ext_pdo_mysql" class="error">检测中...</span></td></tr>
                <tr><td>json</td><td><span id="ext_json" class="error">检测中...</span></td></tr>
                <tr><td>zip</td><td><span id="ext_zip" class="error">检测中...</span></td></tr>
            </table>
            <div id="btn_step0" class="disabled" onclick="nextStep(0)">👿 请检查环境</div>
        </div>

        <!-- 步骤1: 数据库配置 -->
        <div class="section" data-step="1" style="display:none;">
            <h3>配置数据库信息</h3>
            <input type="text" name="host" placeholder="数据库地址" value="127.0.0.1">
            <input type="text" name="database" placeholder="数据库名称" required>
            <input type="text" name="username" placeholder="数据库账号" required>
            <input type="password" name="password" placeholder="数据库密码" required>
            <input type="text" name="prefix" placeholder="数据库前缀" value="acg_">
            <div class="button" onclick="nextStep(1)">下一步</div>
        </div>

        <!-- 步骤2: 管理员设置 -->
        <div class="section" data-step="2" style="display:none;">
            <h3>设置管理员信息</h3>
            <input type="email" name="email" placeholder="管理员邮箱" required>
            <input type="text" name="nickname" placeholder="昵称" required>
            <input type="password" name="login_password" placeholder="登录密码" required>
            <input type="password" name="login_re_password" placeholder="确认密码" required>
            <div class="button" onclick="install()">立即安装</div>
        </div>

        <!-- 步骤3: 安装完成 -->
        <div class="section" data-step="3" style="display:none;">
            <h3>🎉 安装成功！</h3>
            <p style="text-align:center;color:#666;">恭喜您，系统安装完成！</p>
            <p style="text-align:center;margin-top:20px;"><a href="/admin/authentication/login" style="color:#ff6b9d;">点击登录后台</a></p>
        </div>
    </form>
</div>

<script>
var currentStep = 0;
var canInstall = false;

// 检测环境
$(document).ready(function() {
    $.getJSON('/install/check_env', function(data) {
        if (data.php_ok) {
            $('#php_version').html('<span class="success">✓ ' + data.php_version + '</span>');
        } else {
            $('#php_version').html('<span class="error">✗ 需要PHP 8.0+</span>');
        }
        
        var exts = ['gd', 'curl', 'pdo_mysql', 'json', 'zip'];
        exts.forEach(function(ext) {
            if (data.exts[ext]) {
                $('#ext_' + ext).html('<span class="success">✓</span>');
            } else {
                $('#ext_' + ext).html('<span class="error">✗</span>');
            }
        });
        
        canInstall = data.can_install;
        if (canInstall) {
            $('#btn_step0').removeClass('disabled').addClass('button');
            $('#btn_step0').html('下一步');
        }
    }).fail(function() {
        alert('环境检测失败，请检查服务器配置');
    });
});

function nextStep(step) {
    if (step == 0 && !canInstall) return;
    
    if (step == 1) {
        // 验证数据库信息
        var host = $('input[name=host]').val();
        var database = $('input[name=database]').val();
        var username = $('input[name=username]').val();
        var password = $('input[name=password]').val();
        
        if (!database) { layer.msg('请填写数据库名称'); return; }
        if (!username) { layer.msg('请填写数据库账号'); return; }
    }
    
    $('[data-step=' + currentStep + ']').hide();
    $('[data-step=' + (step + 1) + ']').show();
    $('.steps li').removeClass('active');
    $('.steps li[data-step=' + (step + 1) + ']').addClass('active');
    currentStep = step + 1;
}

function install() {
    var email = $('input[name=email]').val();
    var nickname = $('input[name=nickname]').val();
    var pwd1 = $('input[name=login_password]').val();
    var pwd2 = $('input[name=login_re_password]').val();
    
    if (!email) { layer.msg('请填写邮箱'); return; }
    if (!nickname) { layer.msg('请填写昵称'); return; }
    if (!pwd1) { layer.msg('请填写密码'); return; }
    if (pwd1 != pwd2) { layer.msg('两次密码不一致'); return; }
    
    $('.button').attr('disabled', true).html('安装中...');
    
    $.post('/install/submit', $('.install-form').serialize(), function(res) {
        if (res.code == 200) {
            $('[data-step=' + currentStep + ']').hide();
            $('[data-step=3]').show();
            $('.steps li').removeClass('active');
        } else {
            layer.msg(res.msg);
            $('.button').attr('disabled', false).html('立即安装');
        }
    }, 'json').fail(function() {
        layer.msg('安装失败，请检查网络');
        $('.button').attr('disabled', false).html('立即安装');
    });
}
</script>
</body>
</html>