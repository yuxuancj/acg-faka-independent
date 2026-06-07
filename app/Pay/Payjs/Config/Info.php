<?php
declare(strict_types=1);

return [
    "name" => "PAYJS",
    "description" => "PAYJS个人免签约支付接口",
    "author" => "System",
    "version" => "1.0.0",
    "config" => [
        "mchid" => [
            "title" => "商户号",
            "description" => "PAYJS商户号",
            "type" => "input",
            "rule" => "required"
        ],
        "key" => [
            "title" => "通信密钥",
            "description" => "PAYJS通信密钥",
            "type" => "input",
            "rule" => "required"
        ]
    ]
];