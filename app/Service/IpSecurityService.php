<?php
declare(strict_types=1);

namespace App\Service;

use App\Model\IpBlacklist;
use App\Util\Client;

/**
 * IP安全服务
 */
class IpSecurityService
{
    protected static array $errorCounts = [];
    
    /**
     * 记录错误
     */
    public static function recordError(string $ip, string $action = 'default'): void
    {
        $key = $ip . '_' . $action;
        
        if (!isset(self::$errorCounts[$key])) {
            self::$errorCounts[$key] = [
                'count' => 0,
                'first_time' => time(),
            ];
        }
        
        self::$errorCounts[$key]['count']++;
        
        // 检查是否达到阈值
        $threshold = (int)Config::get('security.ip_block_threshold', 'security', 5);
        $enabled = (int)Config::get('security.ip_block_enabled', 'security', 1) == 1;
        
        if ($enabled && self::$errorCounts[$key]['count'] >= $threshold) {
            $minutes = (int)Config::get('security.ip_block_minutes', 'security', 1440);
            IpBlacklist::addBlock(
                $ip,
                "触发{$threshold}次异常，系统自动封禁",
                $minutes,
                1
            );
            
            // 记录日志
            \App\Model\ManageLog::log(null, "IP {$ip} 因触发{$threshold}次异常被自动封禁{$minutes}分钟");
            
            // 清空错误计数
            unset(self::$errorCounts[$key]);
        }
    }
    
    /**
     * 检查IP是否被封禁
     */
    public static function isBlocked(string $ip = null): bool
    {
        if (!$ip) {
            $ip = Client::getAddress();
        }
        
        return IpBlacklist::isBlocked($ip);
    }
    
    /**
     * 封禁IP
     */
    public static function block(string $ip, string $reason = '', int $minutes = 0): bool
    {
        IpBlacklist::addBlock($ip, $reason, $minutes, 2);
        return true;
    }
    
    /**
     * 解封IP
     */
    public static function unblock(string $ip): bool
    {
        return IpBlacklist::removeBlock($ip);
    }
}
