<?php
/**
 * 工单模型
 */
namespace App\Model;

class Ticket extends Model
{
    protected $table = 'ticket';
    
    const TYPE_CARD = 1;
    const TYPE_API = 2;
    const TYPE_REFUND = 3;
    const TYPE_OTHER = 4;
    
    const STATUS_PENDING = 0;
    const STATUS_PROCESSING = 1;
    const STATUS_RESOLVED = 2;
    const STATUS_CLOSED = 3;
    
    /**
     * 关联用户
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
    
    /**
     * 关联订单
     */
    public function order()
    {
        return $this->belongsTo(Order::class);
    }
    
    /**
     * 关联商品
     */
    public function commodity()
    {
        return $this->belongsTo(Commodity::class, 'product_id');
    }
    
    /**
     * 关联回复
     */
    public function replies()
    {
        return $this->hasMany(TicketReply::class);
    }
    
    /**
     * 获取工单类型文本
     */
    public static function getTypeText($type)
    {
        $types = [
            self::TYPE_CARD => '卡密补发',
            self::TYPE_API => 'API授权',
            self::TYPE_REFUND => '退款申请',
            self::TYPE_OTHER => '其他'
        ];
        return isset($types[$type]) ? $types[$type] : '未知';
    }
    
    /**
     * 获取工单状态文本
     */
    public static function getStatusText($status)
    {
        $statuses = [
            self::STATUS_PENDING => '待处理',
            self::STATUS_PROCESSING => '处理中',
            self::STATUS_RESOLVED => '已解决',
            self::STATUS_CLOSED => '已关闭'
        ];
        return isset($statuses[$status]) ? $statuses[$status] : '未知';
    }
}
