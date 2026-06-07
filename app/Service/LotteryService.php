<?php
/**
 * 积分抽奖服务类
 */
namespace App\Service;

use App\Model\Lottery;
use App\Model\LotteryLog;
use App\Model\UserPointsLog;
use App\Model\User;
use App\Model\Coupon;
use App\Model\UserCoupon;
use App\Model\Card;
use App\Model\ConfigExtra;

class LotteryService
{
    private $userService;
    
    public function __construct()
    {
        $this->userService = new UserServiceV2();
    }
    
    /**
     * 执行抽奖
     */
    public function draw($userId)
    {
        if (ConfigExtra::getValue('lottery_enabled', '1') != '1') {
            return ['success' => false, 'message' => '抽奖功能未启用'];
        }
        
        $prizes = Lottery::getAvailablePrizes();
        if ($prizes->isEmpty()) {
            return ['success' => false, 'message' => '奖品池为空'];
        }
        
        $totalProbability = 0;
        foreach ($prizes as $prize) {
            $totalProbability += $prize->probability;
        }
        
        if ($totalProbability <= 0) {
            return ['success' => false, 'message' => '概率配置错误'];
        }
        
        $user = User::find($userId);
        if (!$user) {
            return ['success' => false, 'message' => '用户不存在'];
        }
        
        $pointsCost = $prizes->first()->points_cost ?? 10;
        if ($user->points < $pointsCost) {
            return ['success' => false, 'message' => '积分不足'];
        }
        
        $this->userService->usePoints($userId, $pointsCost, '积分抽奖', null, 'lottery');
        
        $rand = mt_rand(1, $totalProbability);
        $current = 0;
        $winningPrize = null;
        
        foreach ($prizes as $prize) {
            $current += $prize->probability;
            if ($rand <= $current) {
                $winningPrize = $prize;
                break;
            }
        }
        
        if (!$winningPrize) {
            $winningPrize = $prizes->first();
        }
        
        $log = new LotteryLog();
        $log->user_id = $userId;
        $log->lottery_id = $winningPrize->id;
        $log->prize_type = $winningPrize->type;
        $log->prize_value = $winningPrize->prize_value;
        $log->points_cost = $pointsCost;
        $log->create_time = date('Y-m-d H:i:s');
        $log->save();
        
        $result = $this->distributePrize($userId, $winningPrize);
        
        return array_merge(['success' => true, 'prize' => $winningPrize], $result);
    }
    
    /**
     * 发放奖品
     */
    private function distributePrize($userId, $prize)
    {
        $result = ['type' => $prize->type];
        
        switch ($prize->type) {
            case Lottery::TYPE_POINTS:
                $points = intval($prize->prize_value);
                $this->userService->addPoints($userId, $points, '抽奖获得积分', null, 'lottery');
                $result['value'] = $points;
                $result['text'] = "{$points}积分";
                break;
                
            case Lottery::TYPE_COUPON:
                $couponId = intval($prize->prize_value);
                $coupon = Coupon::find($couponId);
                if ($coupon) {
                    do {
                        $code = substr(str_shuffle('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'), 0, 10);
                    } while (UserCoupon::where('code', $code)->exists());
                    
                    $userCoupon = new UserCoupon();
                    $userCoupon->user_id = $userId;
                    $userCoupon->coupon_id = $couponId;
                    $userCoupon->code = $code;
                    $userCoupon->get_time = date('Y-m-d H:i:s');
                    if ($coupon->valid_days > 0) {
                        $userCoupon->expire_time = date('Y-m-d H:i:s', strtotime("+{$coupon->valid_days} days"));
                    } elseif ($coupon->end_time) {
                        $userCoupon->expire_time = $coupon->end_time;
                    }
                    $userCoupon->save();
                    $result['value'] = $code;
                    $result['text'] = $coupon->name;
                }
                break;
                
            case Lottery::TYPE_CARD:
                $productId = intval($prize->prize_value);
                $card = Card::where('commodity_id', $productId)
                    ->where('is_sold', 0)
                    ->first();
                if ($card) {
                    $card->is_sold = 1;
                    $card->sale_time = date('Y-m-d H:i:s');
                    $card->save();
                    $result['value'] = $card->id;
                    $result['text'] = '卡密商品';
                }
                break;
        }
        
        if ($prize->stock > 0) {
            $prize->decrement('stock');
        }
        
        return $result;
    }
    
    /**
     * 获取抽奖记录
     */
    public function getLotteryLog($userId, $page = 1, $limit = 20)
    {
        return LotteryLog::with('lottery')
            ->where('user_id', $userId)
            ->orderBy('id', 'desc')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get();
    }
}
