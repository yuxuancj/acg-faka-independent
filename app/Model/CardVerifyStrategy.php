<?php
declare(strict_types=1);

namespace App\Model;

/**
 * 卡密核销策略模型
 */
class CardVerifyStrategy extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'card_verify_strategy';
    
    public $timestamps = false;
    
    /**
     * 核销类型
     */
    public static $types = [
        1 => '单次使用',
        2 => '有效期限制',
        3 => '设备绑定',
        4 => 'IP绑定',
        5 => '次数限制',
    ];
    
    /**
     * 获取类型文字
     */
    public function getTypeTextAttribute(): string
    {
        return self::$types[$this->type] ?? '未知';
    }
    
    /**
     * 获取参数字符
     */
    public function getParamTextAttribute(): string
    {
        switch ($this->type) {
            case 2:
                return $this->param_days ? "{$this->param_days}天" : '';
            case 5:
                return $this->param_times ? "{$this->param_times}次" : '';
            default:
                return '';
        }
    }
}
