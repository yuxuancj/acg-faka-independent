<?php
/**
 * 批发折扣模型
 */
namespace App\Model;

class WholesaleDiscount extends Model
{
    protected $table = 'wholesale_discount';
    
    /**
     * 关联商品
     */
    public function commodity()
    {
        return $this->belongsTo(Commodity::class, 'product_id');
    }
    
    /**
     * 根据数量获取折扣
     */
    public static function getDiscountByQty($productId, $qty)
    {
        $discounts = self::where('product_id', $productId)
            ->orderBy('min_qty', 'asc')
            ->get();
        
        foreach ($discounts as $d) {
            if ($qty >= $d->min_qty && 
                ($d->max_qty === null || $qty <= $d->max_qty)) {
                return $d;
            }
        }
        
        return null;
    }
}
