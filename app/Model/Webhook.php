<?php
declare(strict_types=1);

namespace App\Model;

/**
 * Webhook配置模型
 */
class Webhook extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'webhook';
    
    public $timestamps = false;
    
    /**
     * 事件列表
     */
    public static $events = [
        'order.paid' => '订单支付成功',
        'order.completed' => '订单完成',
        'order.refunded' => '订单退款',
        'user.register' => '用户注册',
        'user.vip_expired' => 'VIP过期',
        'ticket.reply' => '工单回复',
    ];
    
    /**
     * 获取启用的Webhooks
     */
    public static function getActive()
    {
        return self::where('status', 1)->get();
    }
    
    /**
     * 是否订阅了指定事件
     */
    public function hasEvent(string $event): bool
    {
        $events = explode(',', $this->events);
        return in_array($event, $events);
    }
    
    /**
     * 触发Webhook
     */
    public function trigger(string $event, array $data): bool
    {
        if (!$this->hasEvent($event)) {
            return false;
        }
        
        $payload = json_encode([
            'event' => $event,
            'time' => date('Y-m-d H:i:s'),
            'data' => $data,
        ]);
        
        $signature = $this->secret ? hash_hmac('sha256', $payload, $this->secret) : '';
        
        $ch = curl_init($this->url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'X-Webhook-Signature: ' . $signature,
                'X-Webhook-Event: ' . $event,
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 30,
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        // 记录日志
        $log = new WebhookLog();
        $log->webhook_id = $this->id;
        $log->event = $event;
        $log->payload = $payload;
        $log->response = $response;
        $log->status = $httpCode >= 200 && $httpCode < 300 ? 1 : 2;
        $log->send_time = date('Y-m-d H:i:s');
        $log->save();
        
        return $httpCode >= 200 && $httpCode < 300;
    }
}
