<?php
declare(strict_types=1);

namespace App\Controller;


use App\Controller\Base\API\User;
use App\Service\App;
use App\Util\Client;
use App\Util\Opcache;
use App\Util\Str;
use App\Util\Validation;
use Kernel\Annotation\Inject;
use Kernel\Exception\JSONException;
use Kernel\Util\SQL;
use Kernel\Util\View;

class Install extends User
{

    /**
     * 伪静态探测
     * @return array
     */
    public function rewrite(): array
    {
        return $this->json(200, "success");
    }

    /**
     * 环境检测API
     * @return array
     */
    public function checkEnv(): array
    {
        $phpVersion = phpversion();
        $phpParts = explode('.', $phpVersion);
        $phpOk = (int)$phpParts[0] >= 8;
        
        $exts = [
            'gd' => extension_loaded('gd'),
            'curl' => extension_loaded('curl'),
            'pdo_mysql' => extension_loaded('pdo_mysql'),
            'json' => extension_loaded('json'),
            'zip' => extension_loaded('zip')
        ];
        
        $canInstall = $phpOk;
        foreach ($exts as $ext) {
            if (!$ext) {
                $canInstall = false;
                break;
            }
        }
        
        return $this->json(200, 'ok', [
            'php_version' => $phpVersion,
            'php_ok' => $phpOk,
            'exts' => $exts,
            'can_install' => $canInstall
        ]);
    }

    /**
     * 安装入口 - 重定向到 step
     * @return void
     */
    public function index(): void
    {
        Client::redirect("/install/step");
    }

    /**
     * @return string
     */
    public function step(): string
    {
        if (file_exists(BASE_PATH . '/kernel/Install/Lock')) {
            Client::redirect("/", "どうして?", 3);
        }
        
        // 确保runtime目录存在
        $dirs = [
            BASE_PATH . '/runtime',
            BASE_PATH . '/runtime/view',
            BASE_PATH . '/runtime/view/cache',
            BASE_PATH . '/runtime/view/compile',
            BASE_PATH . '/runtime/plugin'
        ];
        foreach ($dirs as $dir) {
            if (!is_dir($dir)) {
                mkdir($dir, 0777, true);
            }
        }
        
        $data = [];
        $data['version'] = config("app")['version'];
        $data['php_version'] = phpversion();

        $data['ext']['gd'] = extension_loaded("gd");
        $data['ext']['curl'] = extension_loaded("curl");
        $data['ext']['pdo'] = extension_loaded("PDO");
        $data['ext']['pdo_mysql'] = extension_loaded("pdo_mysql");
        $data['ext']['date'] = extension_loaded("date");
        $data['ext']['json'] = extension_loaded("json");
        $data['ext']['session'] = extension_loaded("session");
        $data['ext']['zip'] = extension_loaded("zip");


        $data['install'] = true;
        // 正确比较PHP版本
        $phpVersion = explode('.', $data['php_version']);
        if ((int)$phpVersion[0] < 8) {
            $data['install'] = false;
        } else {
            foreach ($data['ext'] as $ext) {
                if (!$ext) {
                    $data['install'] = false;
                }
            }
        }

        return View::render("Install.html", $data);
    }


