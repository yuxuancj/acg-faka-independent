<?php
declare(strict_types=1);

namespace App\Model;

/**
 * IP黑名单模型
 */
class IpBlacklist extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'ip_blacklist';
    
    public $timestamps = false;
    
    /**
     * 检查IP是否在黑名单
     */
    public static function isBlocked(string $ip): bool
    {
        $record = self::where('ip', $ip)->first();
        if (!$record) {
            return false;
        }
        
        // 检查是否过期
        if ($record->expire_time && $record->expire_time < now()) {
            $record->delete();
            return false;
        }
        
        return true;
    }
    
    /**
     * 添加到黑名单
     */
    public static function addBlock(string $ip, string $reason = '', int $minutes = 0, int $type = 1): self
    {
        $expireTime = null;
        if ($minutes > 0) {
            $expireTime = now()->addMinutes($minutes);
        }
        
        return self::updateOrCreate(
            ['ip' => $ip],
            [
                'reason' => $reason,
                'expire_time' => $expireTime,
                'type' => $type,
                'create_time' => now(),
            ]
        );
    }
    
    /**
     * 移除黑名单
     */
    public static function removeBlock(string $ip): bool
    {
        return self::where('ip', $ip)->delete() > 0;
    }
    
    /**
     * 清理过期记录
     */
    public static function cleanExpired(): int
    {
        return self::whereNotNull('expire_time')
            ->where('expire_time', '<', now())
            ->delete();
    }
}
