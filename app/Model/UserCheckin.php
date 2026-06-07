<?php
/**
 * 签到记录模型
 */
namespace App\Model;

class UserCheckin extends Model
{
    protected $table = 'user_checkin';
    
    /**
     * 关联用户
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
