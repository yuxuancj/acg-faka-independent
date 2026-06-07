<?php
/**
 * 优惠券模型
 */
namespace App\Model;

class Coupon extends Model
{
    protected $table = 'coupon';
    
    const TYPE_FIXED = 1;
    const TYPE_DISCOUNT = 2;
    const TYPE_FREE = 3;
    
    /**
     * 关联用户优惠券
     */
    public function userCoupons()
    {
        return $this->hasMany(UserCoupon::class);
    }
    
    /**
     * 获取可用优惠券
     */
    public static function getAvailableCoupons()
    {
        $now = date('Y-m-d H:i:s');
        $query = self::where('status', 1)
            ->whereRaw('(total_num = 0 OR used_num < total_num)');
        
        if (self::where('start_time', 'IS NOT NULL')->exists()) {
            $query->where(function($q) use ($now) {
                $q->where('start_time', '<=', $now)
                  ->orWhere('start_time', null);
            });
        }
        
        if (self::where('end_time', 'IS NOT NULL')->exists()) {
            $query->where(function($q) use ($now) {
                $q->where('end_time', '>=', $now)
                  ->orWhere('end_time', null);
            });
        }
        
        return $query->orderBy('sort', 'asc')->get();
    }
}
