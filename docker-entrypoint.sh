#!/bin/sh
# 容器入口：确保数据目录可写，然后降权到应用用户运行。
#
# bind 挂载的宿主机目录若不存在，Docker 会以 root 创建它，容器内的应用用户
# （uid 1000）随后写不了 config.json / sqlite，表现为启动即退出：
#   EACCES: permission denied, open '/app/data/config.json'
# 这里在启动时补一次 mkdir，并在真的写不了时才纠正属主。
#
# 降权用 su-exec：镜像自带的 setpriv 是 busybox 版，不支持 --reuid/--regid。
set -e

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"
DATA_DIR="$(dirname "${CONFIG_PATH:-/app/data/config.json}")"

if [ "$(id -u)" = "0" ]; then
  mkdir -p "$DATA_DIR"

  # 只在应用用户确实写不了时才动属主：宿主机上属主/属组正常的目录保持不变
  if ! su-exec "$PUID:$PGID" /bin/sh -c 'test -w "$1"' _ "$DATA_DIR"; then
    chown "$PUID:$PGID" "$DATA_DIR" 2>/dev/null || true
    # 只改数据目录的一级子目录（sqlite/ 等），不递归：媒体库可能有几十 GB
    find "$DATA_DIR" -mindepth 1 -maxdepth 1 -exec chown "$PUID:$PGID" {} \; 2>/dev/null || true
  fi

  exec su-exec "$PUID:$PGID" "$@"
fi

# 已经是非 root（如 docker run --user、rootless 运行时）：原样执行
exec "$@"
