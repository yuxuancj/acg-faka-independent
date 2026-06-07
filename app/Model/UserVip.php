<?php
declare(strict_types=1);

namespace App\Model;

/**
 * 用户VIP记录模型
 */
class UserVip extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'user_vip';
    
    public $timestamps = false;
    
    protected $casts = [
        'start_time' => 'datetime',
        'end_time' => 'datetime',
    ];
    
    /**
     * 用户
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    
    /**
     * VIP卡
     */
    public function vipCard()
    {
        return $this->belongsTo(VipCard::class, 'vip_card_id');
    }
    
    /**
     * 是否有效
     */
    public function isActive(): bool
    {
        return $this->status == 1 && $this->end_time > now();
    }
    
    /**
     * 获取用户当前有效的VIP
     */
    public static function getUserActiveVip(int $userId): ?self
    {
        return self::where('user_id', $userId)
            ->where('status', 1)
            ->where('end_time', '>', now())
            ->orderBy('end_time', 'desc')
            ->first();
    }
    
    /**
     * 获取用户VIP折扣
     */
    public static function getUserDiscount(int $userId): float
    {
        $vip = self::getUserActiveVip($userId);
        if ($vip && $vip->vipCard) {
            return (float)$vip->vipCard->discount;
        }
        return 1.0;
    }
}
