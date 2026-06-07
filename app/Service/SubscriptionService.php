<?php
declare(strict_types=1);

namespace App\Service;

use App\Model\Subscription;
use App\Model\Commodity;
use App\Model\User;

/**
 * 订阅服务
 */
class SubscriptionService
{
    /**
     * 开通订阅
     */
    public function subscribe(int $userId, int $commodityId, int $cycleType, float $price): array
    {
        $commodity = Commodity::find($commodityId);
        if (!$commodity || $commodity->is_subscription != 1) {
            return ['success' => false, 'message' => '商品不支持订阅'];
        }
        
        // 计算下次扣费时间
        $nextPayTime = $this->calcNextPayTime($cycleType);
        
        // 创建订阅记录
        $subscription = Subscription::create([
            'user_id' => $userId,
            'commodity_id' => $commodityId,
            'cycle_type' => $cycleType,
            'price' => $price,
            'next_pay_time' => $nextPayTime,
            'status' => 1,
            'create_time' => now(),
        ]);
        
        return [
            'success' => true,
            'message' => '订阅成功',
            'subscription_id' => $subscription->id,
            'next_pay_time' => $nextPayTime,
        ];
    }
    
    /**
     * 取消订阅
     */
    public function cancel(int $subscriptionId, int $userId): array
    {
        $subscription = Subscription::where('id', $subscriptionId)
            ->where('user_id', $userId)
            ->first();
        
        if (!$subscription) {
            return ['success' => false, 'message' => '订阅不存在'];
        }
        
        $subscription->status = 0;
        $subscription->save();
        
        return ['success' => true, 'message' => '订阅已取消'];
    }
    
    /**
     * 获取用户订阅列表
     */
    public function getUserSubscriptions(int $userId): array
    {
        return Subscription::where('user_id', $userId)
            ->where('status', 1)
            ->with('commodity')
            ->get()
            ->toArray();
    }
    
    /**
     * 处理待扣费的订阅
     */
    public function processDueSubscriptions(): array
    {
        $subscriptions = Subscription::where('status', 1)
            ->where('next_pay_time', '<=', now())
            ->with('commodity')
            ->get();
        
        $results = [];
        foreach ($subscriptions as $subscription) {
            $user = User::find($subscription->user_id);
            if (!$user) {
                continue;
            }
            
            // 尝试扣费
            $balanceService = new BalanceService();
            $result = $balanceService->pay($subscription->user_id, (float)$subscription->price, 0);
            
            if ($result['success']) {
                // 扣费成功，更新下次扣费时间
                $subscription->last_pay_time = now();
                $subscription->next_pay_time = $this->calcNextPayTime($subscription->cycle_type);
                $subscription->save();
                
                $results[] = [
                    'subscription_id' => $subscription->id,
                    'status' => 'success',
                ];
            } else {
                // 余额不足，暂停订阅
                $subscription->status = 0;
                $subscription->save();
                
                // 发送通知（预留）
                
                $results[] = [
                    'subscription_id' => $subscription->id,
                    'status' => 'failed',
                    'reason' => '余额不足',
                ];
            }
        }
        
        return $results;
    }
    
    /**
     * 计算下次扣费时间
     */
    protected function calcNextPayTime(int $cycleType): \Carbon\Carbon
    {
        $now = now();
        
        switch ($cycleType) {
            case 1: // 月付
                return $now->copy()->addMonth();
            case 2: // 季付
                return $now->copy()->addMonths(3);
            case 3: // 年付
                return $now->copy()->addYear();
            default:
                return $now->copy()->addMonth();
        }
    }
}
