<?php
// 调试脚本
error_reporting(E_ALL);
ini_set('display_errors', '1');

date_default_timezone_set("Asia/Shanghai");

define("BASE_PATH", __DIR__);

echo "<h2>安装调试信息</h2>";

echo "<p><strong>PHP版本:</strong> " . phpversion() . "</p>";
echo "<p><strong>BASE_PATH:</strong> " . BASE_PATH . "</p>";

// 检查vendor
echo "<p><strong>vendor目录:</strong> " . (is_dir(BASE_PATH . '/vendor') ? '存在' : '不存在') . "</p>";

// 检查Helper.php
echo "<p><strong>Helper.php:</strong> " . (file_exists(BASE_PATH . '/kernel/Helper.php') ? '存在' : '不存在') . "</p>";

// 检查Lock文件
$lockPath = BASE_PATH . '/kernel/Install/Lock';
echo "<p><strong>Lock文件:</strong> " . (file_exists($lockPath) ? '存在 (已安装)' : '不存在 (未安装)') . "</p>";

// 检查View类
require(BASE_PATH . '/vendor/autoload.php');
echo "<p><strong>View类:</strong> " . (class_exists('Kernel\\Util\\View') ? '存在' : '不存在') . "</p>";

// 检查runtime目录
$dirs = [
    BASE_PATH . '/runtime',
    BASE_PATH . '/runtime/view/cache',
    BASE_PATH . '/runtime/view/compile',
];
echo "<p><strong>runtime目录:</strong></p>";
foreach ($dirs as $dir) {
    $exists = is_dir($dir);
    $writable = $exists ? (is_writable($dir) ? '可写' : '不可写') : 'N/A';
    echo "<p>- $dir: " . ($exists ? '存在' : '不存在') . " | $writable</p>";
}

// 检查config/app.php
echo "<p><strong>config/app.php:</strong> " . (file_exists(BASE_PATH . '/config/app.php') ? '存在' : '不存在') . "</p>";

// 尝试加载配置
try {
    require(BASE_PATH . '/kernel/Helper.php');
    $version = config("app")['version'];
    echo "<p><strong>App版本:</strong> $version</p>";
} catch (Exception $e) {
    echo "<p><strong>加载配置失败:</strong> " . $e->getMessage() . "</p>";
}
?>
