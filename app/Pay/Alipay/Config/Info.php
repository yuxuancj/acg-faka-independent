<?php
declare(strict_types=1);

return [
    "name" => "支付宝",
    "description" => "支付宝电脑网站支付/手机网站支付",
    "author" => "System",
    "version" => "1.0.0",
    "config" => [
        "app_id" => [
            "title" => "应用ID",
            "description" => "支付宝开放平台应用AppID",
            "type" => "input",
            "rule" => "required"
        ],
        "merchant_private_key" => [
            "title" => "应用私钥",
            "description" => "支付宝应用私钥",
            "type" => "textarea",
            "rule" => "required"
        ],
        "alipay_public_key" => [
            "title" => "支付宝公钥",
            "description" => "支付宝公钥",
            "type" => "textarea",
            "rule" => "required"
        ],
        "gateway_url" => [
            "title" => "网关地址",
            "description" => "支付宝网关地址，正式环境使用https://openapi.alipay.com/gateway.do",
            "type" => "input",
            "rule" => "required",
            "value" => "https://openapi.alipay.com/gateway.do"
        ]
    ]
];