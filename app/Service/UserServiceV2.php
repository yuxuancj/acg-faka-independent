<?php
/**
 * 用户服务类（v2.0）
 * 处理用户等级、积分、签到等
 */
namespace App\Service;

use App\Model\User;
use App\Model\UserLevel;
use App\Model\UserPointsLog;
use App\Model\UserCheckin;
use App\Model\ConfigExtra;

class UserServiceV2
{
    /**
     * 检查功能是否启用
     */
    private function isFeatureEnabled($key)
    {
        return ConfigExtra::getValue($key, '1') == '1';
    }
    
    /**
     * 更新用户等级
     */
    public function updateUserLevel($userId)
    {
        if (!$this->isFeatureEnabled('level_enabled')) {
            return false;
        }
        
        $user = User::find($userId);
        if (!$user) {
            return false;
        }
        
        $level = UserLevel::getLevelByPoints($user->growth_points);
        if ($level) {
            $user->level_id = $level->id;
            $user->save();
        }
        
        return true;
    }
    
    /**
     * 增加积分
     */
    public function addPoints($userId, $points, $remark = '', $relatedId = null, $relatedType = null)
    {
        if (!$this->isFeatureEnabled('points_enabled')) {
            return false;
        }
        
        $user = User::find($userId);
        if (!$user) {
            return false;
        }
        
        $user->points += $points;
        $user->save();
        
        $log = new UserPointsLog();
        $log->user_id = $userId;
        $log->type = UserPointsLog::TYPE_GAIN;
        $log->points = $points;
        $log->balance = $user->points;
        $log->remark = $remark;
        $log->related_id = $relatedId;
        $log->related_type = $relatedType;
        $log->create_time = date('Y-m-d H:i:s');
        $log->save();
        
        return true;
    }
    
    /**
     * 扣除积分
     */
    public function usePoints($userId, $points, $remark = '', $relatedId = null, $relatedType = null)
    {
        if (!$this->isFeatureEnabled('points_enabled')) {
            return false;
        }
        
        $user = User::find($userId);
        if (!$user || $user->points < $points) {
            return false;
        }
        
        $user->points -= $points;
        $user->save();
        
        $log = new UserPointsLog();
        $log->user_id = $userId;
        $log->type = UserPointsLog::TYPE_USE;
        $log->points = $points;
        $log->balance = $user->points;
        $log->remark = $remark;
        $log->related_id = $relatedId;
        $log->related_type = $relatedType;
        $log->create_time = date('Y-m-d H:i:s');
        $log->save();
        
        return true;
    }
    
    /**
     * 每日签到
     */
    public function dailyCheckin($userId)
    {
        if (!$this->isFeatureEnabled('checkin_enabled')) {
            return ['success' => false, 'message' => '签到功能未启用'];
        }
        
        $today = date('Y-m-d');
        $yesterday = date('Y-m-d', strtotime('-1 day'));
        
        $checkin = UserCheckin::where('user_id', $userId)
            ->where('checkin_date', $today)
            ->first();
        
        if ($checkin) {
            return ['success' => false, 'message' => '今日已签到'];
        }
        
        $lastCheckin = UserCheckin::where('user_id', $userId)
            ->orderBy('checkin_date', 'desc')
            ->first();
        
        $continuousDays = 1;
        if ($lastCheckin && $lastCheckin->checkin_date == $yesterday) {
            $continuousDays = $lastCheckin->continuous_days + 1;
        }
        
        $basePoints = intval(ConfigExtra::getValue('checkin_base_points', '10'));
        $bonusPoints = intval(ConfigExtra::getValue('checkin_continuous_bonus', '5'));
        
        $totalPoints = $basePoints;
        if ($continuousDays > 1) {
            $totalPoints += $bonusPoints * ($continuousDays - 1);
        }
        
        $newCheckin = new UserCheckin();
        $newCheckin->user_id = $userId;
        $newCheckin->checkin_date = $today;
        $newCheckin->continuous_days = $continuousDays;
        $newCheckin->points_reward = $totalPoints;
        $newCheckin->create_time = date('Y-m-d H:i:s');
        $newCheckin->save();
        
        $this->addPoints($userId, $totalPoints, '每日签到', $newCheckin->id, 'checkin');
        
        return [
            'success' => true,
            'points' => $totalPoints,
            'continuous_days' => $continuousDays
        ];
    }
    
    /**
     * 增加成长值
     */
    public function addGrowthPoints($userId, $points)
    {
        $user = User::find($userId);
        if (!$user) {
            return false;
        }
        
        $user->growth_points += $points;
        $user->save();
        
        $this->updateUserLevel($userId);
        
        return true;
    }
    
    /**
     * 获取用户积分日志
     */
    public function getPointsLog($userId, $page = 1, $limit = 20)
    {
        return UserPointsLog::where('user_id', $userId)
            ->orderBy('id', 'desc')
            ->offset(($page - 1) * $limit)
            ->limit($limit)
            ->get();
    }
}
