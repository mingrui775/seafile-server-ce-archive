# Seafile Core 编译脚手架

> seafile-server（seafile-core）一站式源码编译脚手架 · 基于 **seafile-server-13.0** · 默认 **社区版（CE）**

## 前言

> 实际上本项目的核心目标是将seahub(Django)项目剥离，并解决seafile官方对docker-ubuntu基础镜像依赖，而导致各组件占用储存大于1Gib

## 📖 简介

本仓库提供 Seafile 服务端（seafile-server）的源码编译脚手架，目标版本为 **seafile-server-13.0**。
通过封装好的脚本，可以自动完成 **依赖安装 → 源码拉取 → 逐组件编译 → 组装打包** 的完整流程，并支持两种编译模式：

| 模式 | 说明 | 适用场景 |
| --- | --- | --- |
| 二进制编译 | 在宿主机直接编译 | 宿主机环境可控、追求编译速度 |
| Docker 编译 | 在容器内隔离编译，产物挂载回宿主机 | 环境不一致、不可改动宿主机、需要可复现构建 |

最终产出与官方发布包结构一致的 `seafile-core-13.0.x-ce` 目录及 `.tar.gz` 压缩包，可直接用于部署或二次开发调试。

> ⚠️ **关于 Pro 版本**：本脚手架默认且仅编译 **社区版（Community Edition, CE）**。
> 专业版（Pro）为商业软件，官方对专业版（Pro）有部分限制、需购买授权，因此 **本脚手架不包含、也无法编译 Pro**。
> 如需 Pro，请前往 Seafile 官网购买授权并下载官方预编译包。

## ✨ 特性

- 🚀 **一键编译**：封装依赖安装、源码拉取、编译、打包全流程
- 🐳 **双模式构建**：二进制编译 / Docker 隔离编译随意切换
- 📌 **版本锁定**：默认锁定 13.0 分支与配套依赖版本，结果可复现
- 📦 **产物标准化**：输出目录结构与官方 `seafile-server` 发布包一致
- 💻 **多架构**：支持 x86_64 与 arm64

## 🧩 组件构成

seafile-core 由以下开源组件组成，脚手架按依赖顺序依次编译：

| 组件 | 源码仓库 | 说明 |
| --- | --- | --- |
| libsearpc | `github.com/haiwen/libsearpc` | 简单 C 语言 RPC 框架，seafile 核心的前置依赖 |
| seafile-server | `github.com/haiwen/seafile-server` | 核心服务端：`seaf-server`、`seaf-daemon`、`seaf-fsck` 等二进制 |
| seahub | `github.com/haiwen/seahub` | Web 服务端（Django + 前端静态资源） |
| scripts / seafdav 等 | 随主仓库 / 打包阶段组装 | 启停脚本、升级脚本、WebDAV 扩展等 |

> 各组件遵循其上游仓库声明的开源许可证，详见各源码目录下的 `LICENSE` 文件。

## 📁 目录结构

```text
seafile-core-x/
├── build.sh                  # 二进制编译入口脚本
├── build-docker.sh           # Docker 编译入口脚本
├── config.sh                 # 版本号、分支、路径、镜像等可配置项
├── scripts/
│   ├── install-deps.sh       # 系统依赖安装
│   ├── fetch-source.sh       # 源码拉取 / 更新
│   ├── build-libsearpc.sh    # 编译 libsearpc
│   ├── build-seafile.sh      # 编译 seafile core
│   ├── build-seahub.sh       # 准备 seahub（Python 依赖 + 前端资源）
│   └── package.sh            # 组装 seafile-server 目录并打包
├── docker/
│   └── Dockerfile            # 编译环境镜像（默认基于 ubuntu:22.04）
├── src/                      # 源码缓存目录（脚本自动创建）
└── output/                   # 编译产物目录（脚本自动创建）
```

## 🖥 环境要求

**二进制编译（宿主机）：**

- Ubuntu 20.04 / 22.04 / 24.04 LTS 或 Debian 11 / 12（x86_64、arm64）
- `root` 或 `sudo` 权限（用于安装依赖）
- 内存 ≥ 4 GB（建议 8 GB，seahub 前端构建较吃内存）
- 磁盘剩余空间 ≥ 10 GB
- 可访问 GitHub、pip、npm（国内环境建议开启 `USE_MIRROR=1`）
**Docker 编译：**
- Docker ≥ 20.10
- 其余依赖在容器内预置，宿主机无需安装

## 🚀 快速开始

### 方式一：二进制编译

```bash
git clone <本仓库地址> seafile-core
cd seafile-core
# 一键编译
./build.sh
```

脚本将依次执行：

1. 安装系统依赖（`build-essential`、`cmake`、`libjansson-dev`、`libsqlite3-dev`、`libcurl4-openssl-dev`、`valac` 等）；
2. 从 GitHub 拉取 13.0 分支源码（libsearpc / seafile / seahub）至 `src/`；
3. 编译并安装 `libsearpc`；
4. CMake 编译 `seafile` server，得到 `seaf-server` 等二进制；
5. 准备 `seahub`：安装 Python 依赖、构建/获取前端静态资源；
6. 组装 `seafile-server-13.0.x-ce` 目录并打包为 `tar.gz`。

