# Sing-box for KernelSU

[![CI Build](https://github.com/Mice-Tailor-Infra/sing-box-ksu-module/actions/workflows/release.yml/badge.svg)](https://github.com/Mice-Tailor-Infra/sing-box-ksu-module/actions)

为 Android 设备深度定制的高性能 Sing-box 运行时环境，支持 KernelSU 模块化部署。

## 🎖️ 核心特性

| 特性             | 说明                                                                       |
| ---------------- | -------------------------------------------------------------------------- |
| **云端配置同步** | 安装时自动从 CDN 拉取最新配置模板，始终保持最新状态                        |
| **二进制归一化** | 所有二进制集中存放在 `/data/adb/sing-box-workspace/bin/`，模块目录极致轻量 |
| **系统级软链**   | 通过 `$MODPATH/system/bin/` 建立软链接，`sbc` 命令全局可用                 |
| **热更新**       | `sbc update` 指令支持 OTA 增量更新，无需重启手机                           |
| **凭证隔离**     | `.env` 文件与配置模板分离，保护隐私不外泄                                  |
| **配置覆写**     | 支持 Top/Mid/Bottom 多位注入与 JSON 自动清洗，实现零语法负担定制           |

## 🏗️ 架构设计

```
sing-box-ksu-module/
├── bin/                    # 临时传输介质，安装后移动到 Workspace
├── system/bin/            # 软链接目录（安装时创建）
├── customize.sh           # 安装逻辑：进程停止 → 二进制归一 → 软链创建 → 云端同步
├── service.sh             # 守护进程：开机自启 + 崩溃重试
├── module.prop            # 模块元信息（CI 自动注入版本）
└── README.md              # 本文档
```

### 运行时目录结构

```
/data/adb/sing-box-workspace/
├── bin/                   # 唯一二进制存储（sing-box, sbc, envsubst）
├── etc/                   # 配置目录
│   └── config.template.json  # 云端同步的配置文件
├── var/
│   ├── lib/               # 运行时数据
│   ├── run/               # PID 文件
│   └── log/               # 日志文件
└── .env                   # 凭证文件（本地生成，不打包）
```

## 🚀 快速开始

### 1. 安装模块

1. 在 Magisk/KernelSU 中刷入 ZIP 包
2. **重启手机**（首次安装必须重启以激活软链接）
3. 重启后即可使用 `sbc` 命令

### 2. 配置订阅

1. 编辑凭证文件：
   ```bash
   sbc edit
   ```
2. 参考 [环境变量](#环境变量) 章节填入您的订阅链接及相关密钥。

### 3. 管理服务

| 命令          | 说明                 |
| ------------- | -------------------- |
| `sbc start`   | 启动 sing-box 服务   |
| `sbc stop`    | 停止服务（优雅终止） |
| `sbc restart` | 重启服务             |
| `sbc status`  | 查看运行状态         |
| `sbc update`  | 从云端拉取最新配置   |
| `sbc logs`    | 查看实时日志         |
| `sbc edit`    | 编辑 .env 凭证       |

## 📦 模块结构

### 发布包内容（ZIP）

```
sing-box-ksu-module-v1.12.14-r21.zip
├── bin/               # sing-box 二进制（来自 CI 构建）
├── system/            # 空目录（用于存放软链接）
├── customize.sh       # 安装脚本
├── service.sh         # 守护进程脚本
├── module.prop        # 模块元信息
└── README.md          # 本文档
```

**注意**：配置文件和 .env 模板不打包，由安装时从云端拉取。

### 不包含的文件

- `config.template.json` - 云端管理
- `.env.example` - 云端管理
- `CHANGELOG.md` - 仅在仓库中
- `LICENSE` - 仅在仓库中

## 🔧 高级配置

### 环境变量

编辑 `$WORKSPACE/.env`：

```bash
# Sing-box 运行时环境变量模板
# 请将此文件复制为 .env 并填入真实信息

# --- 核心安全密钥 ---
# Clash API 的访问密钥 (用于 Dashboard 管理)
CLASH_API_SECRET="ChangeMe123456"

# --- 订阅源链接 ---
# 建议配置三个不同的机场以实现高可用负载均衡

# 主力机场
PROVIDER_NAME_1="机场A_主用"
SUB_URL_1="https://example.com/api/v1/client/subscribe?token=xxxxxx"

# 备用机场 A
PROVIDER_NAME_2="机场B_备用"
SUB_URL_2="https://backup1.com/link/yyyyyy"

# 备用机场 B
PROVIDER_NAME_3="机场C_保底"
SUB_URL_3="https://backup2.com/subscribe/zzzzzz"

# 自定义 0.0.0.0 Mixed 代理服务器账号密码
MIXED_PROXY_USERNAME="your_username"
MIXED_PROXY_PASSWORD="your_password"

# --- 高级配置覆写 (Override) ---
# [💡 特性]：支持 Top/Mid/Bottom 多位注入与 JSON 自动清洗 (Zero-Comma)。
# 无需写末尾逗号，系统自动修复语法。

# 路由规则 (ROUTE_RULES_TOP / _MID / _BOTTOM)
# ROUTE_RULES_TOP='{"domain": ["fast.com"], "outbound": "direct"}'

# DNS 规则 (DNS_RULES_TOP / _MID / _BOTTOM)
# DNS_RULES_TOP='{"domain": ["internal.corp"], "server": "local"}'
```

### 日志查看

```bash
# 实时日志
sbc logs

# 查看最后 100 行
tail -n 100 /data/adb/sing-box-workspace/var/log/sing-box.log
```

## 🏭 组件依赖

| 组件        | 仓库                                                                                        | 用途                      |
| ----------- | ------------------------------------------------------------------------------------------- | ------------------------- |
| 自动构建 CI | [sing-box-auto-build-ci](https://github.com/Mice-Tailor-Infra/sing-box-auto-build-ci)       | 多平台/架构自动构建流水线 |
| 配置模板    | [sing-box-config-templates](https://github.com/Mice-Tailor-Infra/sing-box-config-templates) | 移动端分流规则模板        |
| CDN 加速    | [miceworld.top](https://miceworld.top)                                                      | 全球加速分发              |

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源。

## 🙏 致谢

- [Sing-box](https://github.com/SagerNet/sing-box) - 强大的代理客户端核心
- [reF1nd/sing-box](https://github.com/reF1nd/sing-box) - 关键的 Android 适配分支，本项目所有功能的基础
- [KernelSU](https://github.com/KernelSU/KernelSU) - Android root 解决方案
