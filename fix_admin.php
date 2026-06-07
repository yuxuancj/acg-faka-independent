<?php
declare(strict_types=1);

/**
 * ACG-Faka 管理员账号修复脚本
 * 使用方法：上传到网站根目录，访问 http://your-domain.com/fix_admin.php
 */

const BASE_PATH = __DIR__ . "/";

require(BASE_PATH . '/vendor/autoload.php');

use App\Util\Str;
use App\Model\Manage;

// 检查是否已安装
$lockFile = BASE_PATH . '/kernel/Install/Lock';
if (!file_exists($lockFile)) {
    die("错误：系统尚未安装，请先运行安装程序");
}

// 获取数据库配置
$dbConfig = require(BASE_PATH . '/config/database.php');

// 输出信息
echo "<!DOCTYPE html><html><head><meta charset='utf-8'><title>管理员账号修复</title>";
echo "<style>body{font-family:Arial;margin:40px;background:#f5f5f5;}.container{max-width:600px;margin:0 auto;background:white;padding:30px;border-radius:10px;box-shadow:0 2px 10px rgba(0,0,0,0.1);}";
echo ".success{color:#4CAF50;background:#d4edda;padding:10px;margin:10px 0;border-radius:5px;}";
echo ".error{color:#dc3545;background:#f8d7da;padding:10px;margin:10px 0;border-radius:5px;}";
echo "input{width:100%;padding:10px;margin:10px 0;border:1px solid #ddd;border-radius:5px;}";
echo "button{background:#4CAF50;color:white;padding:12px 30px;border:none;border-radius:5px;cursor:pointer;font-size:16px;}";
echo "</style></head><body><div class='container'>";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'];
    $password = $_POST['password'];
    $nickname = $_POST['nickname'] ?: '管理员';
    
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo "<div class='error'>邮箱格式不正确</div>";
    } elseif (strlen($password) < 6) {
        echo "<div class='error'>密码至少需要6位</div>";
    } else {
        try {
            // 初始化数据库连接
            $capsule = new \Illuminate\Database\Capsule\Manager();
            $capsule->addConnection($dbConfig);
            $capsule->setAsGlobal();
            $capsule->bootEloquent();
            
            // 检查是否已存在管理员
            $existing = Manage::query()->where('email', $email)->first();
            
            // 生成密码
            $salt = Str::generateRandStr(32);
            $pw = Str::generatePassword($password, $salt);
            
            if ($existing) {
                // 更新现有管理员
                $existing->password = $pw;
                $existing->salt = $salt;
                $existing->nickname = $nickname;
                $existing->status = 1;
                $existing->save();
                echo "<div class='success'>✅ 管理员账号更新成功！</div>";
            } else {
                // 创建新管理员
                Manage::create([
                    'email' => $email,
                    'password' => $pw,
                    'salt' => $salt,
                    'nickname' => $nickname,
                    'avatar' => '/favicon.ico',
                    'status' => 1,
                    'type' => 0,
                    'create_time' => date('Y-m-d H:i:s')
                ]);
                echo "<div class='success'>✅ 管理员账号创建成功！</div>";
            }
            
            echo "<p>账号：$email</p>";
            echo "<p>密码：$password</p>";
            echo "<p><a href='/admin/authentication/login' style='color:#4CAF50;'>点击登录后台</a></p>";
            
        } catch (Exception $e) {
            echo "<div class='error'>❌ 操作失败：" . $e->getMessage() . "</div>";
        }
    }
}

echo "<h2>🔧 管理员账号修复</h2>";
echo "<p>如果登录提示'不存在账号'，请填写以下信息创建/修复管理员账号：</p>";
echo "<form method='post'>";
echo "<input type='email' name='email' placeholder='管理员邮箱' required><br>";
echo "<input type='password' name='password' placeholder='登录密码（至少6位）' required><br>";
echo "<input type='text' name='nickname' placeholder='昵称（可选）'><br>";
echo "<button type='submit'>创建/修复账号</button>";
echo "</form>";

echo "</div></body></html>";
