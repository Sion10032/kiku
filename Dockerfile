# 后端依赖：只装生产依赖（bundle 里依赖全部 external，运行时靠 node_modules）
FROM oven/bun:alpine AS backend-deps
WORKDIR /app
COPY kiku-backend/package.json kiku-backend/bun.lock ./
RUN bun install --omit=dev --omit=peer --omit=optional --frozen-lockfile

# 后端打包：src/index.ts → dist/index.js + dist/migrations/{main,blob}
FROM oven/bun:alpine AS backend-build
WORKDIR /app
COPY kiku-backend/package.json kiku-backend/bun.lock ./
RUN bun install --frozen-lockfile
COPY kiku-backend/tsconfig.json kiku-backend/build.ts ./
COPY kiku-backend/src ./src
# 版本显示用的短 hash：不跑 git 解析，只认这里传入的值（build.ts 的 define 注入）
# 不传则服务端显示 dev-unknown
ARG APP_VERSION_BACKEND=
ENV APP_VERSION_BACKEND=$APP_VERSION_BACKEND
ARG GIT_COMMIT_BACKEND=
ENV GIT_COMMIT_BACKEND=$GIT_COMMIT_BACKEND
RUN bun run build

# 前端产物：API 走同源 /api；构建期变量只有版本显示的 APP_VERSION_FRONTEND / GIT_COMMIT_FRONTEND
FROM oven/bun:alpine AS frontend-build
WORKDIR /app
COPY kiku-frontend/package.json kiku-frontend/bun.lock ./
COPY kiku-frontend/patches ./patches
RUN bun install --frozen-lockfile
COPY kiku-frontend/tsconfig.json kiku-frontend/vite.config.ts kiku-frontend/index.html ./
COPY kiku-frontend/public ./public
COPY kiku-frontend/src ./src
# 版本显示用的版本号与短 hash：都不跑 git 解析，只认这里传入的值
# 不传则前端显示 dev-unknown（见 vite.config.ts 的 APP_VERSION / APP_COMMIT）
ARG APP_VERSION_FRONTEND=
ENV APP_VERSION_FRONTEND=$APP_VERSION_FRONTEND
ARG GIT_COMMIT_FRONTEND=
ENV GIT_COMMIT_FRONTEND=$GIT_COMMIT_FRONTEND
RUN bun run build

FROM oven/bun:alpine
# ffmpeg：响度分析 spawn 它（config.ffmpegPath 默认 'ffmpeg'）
# su-exec：入口脚本降权用（镜像里的 setpriv 是 busybox 版，不支持 --reuid）
RUN apk add --no-cache ffmpeg su-exec

WORKDIR /app
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
COPY --from=backend-deps /app/node_modules ./node_modules
# dist 内容直接落 /app：index.js 与 migrations/ 同级，resolveMigrationsFolder 按模块目录定位
COPY --from=backend-build /app/dist ./
# 前端产物 → /app/public（后端静态目录是 cwd 相对的 ./public）
COPY --from=frontend-build /app/dist ./public

# 配置与 sqlite 都在 /app/data（挂卷）；config.json 首启自动生成
ENV CONFIG_PATH=/app/data/config.json
ENV HOST=0.0.0.0
ENV PORT=8888
# 应用运行用户（linuxserver.io 同名的约定变量）；入口脚本以 root 确保数据目录可写后用 su-exec 降到这里
ENV PUID=1000
ENV PGID=1000

EXPOSE 8888/tcp

# /api/health 在私有模式白名单内，无需 token
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD bun -e "const r = await fetch('http://127.0.0.1:' + (process.env.PORT || 8888) + '/api/health'); process.exit(r.ok ? 0 : 1)"

# 入口脚本内部降权到 uid 1000：应用进程非 root，宿主机的 ./data 也不会变 root 属主
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "bun", "index.js" ]
