<?php
/**
 * 用户积分记录模型
 */
namespace App\Model;

class UserPointsLog extends Model
{
    protected $table = 'user_points_log';
    
    const TYPE_GAIN = 1;
    const TYPE_USE = 2;
    
    /**
     * 关联用户
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
