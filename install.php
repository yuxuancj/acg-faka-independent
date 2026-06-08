<?php
// 独立安装入口 - 绕过框架路由系统
error_reporting(0);
date_default_timezone_set("Asia/Shanghai");

define("BASE_PATH", __DIR__);
require(BASE_PATH . '/vendor/autoload.php');
require(BASE_PATH . '/kernel/Helper.php');

// 确保runtime目录存在
$dirs = [
    BASE_PATH . '/runtime',
    BASE_PATH . '/runtime/view',
    BASE_PATH . '/runtime/view/cache',
    BASE_PATH . '/runtime/view/compile',
    BASE_PATH . '/runtime/plugin'
];
foreach ($dirs as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0777, true);
    }
}

// 如果已安装，跳转到首页
if (file_exists(BASE_PATH . '/kernel/Install/Lock')) {
    header('Location: /');
    exit;
}

// 渲染安装页面
$view = new \Kernel\Util\View();
$data['version'] = config("app")['version'];
echo $view->render("Install.html", $data);
?>
