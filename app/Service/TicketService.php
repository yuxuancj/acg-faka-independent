<?php
/**
 * 工单服务类
 */
namespace App\Service;

use App\Model\Ticket;
use App\Model\TicketReply;
use App\Model\User;
use App\Model\ConfigExtra;

class TicketService
{
    /**
     * 自动标签分类关键词
     */
    private $tagKeywords = [
        '退款' => '退款',
        'refund' => '退款',
        '无效' => '卡密无效',
        '过期' => '卡密无效',
        '错误' => '卡密无效',
        '补发' => '卡密补发',
        '发错' => '卡密补发',
        '充不上' => '充值问题',
        '打不开' => '技术问题',
        '登录' => '技术问题',
        'API' => 'API问题',
    ];
    
    /**
     * 创建工单
     */
    public function createTicket($userId, $data)
    {
        if (ConfigExtra::getValue('ticket_enabled', '1') != '1') {
            return ['success' => false, 'message' => '工单系统未启用'];
        }
        
        $ticket = new Ticket();
        $ticket->user_id = $userId;
        $ticket->order_id = $data['order_id'] ?? null;
        $ticket->product_id = $data['product_id'] ?? null;
        $ticket->type = $data['type'] ?? Ticket::TYPE_OTHER;
        $ticket->title = $data['title'];
        $ticket->content = $data['content'];
        $ticket->status = Ticket::STATUS_PENDING;
        $ticket->create_time = date('Y-m-d H:i:s');
        
        $ticket->tags = $this->autoTag($data['title'] . ' ' . $data['content']);
        
        $ticket->save();
        
        if (!empty($data['content'])) {
            $this->addReply($ticket->id, $userId, TicketReply::USER_TYPE_USER, $data['content']);
        }
        
        return ['success' => true, 'ticket_id' => $ticket->id];
    }
    
    /**
     * 自动打标签
     */
    private function autoTag($content)
    {
        $tags = [];
        $content = mb_strtolower($content);
        
        foreach ($this->tagKeywords as $keyword => $tag) {
            if (strpos($content, mb_strtolower($keyword)) !== false) {
                if (!in_array($tag, $tags)) {
                    $tags[] = $tag;
                }
            }
        }
        
        return implode(',', $tags);
    }
    
    /**
     * 添加回复
     */
    public function addReply($ticketId, $userId, $userType, $content, $attachments = null)
    {
        $reply = new TicketReply();
        $reply->ticket_id = $ticketId;
        $reply->user_id = $userId;
        $reply->user_type = $userType;
        $reply->content = $content;
        $reply->attachments = $attachments ? json_encode($attachments) : null;
        $reply->create_time = date('Y-m-d H:i:s');
        $reply->save();
        
        $ticket = Ticket::find($ticketId);
        if ($ticket) {
            $ticket->last_reply_time = date('Y-m-d H:i:s');
            if ($userType == TicketReply::USER_TYPE_USER && $ticket->status == Ticket::STATUS_RESOLVED) {
                $ticket->status = Ticket::STATUS_PROCESSING;
            }
            $ticket->save();
        }
        
        return $reply;
    }
    
    /**
     * 更新工单状态
     */
    public function updateStatus($ticketId, $status, $adminId = null)
    {
        $ticket = Ticket::find($ticketId);
        if (!$ticket) {
            return false;
        }
        
        $ticket->status = $status;
        $ticket->admin_id = $adminId;
        $ticket->save();
        
        return true;
    }
    
    /**
     * 获取用户工单列表
     */
    public function getUserTickets($userId, $page = 1, $limit = 20)
    {
        return Ticket::where('user_id', $userId)
            ->orderBy('id', 'desc')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get();
    }
    
    /**
     * 获取工单详情
     */
    public function getTicketDetail($ticketId, $userId = null)
    {
        $query = Ticket::with('replies', 'user', 'order', 'commodity');
        
        if ($userId !== null) {
            $query->where('user_id', $userId);
        }
        
        return $query->where('id', $ticketId)->first();
    }
}
