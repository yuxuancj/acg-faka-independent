<?php
/**
 * 扩展配置模型
 */
namespace App\Model;

class ConfigExtra extends Model
{
    protected $table = 'config_extra';
    
    /**
     * 根据分组获取配置
     */
    public static function getByGroup($group)
    {
        return self::where('group', $group)
            ->orderBy('sort', 'asc')
            ->get()
            ->keyBy('key');
    }
    
    /**
     * 获取配置值
     */
    public static function getValue($key, $default = null)
    {
        $config = self::where('key', $key)->first();
        return $config ? $config->value : $default;
    }
    
    /**
     * 设置配置值
     */
    public static function setValue($key, $value)
    {
        $config = self::where('key', $key)->first();
        if ($config) {
            $config->value = $value;
            $config->save();
        }
    }
}
