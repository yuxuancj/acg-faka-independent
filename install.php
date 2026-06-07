<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ACG-Faka 安装程序</title>
    <script src="/assets/static/jquery.min.js"></script>
    <script src="/assets/static/layer/layer.js"></script>
    <style>
        html, body {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
            font-family: 微软雅黑, serif;
            background: url("/assets/admin/images/login/bg.jpg") fixed no-repeat;
            background-size: cover;
        }
        .container {
            width: 100%;
            max-width: 500px;
            margin: 0 auto;
            position: relative;
            top: 50%;
            margin-top: -300px;
            background-color: #ffffffd6;
            -webkit-box-shadow: 0 6px 0 0 rgba(0,0,0,.01), 0 15px 32px 0 rgba(0,0,0,.06);
            box-shadow: 0 6px 0 0 rgba(0,0,0,.01), 0 15px 32px 0 rgba(0,0,0,.06);
            border-radius: 10px 10px 0 0;
        }
        .wrapper { width: 100%; margin: 30px 0; }
        .steps { list-style-type: none; margin: 0; padding: 0; text-align: center; }
        .steps li { display: inline-block; margin: 20px; color: #ccc; padding-bottom: 5px; }
        .steps li.is-active { border-bottom: 1px solid pink; color: pink; }
        .form-wrapper .section {
            padding: 0px 20px 30px 20px;
            box-sizing: border-box;
            background-color: #ffffffd6;
            opacity: 0;
            transform: scale(1, 0);
            transform-origin: top center;
            transition: all 0.5s ease-in-out;
            text-align: center;
            position: absolute;
            width: 100%;
            min-height: 300px;
            max-width: 500px;
        }
        .form-wrapper .section.is-active {
            opacity: 1;
            transform: scale(1, 1);
            border-radius: 0 0 10px 10px;
            -webkit-box-shadow: 0 6px 0 0 rgba(0,0,0,.01), 0 15px 32px 0 rgba(0,0,0,.06);
            box-shadow: 0 6px 0 0 rgba(0,0,0,.01), 0 15px 32px 0 rgba(0,0,0,.06);
        }
        .form-wrapper .button, .form-wrapper .submit {
            background-color: pink;
            display: inline-block;
            padding: 8px 30px;
            color: #fff;
            cursor: pointer;
            font-size: 14px !important;
            margin-top: 30px;
        }
        .form-wrapper input[type="text"], .form-wrapper input[type="password"] {
            display: block;
            padding: 10px;
            margin: 10px auto;
            background-color: #f1f1f1;
            border: none;
            width: 70%;
            outline: none;
            font-size: 14px !important;
        }
        .gridtable {
            font-family: verdana, arial, sans-serif;
            font-size: 11px;
            color: #333333;
            border-width: 1px;
            border-color: #f3a5a5;
            border-collapse: collapse;
            margin: 0 auto 20px auto;
            width: 80%;
        }
        table.gridtable th {
            border-width: 1px;
            padding: 8px;
            border-style: solid;
            border-color: #fbc8c880;
            background-color: #ffd6d652;
        }
        .gridtable td {
            border-width: 1px;
            padding: 8px;
            border-style: solid;
            border-color: #fbc8c880;
            background-color: #ffffff;
        }
        .disabled {
            background-color: rgba(128, 128, 128, 0.49) !important;
            display: inline-block;
            padding: 8px 30px;
            color: #fff;
            cursor: pointer;
            font-size: 14px !important;
            margin-top: 30px;
        }
    </style>
</head>
<body>
<div class="container">
    <div class="wrapper">
        <ul class="steps">
            <li class="is-active">🚜 环境检查</li>
            <li>📀 数据库配置</li>
            <li>🔐 管理员设置</li>
        </ul>
        <form class="form-wrapper install-info">
            <fieldset class="section is-active">
                <h3 style="color: pink;font-weight: bold;">程序版本：<b style="color: #ff98d6;">v2.0</b></h3>
                <table class="gridtable">
                    <tr><th>依赖模块</th><th>是否支持</th></tr>
                    <tr><td>php-8.0+</td><td><b style="color: green;">✔</b></td></tr>
                    <tr><td>gd</td><td><b style="color: green;">✔</b></td></tr>
                    <tr><td>curl</td><td><b style="color: green;">✔</b></td></tr>
                    <tr><td>pdo</td><td><b style="color: green;">✔</b></td></tr>
                    <tr><td>pdo_mysql</td><td><b style="color: green;">✔</b></td></tr>
                    <tr><td>json</td><td><b style="color: green;">✔</b></td></tr>
                    <tr><td>session</td><td><b style="color: green;">✔</b></td></tr>
                    <tr><td>zip</td><td><b style="color: green;">✔</b></td></tr>
                </table>
                <div class="button">下一步</div>
            </fieldset>
            <fieldset class="section">
                <h3 style="color: pink;font-weight: bold;">配置您的数据库信息</h3>
                <input type="text" name="host" placeholder="数据库地址" value="127.0.0.1">
                <input type="text" name="database" placeholder="数据库名称">
                <input type="text" name="username" placeholder="数据库账号">
                <input type="password" name="password" placeholder="数据库密码">
                <input type="text" name="prefix" placeholder="数据库前缀" value="acg_">
                <div class="button">下一步</div>
            </fieldset>
            <fieldset class="section">
                <h3 style="color: pink;font-weight: bold;">请设置管理员邮箱和密码</h3>
                <input type="text" name="email" placeholder="管理员邮箱">
                <input type="text" name="nickname" placeholder="昵称">
                <input type="password" name="login_password" placeholder="登录密码">
                <input type="password" name="login_re_password" placeholder="确认登录密码">
                <input class="submit prevButton" type="button" value="上一步">
                <input class="submit button installButton" type="button" value="立即安装">
            </fieldset>
            <fieldset class="section">
                <h3 style="color: pink;font-weight: bold;margin-top: 100px;">恭喜，安装成功！<a href="/admin/authentication/login" style="font-size: 17px;color: #0C84D1;">登录</a></h3>
            </fieldset>
        </form>
    </div>
</div>
<script>
$(document).ready(function () {
    let getValue = function (name) {
        return $('input[name=' + name + ']').val();
    }
    $('.prevButton').click(function () {
        var button = $(this);
        var currentSection = button.parents(".section");
        var currentSectionIndex = currentSection.index();
        var headerSection = $('.steps li').eq(currentSectionIndex);
        currentSection.removeClass("is-active").prev().addClass("is-active");
        headerSection.removeClass("is-active").prev().addClass("is-active");
    });
    $(".form-wrapper .button").click(function () {
        var button = $(this);
        var currentSection = button.parents(".section");
        var currentSectionIndex = currentSection.index();
        var headerSection = $('.steps li').eq(currentSectionIndex);
        let host = getValue('host');
        let database = getValue('database');
        let username = getValue('username');
        let password = getValue('password');
        let prefix = getValue('prefix');
        let email = getValue('email');
        let nickname = getValue('nickname');
        let login_password = getValue('login_password');
        let login_re_password = getValue('login_re_password');
        if (currentSectionIndex == 0) {
            currentSection.removeClass("is-active").next().addClass("is-active");
            headerSection.removeClass("is-active").next().addClass("is-active");
        }
        if (currentSectionIndex == 1) {
            if (database == '') { layer.msg("请填写数据库名称"); return; }
            if (username == '') { layer.msg("请填写数据库账号"); return; }
            if (password == '') { layer.msg("请填写数据库密码"); return; }
            currentSection.removeClass("is-active").next().addClass("is-active");
            headerSection.removeClass("is-active").next().addClass("is-active");
        }
        if (currentSectionIndex == 2) {
            if (email == '') { layer.msg("请设置管理员邮箱"); return; }
            if (nickname == '') { layer.msg("昵称不能为空"); return; }
            if (login_password == '') { layer.msg("请设置登录密码"); return; }
            if (login_re_password == '') { layer.msg("请再次输入登录密码"); return; }
            if (login_password != login_re_password) { layer.msg("两次密码输入不一致"); return; }
            let installButton = $('.installButton');
            installButton.attr('disabled', true);
            installButton.css('background-color', 'rgba(0, 0, 0, 0.2)');
            installButton.val('正在安装..');
            $.post('/install_submit.php', $('.install-info').serialize(), res => {
                if (res.code == 200) {
                    currentSection.removeClass("is-active").next().addClass("is-active");
                    headerSection.removeClass("is-active").next().addClass("is-active");
                    $(".form-wrapper").submit(function (e) { e.preventDefault(); });
                } else {
                    layer.msg(res.msg);
                    installButton.attr('disabled', false);
                    installButton.css('background-color', 'pink');
                    installButton.val('重新安装');
                }
            });
        }
    });
});
</script>
</body>
</html>
