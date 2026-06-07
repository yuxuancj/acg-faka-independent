<?php
declare(strict_types=1);

namespace App\Service;

use App\Model\Card;
use App\Model\CardVerifyStrategy;
use App\Model\CardUseLog;
use App\Util\Str;

/**
 * 卡密生成服务
 */
class CardGeneratorService
{
    /**
     * 生成卡密
     */
    public function generate(
        int $commodityId,
        int $quantity,
        ?string $prefix = null,
        ?string $dateFormat = null,
        int $length = 16,
        string $charset = 'alnum',
        ?string $separator = null,
        int $separatorInterval = 4,
        bool $hasCheckcode = false
    ): array {
        $cards = [];
        
        for ($i = 0; $i < $quantity; $i++) {
            $cardNo = $this->generateCardNo(
                $prefix,
                $dateFormat,
                $length,
                $charset,
                $separator,
                $separatorInterval,
                $hasCheckcode
            );
            
            // 检查是否重复
            while (Card::where('card_no', $cardNo)->exists()) {
                $cardNo = $this->generateCardNo(
                    $prefix,
                    $dateFormat,
                    $length,
                    $charset,
                    $separator,
                    $separatorInterval,
                    $hasCheckcode
                );
            }
            
            $cards[] = $cardNo;
            
            // 保存到数据库
            Card::create([
                'commodity_id' => $commodityId,
                'card_no' => $cardNo,
                'status' => 0,
                'create_time' => now(),
            ]);
        }
        
        return $cards;
    }
    
    /**
     * 生成单个卡号
     */
    protected function generateCardNo(
        ?string $prefix,
        ?string $dateFormat,
        int $length,
        string $charset,
        ?string $separator,
        int $separatorInterval,
        bool $hasCheckcode
    ): string {
        $parts = [];
        
        // 前缀
        if ($prefix) {
            $parts[] = $prefix;
        }
        
        // 日期
        if ($dateFormat) {
            $parts[] = date($dateFormat);
        }
        
        // 随机字符串
        $randomLength = $hasCheckcode ? $length - 1 : $length;
        $randomStr = Str::random($randomLength, $charset);
        
        // 添加分隔符
        if ($separator && $separatorInterval > 0) {
            $randomStr = implode($separator, str_split($randomStr, $separatorInterval));
        }
        
        $parts[] = $randomStr;
        
        // 校验位
        if ($hasCheckcode) {
            $allChars = implode('', $parts);
            $checkcode = $this->generateCheckcode($allChars);
            $parts[] = $checkcode;
        }
        
        return implode('', $parts);
    }
    
    /**
     * 生成校验位
     */
    protected function generateCheckcode(string $str): string
    {
        $sum = 0;
        for ($i = 0; $i < strlen($str); $i++) {
            $sum += ord($str[$i]);
        }
        return strtoupper(dechex($sum % 256));
    }
    
    /**
     * 导出卡密为ZIP
     */
    public function exportToZip(array $cardIds, ?string $password = null): string
    {
        $cards = Card::whereIn('id', $cardIds)->get();
        $content = $cards->map(function ($card) {
            return $card->card_no;
        })->implode("\n");
        
        $filename = 'cards_' . date('YmdHis') . '.txt';
        $tempFile = sys_get_temp_dir() . '/' . $filename;
        file_put_contents($tempFile, $content);
        
        if ($password) {
            // 使用ZIP密码保护
            $zipFile = sys_get_temp_dir() . '/cards_' . date('YmdHis') . '.zip';
            $zip = new \ZipArchive();
            if ($zip->open($zipFile, \ZipArchive::CREATE) === true) {
                $zip->setPassword($password);
                $zip->addFile($tempFile, $filename);
                $zip->setEncryptionName($filename, \ZipArchive::EM_AES256);
            }
            $zip->close();
            unlink($tempFile);
            return $zipFile;
        }
        
        return $tempFile;
    }
}
