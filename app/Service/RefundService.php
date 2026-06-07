<?php
declare(strict_types=1);

namespace App\Service;

use App\Model\Order;
use App\Model\Refund;
use App\Model\Card;
use App\Model\User;
use App\Util\Client;

/**
 * 退款服务
 */
class RefundService
{
    protected BalanceService $balanceService;
    
    public function __construct(BalanceService $balanceService)
    {
        $this->balanceService = $balanceService;
    }
    
    /**
     * 检查是否可申请退款
     */
    public function canRefund(Order $order): array
    {
        // 已退款订单不能再次退款
        if ($order->is_refunded) {
            return ['can' => false, 'reason' => '该订单已退款'];
        }
        
        // 检查订单状态
        if (!in_array($order->status, [2, 3])) { // 2=已支付, 3=已完成
            return ['can' => false, 'reason' => '该订单状态不支持退款'];
        }
        
        // 检查是否在自动退款时间内
        $autoRefundMinutes = (int)Config::get('refund.auto_refund_minutes', 'refund', 30);
        if ($order->auto_refund_deadline && $order->auto_refund_deadline > now()) {
            return ['can' => true, 'deadline' => $order->auto_refund_deadline];
        }
        
        return ['can' => false, 'reason' => '已超过退款时限'];
    }
    
    /**
     * 申请退款
     */
    public function apply(int $userId, int $orderId, string $reason = ''): array
    {
        $order = Order::find($orderId);
        if (!$order) {
            return ['success' => false, 'message' => '订单不存在'];
        }
        
        if ($order->user_id != $userId) {
            return ['success' => false, 'message' => '无权操作此订单'];
        }
        
        $check = $this->canRefund($order);
        if (!$check['can']) {
            return ['success' => false, 'message' => $check['reason']];
        }
        
        // 检查是否已有退款申请
        $existingRefund = Refund::where('order_id', $orderId)
            ->whereIn('status', [0, 1])
            ->first();
        if ($existingRefund) {
            return ['success' => false, 'message' => '该订单已有退款申请'];
        }
        
        // 创建退款记录
        $refundToBalance = (int)Config::get('refund.refund_to_balance', 'refund', 1) == 1;
        
        $refund = Refund::create([
            'order_id' => $orderId,
            'user_id' => $userId,
            'amount' => $order->real_price,
            'reason' => $reason,
            'type' => $refundToBalance ? 2 : 1,
            'status' => 0,
            'create_time' => now(),
        ]);
        
        // 标记订单
        $order->refund_id = $refund->id;
        $order->save();
        
        return [
            'success' => true,
            'message' => '退款申请已提交',
            'refund_id' => $refund->id,
        ];
    }
    
    /**
     * 处理退款
     */
    public function process(int $refundId, int $adminId, bool $approve, string $remark = ''): array
    {
        $refund = Refund::find($refundId);
        if (!$refund) {
            return ['success' => false, 'message' => '退款记录不存在'];
        }
        
        if ($refund->status != 0) {
            return ['success' => false, 'message' => '该退款已处理'];
        }
        
        $order = Order::find($refund->order_id);
        if (!$order) {
            return ['success' => false, 'message' => '关联订单不存在'];
        }
        
        if ($approve) {
            // 执行退款
            if ($refund->type == 2) {
                // 退至余额
                $this->balanceService->refund($refund->user_id, (float)$refund->amount, $refund->order_id);
            }
            // 原路返回的退款由支付接口处理
            
            $refund->status = 1;
            $order->is_refunded = 1;
            $order->save();
            
            // 回收卡密
            $this->recycleCards($order);
            
        } else {
            // 拒绝退款
            $refund->status = 2;
            $refund->admin_remark = $remark;
        }
        
        $refund->admin_id = $adminId;
        $refund->handle_time = now();
        $refund->save();
        
        return [
            'success' => true,
            'message' => $approve ? '退款已处理' : '退款已拒绝',
        ];
    }
    
    /**
     * 回收卡密
     */
    protected function recycleCards(Order $order): void
    {
        $cards = Card::where('order_id', $order->id)->get();
        foreach ($cards as $card) {
            $card->status = 0;
            $card->user_id = null;
            $card->order_id = null;
            $card->use_time = null;
            $card->save();
        }
    }
}
