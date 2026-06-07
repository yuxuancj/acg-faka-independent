<?php
declare(strict_types=1);

return [
    "name" => "易支付",
    "description" => "易支付聚合支付接口",
    "author" => "System",
    "version" => "1.0.0",
    "config" => [
        "api_url" => [
            "title" => "API地址",
            "description" => "易支付接口地址",
            "type" => "input",
            "rule" => "required"
        ],
        "pid" => [
            "title" => "商户ID",
            "description" => "易支付商户号",
            "type" => "input",
            "rule" => "required"
        ],
        "key" => [
            "title" => "商户密钥",
            "description" => "易支付密钥",
            "type" => "input",
            "rule" => "required"
        ]
    ]
];