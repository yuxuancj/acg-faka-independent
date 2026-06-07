<?php
declare(strict_types=1);

namespace App\Model;

/**
 * VIP会员卡模型
 */
class VipCard extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'vip_card';
    
    public $timestamps = false;
    
    protected $casts = [
        'price' => 'decimal:2',
        'discount' => 'decimal:2',
        'points_multiplier' => 'decimal:2',
    ];
    
    /**
     * 获取有效的VIP卡
     */
    public static function getActive()
    {
        return self::where('status', 1)->orderBy('sort')->get();
    }
    
    /**
     * 计算折扣后的价格
     */
    public function getDiscountPrice(float $price): float
    {
        return round($price * $this->discount, 2);
    }
}
