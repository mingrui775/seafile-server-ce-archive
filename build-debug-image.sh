#!/usr/bin/env bash
set -euo pipefail

# 与 ValidatePattern 对应的版本号正则
VERSION_RE='^[0-9]+\.[0-9]+(\.[0-9]+)?$'

usage() {
    echo "用法: $0 <镜像名> [版本号]"
    echo "示例: $0 test 0.2"
    echo "      $0 test        # 版本号默认 latest"
}

IMAGE_NAME="${1:-}"
VERSION="${2:-latest}"

# 对应 Mandatory=$true：镜像名必填
if [[ -z "$IMAGE_NAME" ]]; then
    usage
    exit 1
fi

# 对应 ValidatePattern：校验 0.2 / 1.2.3 这类格式
if [[ ! "$VERSION" =~ $VERSION_RE ]]; then
    echo "错误: 版本号 '$VERSION' 格式不合法，应为 0.2 / 1.2.3 之类的格式" >&2
    exit 1
fi

docker build -t "${IMAGE_NAME}:${VERSION}" -f ci/Dockerfile .
