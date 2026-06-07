<?php
/**
 * 健康检查脚本
 * 可通过命令行或Web访问执行
 */

define('BASE_PATH', __DIR__ . '/');

// 检查是否通过CLI运行
$isCli = php_sapi_name() === 'cli';

try {
    // 加载框架
    require_once BASE_PATH . '/kernel/Kernel.php';
    
    // 执行健康检查
    $result = \App\Service\Maintenance::healthCheck();
    
    $output = "系统健康检查\n";
    $output .= "检查时间：" . $result['time'] . "\n";
    $output .= "整体状态：" . ($result['healthy'] ? '✅ 正常' : '❌ 异常') . "\n\n";
    
    foreach ($result['checks'] as $key => $status) {
        $label = match($key) {
            'database' => '数据库连接',
            'disk_space' => '磁盘空间',
            'php_extensions' => 'PHP扩展',
            default => $key
        };
        $output .= "{$label}：" . ($status ? '✅ 正常' : '❌ 异常') . "\n";
    }
    
    if ($isCli) {
        echo $output;
    } else {
        echo nl2br($output);
    }
    
    exit($result['healthy'] ? 0 : 1);
} catch (Exception $e) {
    $message = "健康检查出错：" . $e->getMessage() . "\n";
    if ($isCli) {
        echo $message;
    } else {
        echo nl2br($message);
    }
    exit(1);
}
