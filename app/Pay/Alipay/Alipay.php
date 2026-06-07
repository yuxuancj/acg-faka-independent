<?php
declare(strict_types=1);

namespace App\Pay\Alipay;

use App\Entity\PayEntity;
use App\Pay\Base;
use App\Pay\Pay;
use Kernel\Exception\JSONException;

class Alipay extends Base implements Pay
{
    /**
     * @return PayEntity
     * @throws JSONException
     */
    public function trade(): PayEntity
    {
        $gatewayUrl = $this->config['gateway_url'];
        $params = [
            'app_id' => $this->config['app_id'],
            'method' => $this->code === 'wap' ? 'alipay.trade.wap.pay' : 'alipay.trade.page.pay',
            'charset' => 'UTF-8',
            'sign_type' => 'RSA2',
            'timestamp' => date('Y-m-d H:i:s'),
            'version' => '1.0',
            'notify_url' => $this->callbackUrl,
            'return_url' => $this->returnUrl,
            'biz_content' => json_encode([
                'out_trade_no' => $this->tradeNo,
                'product_code' => $this->code === 'wap' ? 'QUICK_WAP_WAY' : 'FAST_INSTANT_TRADE_PAY',
                'total_amount' => (string)$this->amount,
                'subject' => '商品购买'
            ], JSON_UNESCAPED_UNICODE)
        ];

        $params['sign'] = $this->generateSign($params);
        $payUrl = $gatewayUrl . '?' . http_build_query($params);
        
        $payEntity = new PayEntity();
        $payEntity->setType(self::TYPE_REDIRECT);
        $payEntity->setData($payUrl);
        
        $this->log("支付宝发起支付: " . $this->tradeNo . " 金额: " . $this->amount);
        return $payEntity;
    }

    /**
     * 生成签名
     */
    private function generateSign($params): string
    {
        ksort($params);
        $stringToBeSigned = '';
        foreach ($params as $k => $v) {
            if ($v !== '' && !is_array($v) && substr($v, 0, 1) !== '@') {
                $stringToBeSigned .= "$k=$v&";
            }
        }
        $stringToBeSigned = substr($stringToBeSigned, 0, -1);
        
        $privateKey = "-----BEGIN RSA PRIVATE KEY-----\n" . 
                      chunk_split($this->config['merchant_private_key'], 64, "\n") . 
                      "-----END RSA PRIVATE KEY-----";
        
        openssl_sign($stringToBeSigned, $sign, $privateKey, OPENSSL_ALGO_SHA256);
        return base64_encode($sign);
    }

    /**
     * 验证回调
     */
    public function verify(): bool
    {
        $params = $_POST;
        $sign = base64_decode($params['sign']);
        unset($params['sign'], $params['sign_type']);
        
        ksort($params);
        $stringToBeSigned = '';
        foreach ($params as $k => $v) {
            if ($v !== '' && !is_array($v)) {
                $stringToBeSigned .= "$k=$v&";
            }
        }
        $stringToBeSigned = substr($stringToBeSigned, 0, -1);
        
        $publicKey = "-----BEGIN PUBLIC KEY-----\n" . 
                     chunk_split($this->config['alipay_public_key'], 64, "\n") . 
                     "-----END PUBLIC KEY-----";
        
        $result = openssl_verify($stringToBeSigned, $sign, $publicKey, OPENSSL_ALGO_SHA256);
        
        if ($result === 1) {
            $this->log("支付宝回调验证成功: " . $params['out_trade_no']);
            return true;
        }
        
        $this->log("支付宝回调验证失败: " . $params['out_trade_no']);
        return false;
    }

    /**
     * 获取订单号
     */
    public function tradeNo(): string
    {
        return $_REQUEST['out_trade_no'];
    }
}