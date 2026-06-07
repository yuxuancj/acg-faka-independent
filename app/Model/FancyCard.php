<?php
declare(strict_types=1);

namespace App\Model;

/**
 * 靓号卡密模型
 */
class FancyCard extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'fancy_card';
    
    public $timestamps = false;
    
    protected $casts = [
        'extra_price' => 'decimal:2',
    ];
    
    /**
     * 商品
     */
    public function commodity()
    {
        return $this->belongsTo(Commodity::class, 'commodity_id');
    }
    
    /**
     * 获取可售的靓号
     */
    public static function getAvailable(int $commodityId, int $limit = 10)
    {
        return self::where('commodity_id', $commodityId)
            ->where('status', 0)
            ->orderByRaw('RAND()')
            ->limit($limit)
            ->get();
    }
}
