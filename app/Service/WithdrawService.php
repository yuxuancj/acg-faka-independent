<?php
/**
 * 提现服务类
 */
namespace App\Service;

use App\Model\Withdraw;
use App\Model\User;
use App\Model\ConfigExtra;

class WithdrawService
{
    /**
     * 申请提现
     */
    public function apply($userId, $amount, $type, $account, $realName)
    {
        if (ConfigExtra::getValue('withdraw_enabled', '1') != '1') {
            return ['success' => false, 'message' => '提现功能未启用'];
        }
        
        $user = User::find($userId);
        if (!$user) {
            return ['success' => false, 'message' => '用户不存在'];
        }
        
        $minAmount = floatval(ConfigExtra::getValue('withdraw_min_amount', '10'));
        if ($amount < $minAmount) {
            return ['success' => false, 'message' => "最低提现{$minAmount}元"];
        }
        
        if ($user->balance < $amount) {
            return ['success' => false, 'message' => '余额不足'];
        }
        
        $user->balance -= $amount;
        $user->save();
        
        $withdraw = new Withdraw();
        $withdraw->user_id = $userId;
        $withdraw->amount = $amount;
        $withdraw->type = $type;
        $withdraw->account = $account;
        $withdraw->real_name = $realName;
        $withdraw->status = Withdraw::STATUS_PENDING;
        $withdraw->create_time = date('Y-m-d H:i:s');
        $withdraw->save();
        
        return ['success' => true, 'withdraw_id' => $withdraw->id];
    }
    
    /**
     * 审核提现
     */
    public function audit($withdrawId, $status, $remark = '')
    {
        $withdraw = Withdraw::find($withdrawId);
        if (!$withdraw || $withdraw->status != Withdraw::STATUS_PENDING) {
            return ['success' => false, 'message' => '提现记录不存在或已处理'];
        }
        
        $withdraw->status = $status;
        $withdraw->remark = $remark;
        $withdraw->audit_time = date('Y-m-d H:i:s');
        $withdraw->save();
        
        if ($status == Withdraw::STATUS_REJECTED) {
            $user = User::find($withdraw->user_id);
            if ($user) {
                $user->balance += $withdraw->amount;
                $user->save();
            }
        }
        
        return ['success' => true];
    }
    
    /**
     * 获取用户提现记录
     */
    public function getUserRecords($userId, $page = 1, $limit = 20)
    {
        return Withdraw::where('user_id', $userId)
            ->orderBy('id', 'desc')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get();
    }
}
