<?php
declare(strict_types=1);

namespace App\Model;

/**
 * 用户余额变动记录模型
 */
class UserBalanceLog extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'user_balance_log';
    
    public $timestamps = false;
    
    protected $casts = [
        'amount' => 'decimal:2',
        'balance_before' => 'decimal:2',
        'balance_after' => 'decimal:2',
    ];
    
    /**
     * 用户
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    
    /**
     * 类型文字
     */
    public function getTypeTextAttribute(): string
    {
        $types = [1 => '充值', 2 => '消费', 3 => '退款', 4 => '管理员调整'];
        return $types[$this->type] ?? '未知';
    }
}
