<?php
/**
 * 数据库备份脚本
 * 可通过命令行或Web访问执行
 */

define('BASE_PATH', __DIR__ . '/');

// 检查是否通过CLI运行
$isCli = php_sapi_name() === 'cli';

try {
    // 加载框架
    require_once BASE_PATH . '/kernel/Kernel.php';
    
    // 执行备份
    $backupFile = \App\Service\Maintenance::backupDatabase();
    
    if ($backupFile) {
        $message = "数据库备份成功！\n备份文件：" . $backupFile . "\n文件大小：" . round(filesize($backupFile) / 1024 / 1024, 2) . " MB\n";
        if ($isCli) {
            echo $message;
        } else {
            echo nl2br($message);
        }
        exit(0);
    } else {
        $message = "数据库备份失败！请检查日志。\n";
        if ($isCli) {
            echo $message;
        } else {
            echo nl2br($message);
        }
        exit(1);
    }
} catch (Exception $e) {
    $message = "备份出错：" . $e->getMessage() . "\n";
    if ($isCli) {
        echo $message;
    } else {
        echo nl2br($message);
    }
    exit(1);
}
