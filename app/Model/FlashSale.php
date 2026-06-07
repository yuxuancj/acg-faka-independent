<?php
/**
 * 秒杀活动模型
 */
namespace App\Model;

class FlashSale extends Model
{
    protected $table = 'flash_sale';
    
    /**
     * 关联商品
     */
    public function commodity()
    {
        return $this->belongsTo(Commodity::class, 'product_id');
    }
    
    /**
     * 获取进行中的秒杀
     */
    public static function getActiveSales()
    {
        $now = date('Y-m-d H:i:s');
        return self::where('status', 1)
            ->where('start_time', '<=', $now)
            ->where('end_time', '>=', $now)
            ->where('stock', '>', 0)
            ->orderBy('start_time', 'asc')
            ->get();
    }
    
    /**
     * 获取即将开始的秒杀（预热）
     */
    public static function getUpcomingSales()
    {
        $now = date('Y-m-d H:i:s');
        return self::where('status', 1)
            ->where('start_time', '>', $now)
            ->where('warmup_minutes', '>', 0)
            ->orderBy('start_time', 'asc')
            ->get();
    }
}
