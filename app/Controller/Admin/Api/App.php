<?php
declare(strict_types=1);

namespace App\Controller\Admin\Api;

use App\Interceptor\ManageSession;
use App\Interceptor\Waf;
use App\Model\ManageLog;
use App\Util\Opcache;
use App\Util\PayConfig;
use App\Util\Theme;
use Kernel\Annotation\Inject;
use Kernel\Annotation\Interceptor;
use Kernel\Exception\JSONException;

#[Interceptor([Waf::class, ManageSession::class], Interceptor::TYPE_API)]
class App extends Manage
{
    /**
     * 版本列表 - 已禁用云端连接
     * @return array
     */
    public function versions(): array
    {
        return $this->json(200, "ok", []);
    }

    /**
     * 最新版本检测 - 已禁用云端连接
     * @return array
     */
    public function latest(): array
    {
        $local = config("app")['version'];
        return $this->json(200, 'ok', ["local" => $local, "latest" => true, "version" => $local]);
    }

    /**
     * 系统更新 - 已禁用云端连接
     * @return array
     */
    public function update(): array
    {
        return $this->json(200, "当前为独立版本，无需更新");
    }

    /**
     * 公告 - 已禁用云端连接
     * @return array
     */
    public function ad(): array
    {
        return $this->json(200, "ok", []);
    }

    /**
     * 初始化检测 - 已禁用云端连接
     * @throws JSONException
     */
    public function init(): array
    {
        return $this->json(200, "ok");
    }

    /**
     * 验证码 - 已禁用云端连接
     * @return array
     */
    public function captcha(): array
    {
        return $this->json(200, "ok", []);
    }

    /**
     * 注册 - 已禁用云端连接
     * @throws JSONException
     */
    public function register(): array
    {
        throw new JSONException("应用商店已关闭");
    }

    /**
     * 登录 - 已禁用云端连接
     * @throws JSONException
     */
    public function login(): array
    {
        throw new JSONException("应用商店已关闭");
    }

    /**
     * 插件列表 - 已禁用云端连接
     * @return array
     */
    public function plugins(): array
    {
        return $this->json(data: [
            "list" => [],
            "total" => 0
        ]);
    }

    /**
     * 获取更新 - 已禁用云端连接
     * @return array
     */
    public function getUpdates(): array
    {
        return $this->json(200, "ok", []);
    }

    /**
     * 删除更新缓存 - 已禁用云端连接
     * @return array
     */
    public function delUpdates(): array
    {
        return $this->json(200, "ok");
    }

    /**
     * 购买 - 已禁用云端连接
     * @throws JSONException
     */
    public function purchase(): array
    {
        throw new JSONException("应用商店已关闭");
    }

    /**
     * 安装插件 - 已禁用云端连接
     * @throws JSONException
     */
    public function install(): array
    {
        throw new JSONException("应用商店已关闭，请手动安装插件");
    }

    /**
     * 更新插件 - 已禁用云端连接
     * @throws JSONException
     */
    public function upgrade(): array
    {
        throw new JSONException("应用商店已关闭");
    }

    /**
     * 卸载插件 - 本地卸载
     * @return array
     */
    public function uninstall(): array
    {
        //卸载插件
        $pluginKey = (string)$_POST['plugin_key'];
        $type = (int)$_POST['type'];

        //默认位置，通用插件
        $pluginPath = BASE_PATH . "/app/Plugin/{$pluginKey}/";
        if ($type == 1) {
            //支付插件
            $pluginPath = BASE_PATH . "/app/Pay/{$pluginKey}/";
        } elseif ($type == 2) {
            //网站模板
            $pluginPath = BASE_PATH . "/app/View/User/Theme/{$pluginKey}/";
        }
        if (is_dir($pluginPath)) {
            //开始卸载
            \App\Util\File::delDirectory($pluginPath);
        }

        ManageLog::log($this->getManage(), "卸载了应用({$pluginKey})");
        return $this->json(200, "卸载完成");
    }

    /**
     * 开发者插件 - 已禁用云端连接
     * @return array
     */
    public function developerPlugins(): array
    {
        return $this->json(data: [
            "list" => [],
            "total" => 0
        ]);
    }

    /**
     * 创建插件 - 已禁用云端连接
     * @throws JSONException
     */
    public function developerCreatePlugin(): array
    {
        throw new JSONException("应用商店已关闭");
    }

    /**
     * 创建插件包 - 已禁用云端连接
     * @throws JSONException
     */
    public function developerCreateKit(): array
    {
        throw new JSONException("应用商店已关闭");
    }

    /**
     * 删除插件 - 已禁用云端连接
     * @throws JSONException
     */
    public function developerDeletePlugin(): array
    {
        throw new JSONException("应用商店已关闭");
    }

    /**
     * 更新插件 - 已禁用云端连接
     * @throws JSONException
     */
    public function developerUpdatePlugin(): array
    {
        throw new JSONException("应用商店已关闭");
    }

    /**
     * 插件定价 - 已禁用云端连接
     * @throws JSONException
     */
    public function developerPluginPriceSet(): array
    {
        throw new JSONException("应用商店已关闭");
    }

    /**
     * 购买记录 - 已禁用云端连接
     * @return array
     */
    public function purchaseRecords(): array
    {
        return $this->json(data: ["list" => []]);
    }

    /**
     * 解绑 - 已禁用云端连接
     * @return array
     */
    public function unbind(): array
    {
        return $this->json(200, "应用商店已关闭");
    }

    /**
     * 设置服务器 - 已禁用云端连接
     * @return array
     */
    public function setServer(): array
    {
        return $this->json(200, "应用商店已关闭");
    }

    /**
     * 等级列表 - 已禁用云端连接
     * @return array
     */
    public function levels(): array
    {
        return $this->json(data: ["list" => []]);
    }

    /**
     * 绑定等级 - 已禁用云端连接
     * @return array
     */
    public function bindLevel(): array
    {
        return $this->json(200, "应用商店已关闭");
    }

    /**
     * 服务信息 - 已禁用云端连接
     * @return array
     */
    public function service(): array
    {
        return $this->json(data: ["id" => 0, "username" => "本地模式", "level" => 0, "developer" => 0, "balance" => 0]);
    }

    /**
     * 修改密码 - 已禁用云端连接
     * @throws JSONException
     */
    public function editPassword(): array
    {
        throw new JSONException("应用商店已关闭");
    }
}