**常用参数：**

```bash
# 使用国内镜像加速
USE_MIRROR=1 ./build.sh
# 指定并行编译任务数
BUILD_JOBS=8 ./build.sh
# 编译后保留 src/ 源码，便于调试
KEEP_SOURCE=1 ./build.sh
```

### 方式二：Docker 编译

适用于宿主机环境不可控、或希望构建过程完全可复现的场景。

```bash
./build-docker.sh
```

工作原理：

1. 使用 `docker/Dockerfile` 构建编译环境镜像（已预置全部依赖）；
2. 启动一次性容器，将宿主机 `output/` 挂载进容器；
3. 容器内执行与二进制模式相同的编译脚本；
4. 编译结束后产物落回宿主机 `output/`，容器自动销毁。
也可以手动分步执行：

```bash
# 构建编译镜像
docker build -t seafile-build:13.0 -f docker/Dockerfile .
# 运行编译并挂载输出目录
docker run --rm \
  -v "$(pwd)/output:/output" \
  -e BUILD_JOBS=8 \
  seafile-build:13.0
```

## ⚙️ 可配置项

所有变量可在 `config.sh` 中修改，或以环境变量方式覆盖：

| 变量 | 默认值 | 说明 |
| --- | --- | --- |
| `SEAFILE_SERVER_VERSION` | `13.0` | 产物版本号 |
| `SEAFILE_BRANCH` | `v13.0-latest` | seafile / seahub 源码分支或 Tag |
| `LIBSEARPC_BRANCH` | `v3.2-latest` | libsearpc 分支或 Tag |
| `BUILD_JOBS` | `nproc` | 并行编译任务数 |
| `OUTPUT_DIR` | `./output` | 产物输出目录 |
| `KEEP_SOURCE` | `0` | 编译完成后是否保留 `src/` 源码（`1` 保留） |
| `USE_MIRROR` | `0` | 使用国内镜像加速（`1` 开启） |
| `BUILD_DOCKER_IMAGE` | `seafile-build:13.0` | Docker 编译镜像名称 |

> 具体分支 / Tag 名称以 `config.sh` 中实际配置为准，如需切换版本请同步修改对应变量。

## 📦 产物说明

```text
output/seafile-server-13.0.x-ce/
├── seafile/          # 核心二进制与动态库（seaf-server、seaf-daemon、seaf-fsck 等）
├── seahub/           # Web 服务（Django 代码 + 第三方 Python 依赖 + 前端静态资源）
├── runtime/          # 运行时环境
├── seafile.sh        # seafile 服务启停脚本
├── seahub.sh         # seahub 服务启停脚本
├── setup-seafile.sh  # 交互式初始化脚本
├── upgrade/          # 升级脚本
└── （同级生成 seafile-server-13.0.x-ce.tar.gz 压缩包）
```

**验证产物：**

```bash
ls output/
tar tzf output/seafile-server-*.tar.gz | head
md5sum output/*.tar.gz
```

**快速验证可运行性（可选）：**

```bash
mkdir -p /opt/seafile && tar -xzf output/seafile-server-*.tar.gz -C /opt/seafile
cd /opt/seafile/seafile-server-13.0.x
./setup-seafile.sh
```

> 📌 自 Seafile 12.0 起，官方 **推荐使用 Docker Compose 部署**。
> 二进制产物主要用于源码定制、调试、内网特殊环境等场景，常规部署建议优先使用官方镜像。

## ❓ 常见问题（FAQ）

**Q1：为什么没有 Pro 版本？**
Pro 为闭源商业软件，需购买授权，官方仅提供预编译包，不提供源码。本脚手架仅面向社区版（CE）。

**Q2：编译产物与官方发布包有何区别？**
目录结构一致，可直接部署；官方包可能额外内置便携化运行时（如 Python）等，差异以官方发布说明为准。

**Q3：支持 arm64 吗？**
支持。x86_64 与 arm64 均可编译，Docker 模式下注意使用对应架构的基础镜像（buildx 多架构构建亦可）。

## 📄 许可证与声明

- 本脚手架脚本部分基于 **MIT License** 发布；
- `seafile`、`libsearpc`、`seahub` 等组件遵循其上游仓库声明的开源许可证，详见各源码目录 `LICENSE`；
- 本项目为社区编译辅助工具，与 Seafile 官方无隶属关系，相关商标与产品版权归 Seafile 团队所有。

## 🙌 贡献

欢迎提交 Issue 与 Pull Request：

1. Fork 本仓库并创建特性分支；
2. 保持脚本风格一致，新增功能请补充注释与文档；
3. 提交前在干净环境中完整跑通一次编译。

``` text

两点补充建议：
1. **表格与脚本名对齐**：如果你的入口脚本实际叫 `binary-build.sh` / `docker-build.sh`，记得全文替换；`config.sh` 中变量名同理。
2. **分支/Tag 核实**：`v13.0-latest`、`v3.2-latest` 为示意写法，建议按 `haiwen/seafile`、`haiwen/libsearpc` 仓库实际存在的 Tag 确认后固化到 `config.sh`，避免 README 与实际不符。
```
