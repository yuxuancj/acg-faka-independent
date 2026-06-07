<?php
declare(strict_types=1);

/**
 * ACG-Faka 安装处理脚本
 * 处理安装提交请求
 */

const DEBUG = true;
const BASE_PATH = __DIR__ . "/";

require(BASE_PATH . '/vendor/autoload.php');

use App\Util\Str;
use Kernel\Util\SQL;

// 检查是否已安装
if (file_exists(BASE_PATH . '/kernel/Install/Lock')) {
    echo json_encode(['code' => 400, 'msg' => '您已经安装过了，如果想重新安装，请删除 kernel/Install/Lock 文件']);
    exit;
}

// 检查请求方法
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['code' => 400, 'msg' => '请使用POST方法']);
    exit;
}

// 获取表单数据
$map = $_POST;
foreach ($map as $k => $v) {
    $map[$k] = trim((string)$v);
}

$host = $map['host'] == '' ? 'localhost' : $map['host'];
$email = $map['email'];
$nickname = $map['nickname'];
$login_password = $map['login_password'];

// 验证邮箱
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['code' => 400, 'msg' => '管理员邮箱格式不正确']);
    exit;
}

// 验证密码
if (strlen($login_password) < 6) {
    echo json_encode(['code' => 400, 'msg' => '您设置的登录密码过于简单']);
    exit;
}

$sqlFile = BASE_PATH . '/kernel/Install/Install.sql';

if (!file_exists($sqlFile)) {
    echo json_encode(['code' => 400, 'msg' => '找不到安装SQL文件']);
    exit;
}

$salt = Str::generateRandStr(32);
$pw = Str::generatePassword($login_password, $salt);

$sqlSrc = (string)file_get_contents($sqlFile);
$sqlSrc = str_replace('__MANAGE_EMAIL__', $email, $sqlSrc);
$sqlSrc = str_replace('__MANAGE_PASSWORD__', $pw, $sqlSrc);
$sqlSrc = str_replace('__MANAGE_SALT__', $salt, $sqlSrc);
$sqlSrc = str_replace('__MANAGE_NICKNAME__', $nickname, $sqlSrc);

if (file_put_contents($sqlFile . ".tmp", $sqlSrc) === false) {
    echo json_encode(['code' => 400, 'msg' => '没有写入权限，请检查权限是否足够']);
    exit;
}

try {
    // 导入数据库
    SQL::import($sqlFile . ".tmp", $host, $map['database'], $map['username'], $map['password'], $map['prefix']);
    
    // 设置数据库账号密码
    $configContent = '<?php return ' . var_export([
        'driver' => 'mysql',
        'host' => $host,
        'database' => $map['database'],
        'username' => $map['username'],
        'password' => $map['password'],
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_unicode_ci',
        'prefix' => $map['prefix']
    ], true) . ';';
    
    if (file_put_contents(BASE_PATH . "/config/database.php", $configContent) === false) {
        throw new Exception('无法写入数据库配置文件');
    }
    
    unlink($sqlFile . ".tmp");
    file_put_contents(BASE_PATH . '/kernel/Install/Lock', "");
    
    echo json_encode(['code' => 200, 'msg' => '安装完成']);
} catch (Exception $e) {
    if (file_exists($sqlFile . ".tmp")) {
        unlink($sqlFile . ".tmp");
    }
    echo json_encode(['code' => 500, 'msg' => '安装失败: ' . $e->getMessage()]);
}
