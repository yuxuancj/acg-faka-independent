<?php
/**
 * 用户优惠券模型
 */
namespace App\Model;

class UserCoupon extends Model
{
    protected $table = 'user_coupon';
    
    const STATUS_UNUSED = 0;
    const STATUS_USED = 1;
    const STATUS_EXPIRED = 2;
    
    /**
     * 关联用户
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    
    /**
     * 关联优惠券
     */
    public function coupon()
    {
        return $this->belongsTo(Coupon::class);
    }
}
