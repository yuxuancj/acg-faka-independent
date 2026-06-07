<?php
/**
 * 优惠券服务类
 */
namespace App\Service;

use App\Model\Coupon;
use App\Model\UserCoupon;
use App\Model\User;

class CouponService
{
    /**
     * 生成兑换码
     */
    private function generateCode()
    {
        $chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        $code = '';
        for ($i = 0; $i < 10; $i++) {
            $code .= $chars[rand(0, strlen($chars) - 1)];
        }
        return $code;
    }
    
    /**
     * 用户领取优惠券
     */
    public function receiveCoupon($userId, $couponId)
    {
        $coupon = Coupon::find($couponId);
        if (!$coupon || $coupon->status != 1) {
            return ['success' => false, 'message' => '优惠券不可用'];
        }
        
        $receivedCount = UserCoupon::where('user_id', $userId)
            ->where('coupon_id', $couponId)
            ->count();
        
        if ($coupon->per_user_limit > 0 && $receivedCount >= $coupon->per_user_limit) {
            return ['success' => false, 'message' => '领取已达上限'];
        }
        
        if ($coupon->total_num > 0 && $coupon->used_num >= $coupon->total_num) {
            return ['success' => false, 'message' => '优惠券已领完'];
        }
        
        do {
            $code = $this->generateCode();
        } while (UserCoupon::where('code', $code)->exists());
        
        $expireTime = null;
        if ($coupon->valid_days > 0) {
            $expireTime = date('Y-m-d H:i:s', strtotime("+{$coupon->valid_days} days"));
        } elseif ($coupon->end_time) {
            $expireTime = $coupon->end_time;
        }
        
        $userCoupon = new UserCoupon();
        $userCoupon->user_id = $userId;
        $userCoupon->coupon_id = $couponId;
        $userCoupon->code = $code;
        $userCoupon->expire_time = $expireTime;
        $userCoupon->get_time = date('Y-m-d H:i:s');
        $userCoupon->save();
        
        return ['success' => true, 'code' => $code];
    }
    
    /**
     * 使用兑换码领取
     */
    public function redeemByCode($userId, $code)
    {
        $userCoupon = UserCoupon::where('code', $code)->first();
        if (!$userCoupon) {
            return ['success' => false, 'message' => '兑换码无效'];
        }
        
        if ($userCoupon->user_id != 0) {
            return ['success' => false, 'message' => '兑换码已被使用'];
        }
        
        $userCoupon->user_id = $userId;
        $userCoupon->save();
        
        return ['success' => true];
    }
    
    /**
     * 计算优惠券优惠金额
     */
    public function calculateDiscount($userCoupon, $orderAmount, $productIds = [])
    {
        $coupon = $userCoupon->coupon;
        
        if ($coupon->product_ids) {
            $allowedProductIds = explode(',', $coupon->product_ids);
            if (empty($productIds)) {
                return 0;
            }
            $hasMatch = false;
            foreach ($productIds as $pid) {
                if (in_array($pid, $allowedProductIds)) {
                    $hasMatch = true;
                    break;
                }
            }
            if (!$hasMatch) {
                return 0;
            }
        }
        
        if ($coupon->min_amount > 0 && $orderAmount < $coupon->min_amount) {
            return 0;
        }
        
        if ($coupon->type == Coupon::TYPE_FIXED) {
            return min($coupon->value, $orderAmount);
        } elseif ($coupon->type == Coupon::TYPE_DISCOUNT) {
            return $orderAmount * (1 - $coupon->value / 100);
        }
        
        return 0;
    }
    
    /**
     * 使用优惠券
     */
    public function useCoupon($userCouponId, $orderId)
    {
        $userCoupon = UserCoupon::find($userCouponId);
        if (!$userCoupon || $userCoupon->status != UserCoupon::STATUS_UNUSED) {
            return false;
        }
        
        if ($userCoupon->expire_time && strtotime($userCoupon->expire_time) < time()) {
            $userCoupon->status = UserCoupon::STATUS_EXPIRED;
            $userCoupon->save();
            return false;
        }
        
        $userCoupon->status = UserCoupon::STATUS_USED;
        $userCoupon->order_id = $orderId;
        $userCoupon->use_time = date('Y-m-d H:i:s');
        $userCoupon->save();
        
        $coupon = Coupon::find($userCoupon->coupon_id);
        if ($coupon) {
            $coupon->increment('used_num');
        }
        
        return true;
    }
    
    /**
     * 获取用户可用优惠券
     */
    public function getUserAvailableCoupons($userId)
    {
        return UserCoupon::with('coupon')
            ->where('user_id', $userId)
            ->where('status', UserCoupon::STATUS_UNUSED)
            ->where(function($q) {
                $q->where('expire_time', '>=', date('Y-m-d H:i:s'))
                  ->orWhere('expire_time', null);
            })
            ->orderBy('id', 'desc')
            ->get();
    }
}
