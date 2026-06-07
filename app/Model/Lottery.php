<?php
/**
 * 积分抽奖模型
 */
namespace App\Model;

class Lottery extends Model
{
    protected $table = 'lottery';
    
    const TYPE_POINTS = 1;
    const TYPE_COUPON = 2;
    const TYPE_CARD = 3;
    
    /**
     * 获取可用奖品
     */
    public static function getAvailablePrizes()
    {
        return self::where('status', 1)
            ->whereRaw('(stock = -1 OR stock > 0)')
            ->orderBy('sort', 'asc')
            ->get();
    }
}
