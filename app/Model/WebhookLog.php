<?php
declare(strict_types=1);

namespace App\Model;

/**
 * Webhook日志模型
 */
class WebhookLog extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'webhook_log';
    
    public $timestamps = false;
    
    protected $casts = [
        'create_time' => 'datetime',
        'send_time' => 'datetime',
    ];
    
    /**
     * Webhook配置
     */
    public function webhook()
    {
        return $this->belongsTo(Webhook::class, 'webhook_id');
    }
}
