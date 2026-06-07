<?php
declare(strict_types=1);

/**
 * 配置辅助函数
 */

if (!function_exists('config')) {
    /**
     * 获取配置
     */
    function config(string $key, $default = null)
    {
        static $configs = [];
        
        $keys = explode('.', $key);
        $file = array_shift($keys);
        
        if (!isset($configs[$file])) {
            $path = BASE_PATH . '/config/' . $file . '.php';
            if (file_exists($path)) {
                $configs[$file] = require $path;
            } else {
                $configs[$file] = [];
            }
            
            // 尝试从数据库加载
            try {
                if (\App\Model\ConfigExtra::tableExists()) {
                    $dbConfigs = \App\Model\ConfigExtra::getGroup($file);
                    $configs[$file] = array_merge($configs[$file], $dbConfigs);
                }
            } catch (\Exception $e) {
                // 数据库未初始化，忽略
            }
            
            // 尝试从system_config加载
            try {
                if (class_exists('\App\Model\SystemConfig')) {
                    $systemConfigs = \App\Model\SystemConfig::getGroup($file);
                    $configs[$file] = array_merge($configs[$file], $systemConfigs);
                }
            } catch (\Exception $e) {
                // 数据库未初始化，忽略
            }
        }
        
        $value = $configs[$file] ?? [];
        
        foreach ($keys as $k) {
            if (!isset($value[$k])) {
                return $default;
            }
            $value = $value[$k];
        }
        
        return $value;
    }
}

if (!function_exists('Config')) {
    /**
     * 获取/设置配置（静态调用）
     */
    class Config
    {
        public static function get(string $key, string $group = 'system', $default = null)
        {
            try {
                if (class_exists('\App\Model\SystemConfig')) {
                    return \App\Model\SystemConfig::getValue($key, $group, $default);
                }
            } catch (\Exception $e) {
                // 数据库未初始化
            }
            
            return $default;
        }
        
        public static function set(string $key, $value, string $group = 'system'): bool
        {
            try {
                if (class_exists('\App\Model\SystemConfig')) {
                    return \App\Model\SystemConfig::setValue($key, $value, $group);
                }
            } catch (\Exception $e) {
                // 数据库未初始化
            }
            
            return false;
        }
    }
}
