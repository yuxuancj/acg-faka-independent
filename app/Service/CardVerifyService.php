<?php
declare(strict_types=1);

namespace App\Service;

use App\Model\Card;
use App\Model\CardVerifyStrategy;
use App\Model\CardUseLog;

/**
 * 卡密核销服务
 */
class CardVerifyService
{
    /**
     * 验证卡密是否可以使用
     */
    public function verify(Card $card, int $userId, ?string $deviceId = null, ?string $ip = null): array
    {
        // 检查卡密状态
        if ($card->status != 1) {
            return ['success' => false, 'message' => '卡密未售出或已使用'];
        }
        
        // 获取核销策略
        $strategy = null;
        if ($card->verify_strategy_id) {
            $strategy = CardVerifyStrategy::find($card->verify_strategy_id);
        }
        
        if (!$strategy) {
            return ['success' => true, 'message' => '验证通过'];
        }
        
        // 根据策略类型验证
        switch ($strategy->type) {
            case 1: // 单次使用
                if ($card->current_uses > 0) {
                    return ['success' => false, 'message' => '卡密已使用过'];
                }
                break;
                
            case 2: // 有效期限制
                if ($card->activated_time && $card->expire_days) {
                    $expireTime = strtotime($card->activated_time) + ($card->expire_days * 86400);
                    if (time() > $expireTime) {
                        return ['success' => false, 'message' => '卡密已过期'];
                    }
                }
                break;
                
            case 3: // 设备绑定
                if ($card->device_id && $card->device_id != $deviceId) {
                    return ['success' => false, 'message' => '设备不匹配'];
                }
                break;
                
            case 4: // IP绑定
                $lastUse = CardUseLog::where('card_id', $card->id)
                    ->orderBy('use_time', 'desc')
                    ->first();
                if ($lastUse && $lastUse->ip != $ip) {
                    return ['success' => false, 'message' => 'IP地址不匹配'];
                }
                break;
                
            case 5: // 次数限制
                if ($card->max_uses && $card->current_uses >= $card->max_uses) {
                    return ['success' => false, 'message' => '使用次数已达上限'];
                }
                break;
        }
        
        return ['success' => true, 'message' => '验证通过'];
    }
    
    /**
     * 使用卡密
     */
    public function use(Card $card, int $userId, ?string $deviceId = null, ?string $ip = null, ?string $content = null): array
    {
        // 验证
        $verify = $this->verify($card, $userId, $deviceId, $ip);
        if (!$verify['success']) {
            return $verify;
        }
        
        // 更新使用次数
        $card->current_uses = $card->current_uses + 1;
        
        // 如果是首次使用，记录激活时间
        if ($card->current_uses == 1) {
            $card->activated_time = now();
        }
        
        // 如果设定了设备绑定
        if ($deviceId && !$card->device_id) {
            $card->device_id = $deviceId;
        }
        
        $card->save();
        
        // 记录使用日志
        CardUseLog::create([
            'card_id' => $card->id,
            'user_id' => $userId,
            'device_id' => $deviceId,
            'ip' => $ip ?? request()->ip(),
            'use_time' => now(),
            'content' => $content,
        ]);
        
        return [
            'success' => true,
            'message' => '使用成功',
            'remaining_uses' => $card->max_uses ? $card->max_uses - $card->current_uses : null,
        ];
    }
}
