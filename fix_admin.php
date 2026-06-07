<?php
declare(strict_types=1);

/**
 * ACG-Faka 管理员账号修复脚本 v2
 * 使用方法：上传到网站根目录，访问 http://your-domain.com/fix_admin.php
 */

const BASE_PATH = __DIR__ . "/";

// 禁用所有错误显示
error_reporting(0);
ini_set('display_errors', '0');

require(BASE_PATH . '/vendor/autoload.php');

use App\Util\Str;

// 检查是否已安装
$lockFile = BASE_PATH . '/kernel/Install/Lock';
if (!file_exists($lockFile)) {
    die("错误：系统尚未安装，请先运行安装程序");
}

// 获取数据库配置
$dbConfig = require(BASE_PATH . '/config/database.php');

// 输出信息
echo "<!DOCTYPE html><html><head><meta charset='utf-8'><title>管理员账号修复</title>";
echo "<style>
body{font-family:Arial;margin:40px;background:#f5f5f5;}
.container{max-width:600px;margin:0 auto;background:white;padding:30px;border-radius:10px;box-shadow:0 2px 10px rgba(0,0,0,0.1);}
.success{color:#28a745;background:#d4edda;padding:15px;margin:15px 0;border-radius:5px;border:1px solid #c3e6cb;}
.error{color:#dc3545;background:#f8d7da;padding:15px;margin:15px 0;border-radius:5px;border:1px solid #f5c6cb;}
.info{color:#004085;background:#cce5ff;padding:15px;margin:15px 0;border-radius:5px;border:1px solid #b8daff;}
input{width:100%;padding:12px;margin:10px 0;border:1px solid #ddd;border-radius:5px;box-sizing:border-box;}
button{background:#28a745;color:white;padding:12px 30px;border:none;border-radius:5px;cursor:pointer;font-size:16px;width:100%;}
button:hover{background:#218838;}
table{width:100%;border-collapse:collapse;margin:15px 0;}
th,td{padding:10px;border:1px solid #ddd;text-align:left;}
th{background:#f8f9fa;}
</style></head><body><div class='container'>";

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'];
    $password = $_POST['password'];
    $nickname = $_POST['nickname'] ?: '管理员';

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo "<div class='error'>❌ 邮箱格式不正确</div>";
    } elseif (strlen($password) < 6) {
        echo "<div class='error'>❌ 密码至少需要6位</div>";
    } else {
        try {
            // 初始化数据库连接
            $capsule = new \Illuminate\Database\Capsule\Manager();
            $capsule->addConnection($dbConfig);
            $capsule->setAsGlobal();
            $capsule->bootEloquent();

            // 获取表前缀
            $prefix = $dbConfig['prefix'] ?? '';
            $tableName = $prefix . 'manage';

            // 生成密码
            $salt = Str::generateRandStr(32);
            $pw = Str::generatePassword($password, $salt);

            // 检查数据库连接
            $pdo = new PDO(
                "mysql:host={$dbConfig['host']};dbname={$dbConfig['database']};charset=utf8mb4",
                $dbConfig['username'],
                $dbConfig['password']
            );

            // 检查表是否存在
            $stmt = $pdo->query("SHOW TABLES LIKE '{$tableName}'");
            if ($stmt->rowCount() == 0) {
                echo "<div class='error'>❌ 表 {$tableName} 不存在！请检查数据库配置。</div>";
                echo "<p>当前配置的前缀是: <strong>{$prefix}</strong></p>";
                echo "<p>请检查数据库中实际的表前缀。</p>";
            } else {
                // 检查是否已存在管理员
                $stmt = $pdo->prepare("SELECT * FROM {$tableName} WHERE email = ?");
                $stmt->execute([$email]);
                $existing = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($existing) {
                    // 更新现有管理员
                    $stmt = $pdo->prepare("UPDATE {$tableName} SET password = ?, salt = ?, nickname = ?, status = 1 WHERE email = ?");
                    $stmt->execute([$pw, $salt, $nickname, $email]);
                    echo "<div class='success'>✅ 管理员账号更新成功！</div>";
                } else {
                    // 创建新管理员
                    $stmt = $pdo->prepare("INSERT INTO {$tableName} (email, password, salt, nickname, avatar, status, type, create_time) VALUES (?, ?, ?, ?, ?, 1, 0, NOW())");
                    $stmt->execute([$email, $pw, $salt, $nickname, '/favicon.ico']);
                    echo "<div class='success'>✅ 管理员账号创建成功！</div>";
                }

                echo "<div class='info'>";
                echo "<h3>📋 账号信息</h3>";
                echo "<table>";
                echo "<tr><th>邮箱</th><td>{$email}</td></tr>";
                echo "<tr><th>密码</th><td>{$password}</td></tr>";
                echo "<tr><th>表名</th><td>{$tableName}</td></tr>";
                echo "</table>";
                echo "</div>";

                echo "<p style='text-align:center;margin-top:20px;'>";
                echo "<a href='/admin/authentication/login' style='color:#28a745;font-size:18px;text-decoration:none;'>👉 点击登录后台</a>";
                echo "</p>";
            }

        } catch (Exception $e) {
            echo "<div class='error'>❌ 操作失败：" . $e->getMessage() . "</div>";
        }
    }
}

echo "<h2>🔧 管理员账号修复工具</h2>";
echo "<p>如果登录提示'不存在账号'，请填写以下信息：</p>";
echo "<form method='post'>";
echo "<input type='email' name='email' placeholder='管理员邮箱' required><br>";
echo "<input type='password' name='password' placeholder='登录密码（至少6位）' required><br>";
echo "<input type='text' name='nickname' placeholder='昵称（可选）'><br>";
echo "<button type='submit'>创建/修复账号</button>";
echo "</form>";

echo "<div style='margin-top:20px;padding:15px;background:#fff3cd;border-radius:5px;'>";
echo "<h4>⚠️ 安全提示</h4>";
echo "<p>修复完成后请删除以下文件：</p>";
echo "<ul>";
echo "<li>fix_admin.php</li>";
echo "<li>install.php</li>";
echo "<li>install_submit.php</li>";
echo "</ul>";
echo "</div>";

echo "</div></body></html>";
