<?php
declare(strict_types=1);

namespace App\Model;

use Illuminate\Database\Eloquent\Model;

/**
 * 系统配置模型
 */
class SystemConfig extends Model
{
    protected $table = 'system_config';
    
    public $timestamps = false;
    
    /**
     * 获取配置值
     */
    public static function getValue(string $key, string $group = 'system', $default = null)
    {
        $config = self::where('group', $group)
            ->where('key', $key)
            ->first();
        
        return $config ? $config->value : $default;
    }
    
    /**
     * 设置配置值
     */
    public static function setValue(string $key, $value, string $group = 'system'): bool
    {
        $config = self::where('group', $group)
            ->where('key', $key)
            ->first();
        
        if ($config) {
            $config->value = $value;
            return $config->save();
        }
        
        return false;
    }
    
    /**
     * 获取分组的所有配置
     */
    public static function getGroup(string $group): array
    {
        $configs = self::where('group', $group)
            ->orderBy('sort')
            ->get();
        
        $result = [];
        foreach ($configs as $config) {
            $result[$config->key] = $config->value;
        }
        
        return $result;
    }
}
