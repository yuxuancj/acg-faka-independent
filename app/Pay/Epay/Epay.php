<?php
declare(strict_types=1);

namespace App\Pay\Epay;

use App\Entity\PayEntity;
use App\Pay\Base;
use App\Pay\Pay;
use Kernel\Exception\JSONException;

class Epay extends Base implements Pay
{
    /**
     * @return PayEntity
     * @throws JSONException
     */
    public function trade(): PayEntity
    {
        $apiUrl = rtrim($this->config['api_url'], '/');
        $params = [
            'pid' => $this->config['pid'],
            'type' => $this->code,
            'notify_url' => $this->callbackUrl,
            'return_url' => $this->returnUrl,
            'out_trade_no' => $this->tradeNo,
            'name' => '商品购买',
            'money' => $this->amount,
            'clientip' => $this->clientIp
        ];

        // 生成签名
        ksort($params);
        $signStr = http_build_query($params);
        $params['sign'] = md5($signStr . $this->config['key']);
        $params['sign_type'] = 'MD5';

        $payUrl = $apiUrl . '/submit.php?' . http_build_query($params);
        $payEntity = new PayEntity();
        $payEntity->setType(self::TYPE_REDIRECT);
        $payEntity->setData($payUrl);
        
        $this->log("易支付发起支付: " . $this->tradeNo . " 金额: " . $this->amount);
        return $payEntity;
    }

    /**
     * 验证回调
     */
    public function verify(): bool
    {
        $data = $_GET + $_POST;
        $sign = $data['sign'];
        unset($data['sign'], $data['sign_type']);
        
        ksort($data);
        $signStr = http_build_query($data);
        $localSign = md5($signStr . $this->config['key']);
        
        if ($sign === $localSign) {
            $this->log("易支付回调验证成功: " . $data['trade_no']);
            return true;
        }
        
        $this->log("易支付回调验证失败: " . $data['trade_no']);
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