    /**
     * @return array
     * @throws \Kernel\Exception\JSONException
     */
    public function submit(): array
    {
        if (file_exists(BASE_PATH . '/kernel/Install/Lock')) {
            throw new JSONException("您已经安装过了，如果想重新安装，请删除" . '/kernel/Install/Lock' . '文件，即可重新安装!');
        }
        $map = $_POST;

        foreach ($map as $k => $v) {
            $map[$k] = trim((string)$v);
        }

        $host = $map['host'] == '' ? 'localhost' : $map['host'];

        $email = $map['email'];
        $nickname = $map['nickname'];
        $login_password = $map['login_password'];

        if (!Validation::email($email)) {
            throw new JSONException("管理员邮箱格式不正确");
        }

        if (!Validation::password($login_password)) {
            throw new JSONException("您设置的登录密码过于简单");
        }

        $sqlFile = BASE_PATH . '/kernel/Install/Full_Install.sql';

        $salt = Str::generateRandStr(32);
        $pw = Str::generatePassword($login_password, $salt);

        $sqlSrc = (string)file_get_contents($sqlFile);
        $sqlSrc = str_replace('__MANAGE_EMAIL__', $email, $sqlSrc);
        $sqlSrc = str_replace('__MANAGE_PASSWORD__', $pw, $sqlSrc);
        $sqlSrc = str_replace('__MANAGE_SALT__', $salt, $sqlSrc);
        $sqlSrc = str_replace('__MANAGE_NICKNAME__', $nickname, $sqlSrc);

        if (file_put_contents($sqlFile . ".tmp", $sqlSrc) === false) {
            throw new JSONException("没有写入权限，请检查权限是否足够");
        }

        //导入数据库
        SQL::import($sqlFile . ".tmp", $host, $map['database'], $map['username'], $map['password'], $map['prefix']);

        //更新配置文件
        $configFile = BASE_PATH . '/config/database.php';
        $configContent = (string)file_get_contents($configFile);

        $configContent = str_replace("localhost", $host, $configContent);
        $configContent = str_replace("acgshop", $map['database'], $configContent);
        $configContent = str_replace("root", $map['username'], $configContent);
        $configContent = str_replace("password", $map['password'], $configContent);
        $configContent = str_replace("acg_", $map['prefix'], $configContent);

        file_put_contents($configFile, $configContent);

        //创建安装锁文件
        file_put_contents(BASE_PATH . '/kernel/Install/Lock', date("Y-m-d H:i:s"));

        //删除临时文件
        unlink($sqlFile . ".tmp");

        //更新配置文件
        $appConfigFile = BASE_PATH . '/config/app.php';
        $appConfigContent = (string)file_get_contents($appConfigFile);
        $appConfigContent = str_replace("__APP_KEY__", Str::generateRandStr(32), $appConfigContent);
        file_put_contents($appConfigFile, $appConfigContent);

        //记录日志
        ManageLog::log($email, "系统安装完成");

        return $this->json(200, '安装成功');
    }

    /**
     * 更新
     * @return string
     * @throws ViewException
     */
    public function update(): string
    {
        if (!file_exists(BASE_PATH . '/kernel/Install/Lock')) {
            Client::redirect("/install/step", "请先安装", 3);
        }

        $data = [];
        $data['version'] = config("app")['version'];
        $data['currentVersion'] = $data['version'];

        $data['versions'] = [];

        $versionList = App::getVersions();
        foreach ($versionList as $version) {
            if (version_compare($version['version'], $data['version']) > 0) {
                $data['versions'][] = $version;
            }
        }

        return $this->render("更新", "Install/Update.html", $data);
    }


    /**
     * 更新提交
     * @return array
     * @throws JSONException
     */
    public function updateSubmit(): array
    {
        $version = (string)$_POST['version'];

        $versionInfo = App::getVersionInfo($version);

        if (empty($versionInfo)) {
            throw new JSONException("版本信息不存在");
        }

        $downloadUrl = $versionInfo['download'];
        $tmpFile = BASE_PATH . '/runtime/update.zip';

        //下载更新包
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $downloadUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_TIMEOUT, 300);
        $content = curl_exec($ch);
        curl_close($ch);

        if ($content === false) {
            throw new JSONException("下载更新包失败");
        }

        file_put_contents($tmpFile, $content);

        //解压更新包
        $zip = new \ZipArchive();
        if ($zip->open($tmpFile) !== true) {
            throw new JSONException("解压更新包失败");
        }
        $zip->extractTo(BASE_PATH);
        $zip->close();

        //删除临时文件
        unlink($tmpFile);

        //更新版本号
        $configFile = BASE_PATH . '/config/app.php';
        $configContent = (string)file_get_contents($configFile);
        $configContent = str_replace("'version' => '" . config("app")['version'] . "'", "'version' => '$version'", $configContent);
        file_put_contents($configFile, $configContent);

        //更新锁文件
        file_put_contents(BASE_PATH . '/kernel/Install/Lock', date("Y-m-d H:i:s"));

        //清空缓存
        Opcache::clear();

        return $this->json(200, '更新成功');
    }
}
