<?php
/**
 * 用户等级模型
 */
namespace App\Model;

class UserLevel extends Model
{
    protected $table = 'user_level';
    
    /**
     * 获取所有可用等级
     */
    public static function getActiveLevels()
    {
        return self::where('status', 1)->orderBy('sort', 'asc')->get();
    }
    
    /**
     * 根据成长值获取对应等级
     */
    public static function getLevelByPoints($growthPoints)
    {
        return self::where('min_points', '<=', $growthPoints)
            ->where('status', 1)
            ->orderBy('min_points', 'desc')
            ->first();
    }
}
