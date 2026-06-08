<?php
// 诊断脚本 - 检查安装页面是否正常
error_reporting(E_ALL);
ini_set('display_errors', '1');

require 'vendor/autoload.php';
require 'kernel/Helper.php';

echo "<h2>安装页面诊断</h2>";

// 检查控制器是否存在
echo "<p><strong>1. 检查控制器:</strong></p>";
echo "<p>Controller: App\\Controller\\Install</p>";
echo "<p>存在: ".(class_exists('App\\Controller\\Install') ? '✓' : '✗')."</p>";

// 检查方法是否存在
echo "<p><strong>2. 检查方法:</strong></p>";
echo "<p>Method: step</p>";
if (class_exists('App\\Controller\\Install')) {
    $instance = new App\Controller\Install();
    echo "<p>存在: ".(method_exists($instance, 'step') ? '✓' : '✗')."</p>";
}

// 检查视图文件
echo "<p><strong>3. 检查视图文件:</strong></p>";
$viewPath = BASE_PATH . "/app/View/Install.html";
echo "<p>路径: $viewPath</p>";
echo "<p>存在: ".(file_exists($viewPath) ? '✓' : '✗')."</p>";

// 检查runtime目录
echo "<p><strong>4. 检查runtime目录:</strong></p>";
$dirs = [
    BASE_PATH . '/runtime',
    BASE_PATH . '/runtime/view/cache',
    BASE_PATH . '/runtime/view/compile',
];
foreach ($dirs as $dir) {
    $exists = is_dir($dir);
    $writable = $exists ? is_writable($dir) : 'N/A';
    echo "<p>$dir - 存在: " . ($exists ? '✓' : '✗') . " | 可写: " . ($writable === true ? '✓' : ($writable === false ? '✗' : 'N/A')) . "</p>";
}

// 检查Lock文件
echo "<p><strong>5. 检查Lock文件:</strong></p>";
$lockPath = BASE_PATH . "/kernel/Install/Lock";
echo "<p>路径: $lockPath</p>";
echo "<p>存在: ".(file_exists($lockPath) ? '✓ (已安装)' : '✗ (未安装)')."</p>";

echo "<p><strong>6. PHP版本:</strong> " . phpversion() . "</p>";

echo "<p><strong>7. 尝试直接调用安装方法:</strong></p>";
try {
    $install = new App\Controller\Install();
    ob_start();
    $result = $install->step();
    $output = ob_get_clean();
    echo "<p>调用成功: ✓</p>";
    echo "<p>输出长度: " . strlen($result) . " 字符</p>";
} catch (Exception $e) {
    echo "<p>调用失败: ✗</p>";
    echo "<p>错误: " . $e->getMessage() . "</p>";
}
?>
