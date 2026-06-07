<?php
declare(strict_types=1);

/**
 * 关闭错误显示
 */
error_reporting(0);
ini_set('display_errors', '0');

/**
 * 开启DEBUG
 */
const DEBUG = false;
require("kernel/Kernel.php");
