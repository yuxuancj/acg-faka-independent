<?php
declare(strict_types=1);

namespace App\Model;

/**
 * 商品套餐模型
 */
class Package extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'package';
    
    public $timestamps = false;
    
    protected $casts = [
        'price' => 'decimal:2',
        'original_price' => 'decimal:2',
    ];
    
    /**
     * 获取上架的套餐
     */
    public static function getActive()
    {
        return self::where('status', 1)->orderBy('sort')->get();
    }
    
    /**
     * 套餐商品
     */
    public function items()
    {
        return $this->hasMany(PackageItem::class, 'package_id');
    }
    
    /**
     * 获取套餐包含的商品
     */
    public function getCommodities()
    {
        $items = $this->items()->with('commodity')->get();
        return $items->map(function ($item) {
            return [
                'commodity' => $item->commodity,
                'quantity' => $item->quantity,
            ];
        });
    }
    
    /**
     * 计算节省金额
     */
    public function getSavedAmount(): float
    {
        return round((float)$this->original_price - (float)$this->price, 2);
    }
    
    /**
     * 计算折扣
     */
    public function getDiscountRate(): float
    {
        if ($this->original_price <= 0) {
            return 0;
        }
        return round((1 - (float)$this->price / (float)$this->original_price) * 10, 1);
    }
}
