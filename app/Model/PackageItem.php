<?php
declare(strict_types=1);

namespace App\Model;

/**
 * 套餐商品关联模型
 */
class PackageItem extends \Illuminate\Database\Eloquent\Model
{
    protected $table = 'package_item';
    
    public $timestamps = false;
    
    /**
     * 套餐
     */
    public function package()
    {
        return $this->belongsTo(Package::class, 'package_id');
    }
    
    /**
     * 商品
     */
    public function commodity()
    {
        return $this->belongsTo(Commodity::class, 'commodity_id');
    }
}
