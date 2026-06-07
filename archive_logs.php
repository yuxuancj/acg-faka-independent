<?php
/**
 * 日志归档脚本
 * 可通过命令行或Web访问执行
 */

define('BASE_PATH', __DIR__ . '/');

// 检查是否通过CLI运行
$isCli = php_sapi_name() === 'cli';

try {
    // 加载框架
    require_once BASE_PATH . '/kernel/Kernel.php';
    
    // 执行日志归档
    \App\Service\Maintenance::archiveLogs();
    
    $message = "日志归档完成！\n";
    if ($isCli) {
        echo $message;
    } else {
        echo nl2br($message);
    }
    exit(0);
} catch (Exception $e) {
    $message = "日志归档出错：" . $e->getMessage() . "\n";
    if ($isCli) {
        echo $message;
    } else {
        echo nl2br($message);
    }
    exit(1);
}
