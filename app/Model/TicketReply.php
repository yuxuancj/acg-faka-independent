<?php
/**
 * 工单回复模型
 */
namespace App\Model;

class TicketReply extends Model
{
    protected $table = 'ticket_reply';
    
    const USER_TYPE_USER = 1;
    const USER_TYPE_ADMIN = 2;
    
    /**
     * 关联工单
     */
    public function ticket()
    {
        return $this->belongsTo(Ticket::class);
    }
}
