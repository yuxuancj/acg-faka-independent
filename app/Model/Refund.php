<?php
declare(strict_types=1);

namespace App\Model;

/**
 * 退款记录模型
 */
class Refund extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'refund';
    
    public $timestamps = false;
    
    protected $casts = [
        'amount' => 'decimal:2',
        'create_time' => 'datetime',
        'handle_time' => 'datetime',
    ];
    
    /**
     * 状态文字
     */
    public static $statusText = [
        0 => '待处理',
        1 => '已退款',
        2 => '已拒绝',
    ];
    
    /**
     * 类型文字
     */
    public static $typeText = [
        1 => '原路返回',
        2 => '退至余额',
    ];
    
    /**
     * 订单
     */
    public function order()
    {
        return $this->belongsTo(Order::class, 'order_id');
    }
    
    /**
     * 用户
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    
    /**
     * 管理员
     */
    public function admin()
    {
        return $this->belongsTo(Manage::class, 'admin_id');
    }
    
    /**
     * 获取状态文字
     */
    public function getStatusTextAttribute(): string
    {
        return self::$statusText[$this->status] ?? '未知';
    }
    
    /**
     * 获取类型文字
     */
    public function getTypeTextAttribute(): string
    {
        return self::$typeText[$this->type] ?? '未知';
    }
}
