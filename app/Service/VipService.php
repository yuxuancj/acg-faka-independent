<?php
declare(strict_types=1);

namespace App\Service;

use App\Model\VipCard;
use App\Model\UserVip;
use App\Model\User;
use App\Model\Order;
use App\Util\Date;

/**
 * VIP会员服务
 */
class VipService
{
    /**
     * 购买VIP
     */
    public function buy(int $userId, int $vipCardId, int $orderId): array
    {
        $vipCard = VipCard::find($vipCardId);
        if (!$vipCard || $vipCard->status != 1) {
            return ['success' => false, 'message' => 'VIP卡不存在或已下架'];
        }
        
        // 检查是否已有VIP
        $existingVip = UserVip::getUserActiveVip($userId);
        
        $startTime = $existingVip && $existingVip->end_time > now() 
            ? $existingVip->end_time 
            : now();
        
        $endTime = $startTime->copy()->addDays($vipCard->days);
        
        // 创建VIP记录
        UserVip::create([
            'user_id' => $userId,
            'vip_card_id' => $vipCardId,
            'order_id' => $orderId,
            'start_time' => $startTime,
            'end_time' => $endTime,
            'status' => 1,
            'create_time' => now(),
        ]);
        
        // 更新用户VIP过期时间
        $user = User::find($userId);
        if ($user) {
            $user->vip_expire_time = $endTime;
            $user->save();
        }
        
        // 更新订单
        $order = Order::find($orderId);
        if ($order) {
            $order->vip_card_id = $vipCardId;
            $order->save();
        }
        
        return [
            'success' => true,
            'message' => 'VIP购买成功',
            'start_time' => $startTime,
            'end_time' => $endTime,
        ];
    }
    
    /**
     * 检查用户VIP状态
     */
    public function check(int $userId): array
    {
        $vip = UserVip::getUserActiveVip($userId);
        
        if (!$vip) {
            return [
                'has_vip' => false,
                'vip_info' => null,
            ];
        }
        
        return [
            'has_vip' => true,
            'vip_info' => [
                'name' => $vip->vipCard->name ?? '',
                'discount' => $vip->vipCard->discount ?? 1.0,
                'points_multiplier' => $vip->vipCard->points_multiplier ?? 1.0,
                'free_shipping' => $vip->vipCard->free_shipping ?? false,
                'start_time' => $vip->start_time,
                'end_time' => $vip->end_time,
                'days_left' => now()->diffInDays($vip->end_time),
            ],
        ];
    }
    
    /**
     * 获取用户VIP折扣
     */
    public function getDiscount(int $userId): float
    {
        $vip = UserVip::getUserActiveVip($userId);
        if ($vip && $vip->vipCard) {
            return (float)$vip->vipCard->discount;
        }
        return 1.0;
    }
    
    /**
     * 获取VIP积分倍率
     */
    public function getPointsMultiplier(int $userId): float
    {
        $vip = UserVip::getUserActiveVip($userId);
        if ($vip && $vip->vipCard) {
            return (float)$vip->vipCard->points_multiplier;
        }
        return 1.0;
    }
    
    /**
     * 清理过期VIP
     */
    public function cleanExpired(): int
    {
        return UserVip::where('status', 1)
            ->where('end_time', '<', now())
            ->update(['status' => 0]);
    }
}
