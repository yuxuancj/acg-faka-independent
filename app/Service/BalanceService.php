<?php
declare(strict_types=1);

namespace App\Service;

use App\Model\User;
use App\Model\UserBalanceLog;
use App\Model\Order;

/**
 * 用户余额服务
 */
class BalanceService
{
    /**
     * 获取用户余额
     */
    public function getBalance(int $userId): float
    {
        $user = User::find($userId);
        return $user ? (float)$user->balance : 0.00;
    }
    
    /**
     * 增加余额
     */
    public function increase(int $userId, float $amount, string $description, ?int $orderId = null, int $type = 1): bool
    {
        $user = User::find($userId);
        if (!$user) {
            return false;
        }
        
        $balanceBefore = (float)$user->balance;
        $balanceAfter = $balanceBefore + $amount;
        
        // 更新用户余额
        $user->balance = $balanceAfter;
        $user->save();
        
        // 记录日志
        UserBalanceLog::create([
            'user_id' => $userId,
            'type' => $type,
            'amount' => $amount,
            'balance_before' => $balanceBefore,
            'balance_after' => $balanceAfter,
            'description' => $description,
            'order_id' => $orderId,
            'create_time' => now(),
        ]);
        
        return true;
    }
    
    /**
     * 减少余额
     */
    public function decrease(int $userId, float $amount, string $description, ?int $orderId = null): bool
    {
        $balance = $this->getBalance($userId);
        if ($balance < $amount) {
            return false;
        }
        
        return $this->increase($userId, -$amount, $description, $orderId, 2);
    }
    
    /**
     * 余额支付
     */
    public function pay(int $userId, float $amount, int $orderId): array
    {
        $balance = $this->getBalance($userId);
        
        if ($balance < $amount) {
            return [
                'success' => false,
                'message' => '余额不足',
                'balance' => $balance,
            ];
        }
        
        // 扣款
        $this->decrease($userId, $amount, "订单支付", $orderId);
        
        return [
            'success' => true,
            'message' => '支付成功',
            'balance' => $balance - $amount,
        ];
    }
    
    /**
     * 退款到余额
     */
    public function refund(int $userId, float $amount, int $orderId): bool
    {
        return $this->increase($userId, $amount, "订单退款", $orderId, 3);
    }
    
    /**
     * 管理员调整余额
     */
    public function adjust(int $userId, float $amount, string $description): bool
    {
        $type = $amount > 0 ? 4 : 4;
        return $this->increase($userId, abs($amount), "[管理员]{$description}", null, 4);
    }
    
    /**
     * 获取余额变动记录
     */
    public function getLogs(int $userId, int $page = 1, int $limit = 20): array
    {
        $query = UserBalanceLog::where('user_id', $userId)
            ->orderBy('create_time', 'desc');
        
        $total = $query->count();
        $logs = $query->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get();
        
        return [
            'total' => $total,
            'list' => $logs,
        ];
    }
}
