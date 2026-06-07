<?php
/**
 * 订单增强服务类
 */
namespace App\Service;

use App\Model\Order;
use App\Model\FlashSale;
use App\Model\WholesaleDiscount;
use App\Model\UserLevel;
use App\Model\UserCoupon;
use App\Model\Commodity;
use App\Model\ConfigExtra;
use App\Model\Ticket;

class OrderEnhanceService
{
    private $userService;
    private $couponService;
    
    public function __construct()
    {
        $this->userService = new UserServiceV2();
        $this->couponService = new CouponService();
    }
    
    /**
     * 计算订单价格（包含所有优惠）
     */
    public function calculatePrice($productId, $quantity, $userId = null, $userCouponId = null)
    {
        $product = Commodity::find($productId);
        if (!$product) {
            return ['success' => false, 'message' => '商品不存在'];
        }
        
        $price = $product->price;
        $originalPrice = $product->price;
        
        $flashSale = FlashSale::where('product_id', $productId)
            ->where('status', 1)
            ->where('start_time', '<=', date('Y-m-d H:i:s'))
            ->where('end_time', '>=', date('Y-m-d H:i:s'))
            ->where('stock', '>', 0)
            ->first();
        
        if ($flashSale) {
            $price = $flashSale->price;
            $discountType = 'flash_sale';
        }
        
        if ($userId && ConfigExtra::getValue('level_enabled', '1') == '1') {
            $user = \App\Model\User::find($userId);
            if ($user) {
                $level = UserLevel::find($user->level_id);
                if ($level && $level->discount < 100) {
                    $price = $price * ($level->discount / 100);
                    $discountType = 'member';
                }
            }
        }
        
        if ($quantity > 1 && $product->has_wholesale) {
            $wholesale = WholesaleDiscount::getDiscountByQty($productId, $quantity);
            if ($wholesale) {
                $price = $price * ($wholesale->discount / 100);
                $discountType = 'wholesale';
            }
        }
        
        $total = $price * $quantity;
        $discountAmount = 0;
        
        if ($userCouponId && ConfigExtra::getValue('coupon_enabled', '1') == '1') {
            $userCoupon = UserCoupon::with('coupon')->find($userCouponId);
            if ($userCoupon && $userCoupon->status == UserCoupon::STATUS_UNUSED) {
                $discountAmount = $this->couponService->calculateDiscount($userCoupon, $total, [$productId]);
                if ($discountAmount > 0) {
                    $total -= $discountAmount;
                }
            }
        }
        
        $total = max(0.01, $total);
        
        return [
            'success' => true,
            'original_price' => $originalPrice * $quantity,
            'final_price' => $total,
            'discount_amount' => ($originalPrice * $quantity) - $total,
            'unit_price' => $price,
            'quantity' => $quantity
        ];
    }
    
    /**
     * 关闭超时订单
     */
    public function closeExpiredOrders()
    {
        $minutes = intval(ConfigExtra::getValue('order_auto_close_minutes', '30'));
        $expireTime = date('Y-m-d H:i:s', strtotime("-{$minutes} minutes"));
        
        $orders = Order::where('status', 0)
            ->where('create_time', '<', $expireTime)
            ->get();
        
        foreach ($orders as $order) {
            $order->status = -1;
            $order->save();
            
            $cards = \App\Model\Card::where('order_id', $order->id)->get();
            foreach ($cards as $card) {
                $card->is_sold = 0;
                $card->order_id = 0;
                $card->sale_time = null;
                $card->save();
            }
        }
        
        return count($orders);
    }
    
    /**
     * 订单完成后处理
     */
    public function onOrderComplete($order)
    {
        if (!$order->user_id) {
            return true;
        }
        
        if (ConfigExtra::getValue('level_enabled', '1') == '1') {
            $growthPoints = floor($order->total_price);
            $this->userService->addGrowthPoints($order->user_id, $growthPoints);
        }
        
        if (ConfigExtra::getValue('points_enabled', '1') == '1') {
            $pointRate = floatval(ConfigExtra::getValue('points_gain_rate', '1'));
            $points = floor($order->total_price * $pointRate);
            if ($points > 0) {
                $this->userService->addPoints($order->user_id, $points, '购物获得积分', $order->id, 'order');
            }
        }
        
        return true;
    }
}
