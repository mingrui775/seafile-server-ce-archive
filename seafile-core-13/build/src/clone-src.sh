#!/usr/bin/env bash
set -u

# 目标目录(src/ 已存在则跳过创建)
SRC_DIR="${SRC_DIR:-./src}"
mkdir -p "$SRC_DIR"
cd "$SRC_DIR"

# ===== 配置区:目录名 → "URL|额外参数" =====
# tag 值按 seafile-build.sh 头部 *_tag= 的定义照抄,别拍脑袋猜
# 浅克隆用 --depth=N --branch <tag>;不限深度的就留空参数

GH_PROXY="https://gh-proxy.com/"    # 关闭代理就设为空

declare -A REPOS=(
  [libevhtp]="https://github.com/haiwen/libevhtp.git|--branch 1.1.6 --depth=1"
  [libsearpc]="https://github.com/haiwen/libsearpc.git|--branch v3.3-latest --depth=1"
  [seafile-server]="https://github.com/haiwen/seafile-server.git|--branch v13.0.28-server --depth=100"
  [seafobj]="https://github.com/haiwen/seafobj.git|--branch v13.0.28-server --depth=1"
  [seafdav]="https://github.com/haiwen/seafdav.git|--branch v13.0.28-server --depth=1"
  [seafevents]="https://github.com/haiwen/seafevents.git|--branch v13.0.28-server --depth=1"
  [seahub]="https://github.com/haiwen/seahub.git|--branch v13.0.28-server --depth=100"
)

for dir in "${!REPOS[@]}"; do
  base_url="${REPOS[$dir]%%|*}"
  args="${REPOS[$dir]#*|}"
  url="${GH_PROXY}${base_url}"

  # 判断:目录存在 且 里面有 .git 才算"已 clone"
  # 只判 -d 会被网络中断留下的空目录骗过,补上 .git 检查更稳
  if [[ -d "$dir" && -d "$dir/.git" ]]; then
    echo "SKIP      $dir (already exists)"
  elif [[ -d "$dir" ]]; then
    echo "BROKEN    $dir (empty/incomplete dir, removing and re-cloning)"
    rm -rf "$dir"
    git clone $args "$url" "$dir" || echo "FAILED    $dir"
  else
    echo "CLONE     $dir"
    git clone $args "$url" "$dir" || echo "FAILED    $dir"
  fi
done

echo
echo "=== 仓库状态汇总 ==="
for dir in "${!REPOS[@]}"; do
  if [[ -d "$dir/.git" ]]; then
    head=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null || echo "unknown")
    printf "OK      %-18s @ %s\n" "$dir" "$head"
  else
    printf "MISSING %s\n" "$dir"
  fi
done
