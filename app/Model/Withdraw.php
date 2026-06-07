<?php
/**
 * 提现申请模型
 */
namespace App\Model;

class Withdraw extends Model
{
    protected $table = 'withdraw';
    
    const TYPE_ALIPAY = 1;
    const TYPE_WECHAT = 2;
    const TYPE_BANK = 3;
    
    const STATUS_PENDING = 0;
    const STATUS_APPROVED = 1;
    const STATUS_REJECTED = 2;
    
    /**
     * 关联用户
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    
    /**
     * 获取提现方式文本
     */
    public static function getTypeText($type)
    {
        $types = [
            self::TYPE_ALIPAY => '支付宝',
            self::TYPE_WECHAT => '微信',
            self::TYPE_BANK => '银行卡'
        ];
        return isset($types[$type]) ? $types[$type] : '未知';
    }
    
    /**
     * 获取提现状态文本
     */
    public static function getStatusText($status)
    {
        $statuses = [
            self::STATUS_PENDING => '待审核',
            self::STATUS_APPROVED => '已通过',
            self::STATUS_REJECTED => '已拒绝'
        ];
        return isset($statuses[$status]) ? $statuses[$status] : '未知';
    }
}
