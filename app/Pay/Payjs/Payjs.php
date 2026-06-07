<?php
declare(strict_types=1);

namespace App\Pay\Payjs;

use App\Entity\PayEntity;
use App\Pay\Base;
use App\Pay\Pay;
use Kernel\Exception\JSONException;

class Payjs extends Base implements Pay
{
    /**
     * @return PayEntity
     * @throws JSONException
     */
    public function trade(): PayEntity
    {
        $apiUrl = 'https://payjs.cn/api/native';
        $params = [
            'mchid' => $this->config['mchid'],
            'total_fee' => (int)($this->amount * 100),
            'out_trade_no' => $this->tradeNo,
            'notify_url' => $this->callbackUrl
        ];
        
        $params['sign'] = $this->generateSign($params);
        
        $response = $this->http()->post($apiUrl, [
            'form_params' => $params,
            'verify' => false
        ]);
        
        $result = json_decode((string)$response->getBody(), true);
        
        if ($result['return_code'] !== 1) {
            throw new JSONException('PAYJS下单失败: ' . ($result['return_msg'] ?? '未知错误'));
        }
        
        $payEntity = new PayEntity();
        $payEntity->setType(self::TYPE_REDIRECT);
        $payEntity->setData($result['qrcode']);
        
        $this->log("PAYJS发起支付: " . $this->tradeNo . " 金额: " . $this->amount);
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
            if ($v !== '' && !is_array($v)) {
                $stringToBeSigned .= "$k=$v&";
            }
        }
        $stringToBeSigned .= 'key=' . $this->config['key'];
        return strtoupper(md5($stringToBeSigned));
    }

    /**
     * 验证回调
     */
    public function verify(): bool
    {
        $params = $_POST;
        $sign = $params['sign'];
        unset($params['sign']);
        
        $localSign = $this->generateSign($params);
        
        if ($sign === $localSign) {
            $this->log("PAYJS回调验证成功: " . $params['out_trade_no']);
            return true;
        }
        
        $this->log("PAYJS回调验证失败: " . $params['out_trade_no']);
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