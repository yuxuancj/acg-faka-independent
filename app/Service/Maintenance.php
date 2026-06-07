<?php
declare(strict_types=1);

namespace App\Service;

use Kernel\Util\Context;
use Kernel\Util\Date;
use PDO;

class Maintenance
{
    /**
     * 备份数据库
     * @return string|null 备份文件路径，失败返回null
     */
    public static function backupDatabase(): ?string
    {
        try {
            $config = config('database');
            $backupDir = BASE_PATH . '/runtime/backup/';
            if (!is_dir($backupDir)) {
                mkdir($backupDir, 0755, true);
            }

            $fileName = 'backup_' . date('Ymd_His') . '.sql';
            $filePath = $backupDir . $fileName;

            $dsn = "mysql:host={$config['host']};dbname={$config['database']};charset=utf8mb4";
            $pdo = new PDO($dsn, $config['username'], $config['password'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
            ]);

            $tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
            $sql = "-- Database backup generated on " . date('Y-m-d H:i:s') . "\n";
            $sql .= "-- Database: {$config['database']}\n\n";
            $sql .= "SET FOREIGN_KEY_CHECKS = 0;\n\n";

            foreach ($tables as $table) {
                $sql .= "-- Table structure for `$table`\n";
                $createTable = $pdo->query("SHOW CREATE TABLE `$table`")->fetch(PDO::FETCH_ASSOC);
                $sql .= $createTable['Create Table'] . ";\n\n";
                
                $sql .= "-- Dumping data for `$table`\n";
                $rows = $pdo->query("SELECT * FROM `$table`")->fetchAll(PDO::FETCH_ASSOC);
                foreach ($rows as $row) {
                    $values = array_map(function($value) use ($pdo) {
                        return $value === null ? 'NULL' : $pdo->quote($value);
                    }, $row);
                    $sql .= "INSERT INTO `$table` VALUES (" . implode(', ', $values) . ");\n";
                }
                $sql .= "\n";
            }

            $sql .= "SET FOREIGN_KEY_CHECKS = 1;\n";
            file_put_contents($filePath, $sql);

            // 清理旧备份
            self::cleanOldBackups($backupDir, (int)self::getConfig('auto_backup_retention', 7));

            return $filePath;
        } catch (\Exception $e) {
            \Kernel\Util\Log::inst()->error('Database backup failed: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * 清理旧备份
     * @param string $dir
     * @param int $days
     */
    private static function cleanOldBackups(string $dir, int $days): void
    {
        $files = glob($dir . 'backup_*.sql');
        $now = time();
        $expireTime = $now - ($days * 86400);

        foreach ($files as $file) {
            if (filemtime($file) < $expireTime) {
                unlink($file);
            }
        }
    }

    /**
     * 运行健康检查
     * @return array
     */
    public static function healthCheck(): array
    {
        $checks = [
            'database' => self::checkDatabase(),
            'disk_space' => self::checkDiskSpace(),
            'php_extensions' => self::checkPhpExtensions(),
        ];

        $isHealthy = !in_array(false, $checks, true);

        if (!$isHealthy) {
            self::sendHealthAlert($checks);
        }

        return [
            'healthy' => $isHealthy,
            'checks' => $checks,
            'time' => Date::current()
        ];
    }

    /**
     * 检查数据库连接
     * @return bool
     */
    private static function checkDatabase(): bool
    {
        try {
            $config = config('database');
            $dsn = "mysql:host={$config['host']};dbname={$config['database']};charset=utf8mb4";
            new PDO($dsn, $config['username'], $config['password'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_TIMEOUT => 5
            ]);
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * 检查磁盘空间
     * @return bool
     */
    private static function checkDiskSpace(): bool
    {
        $freeSpace = disk_free_space(BASE_PATH);
        $requiredSpace = 100 * 1024 * 1024; // 100MB
        return $freeSpace > $requiredSpace;
    }

    /**
     * 检查必要的PHP扩展
     * @return bool
     */
    private static function checkPhpExtensions(): bool
    {
        $requiredExtensions = ['pdo', 'pdo_mysql', 'json', 'mbstring', 'gd'];
        foreach ($requiredExtensions as $ext) {
            if (!extension_loaded($ext)) {
                return false;
            }
        }
        return true;
    }

    /**
     * 发送健康告警
     * @param array $checks
     */
    private static function sendHealthAlert(array $checks): void
    {
        $webhook = self::getConfig('health_check_webhook', '');
        if (empty($webhook)) {
            return;
        }

        $message = "⚠️ 系统健康检查告警\n";
        $message .= "时间: " . Date::current() . "\n";
        $message .= "状态: 异常\n";
        
        foreach ($checks as $key => $status) {
            $message .= "- {$key}: " . ($status ? '正常' : '异常') . "\n";
        }

        try {
            $ch = curl_init($webhook);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['content' => $message]));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Content-Type: application/json'
            ]);
            curl_exec($ch);
            curl_close($ch);
        } catch (\Exception $e) {
            // 静默失败
        }
    }

    /**
     * 归档旧日志
     */
    public static function archiveLogs(): void
    {
        $logDir = BASE_PATH . '/runtime/log/';
        if (!is_dir($logDir)) {
            return;
        }

        $retentionDays = (int)self::getConfig('log_archive_retention', 30);
        $now = time();
        $expireTime = $now - ($retentionDays * 86400);

        $files = new \RecursiveIteratorIterator(
            new \RecursiveDirectoryIterator($logDir),
            \RecursiveIteratorIterator::SELF_FIRST
        );

        foreach ($files as $file) {
            if ($file->isFile() && $file->getMTime() < $expireTime) {
                unlink($file->getPathname());
            }
        }
    }

    /**
     * 获取运维配置
     * @param string $key
     * @param mixed $default
     * @return mixed
     */
    public static function getConfig(string $key, mixed $default = null): mixed
    {
        try {
            $config = \App\Model\Config::query()->where('key', $key)->first();
            return $config ? $config->value : $default;
        } catch (\Exception $e) {
            return $default;
        }
    }
}
