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
RUN bun run build

# 前端产物：API 走同源 /api，无构建期环境变量
FROM oven/bun:alpine AS frontend-build
WORKDIR /app
COPY kiku-frontend/package.json kiku-frontend/bun.lock ./
RUN bun install --frozen-lockfile
COPY kiku-frontend/tsconfig.json kiku-frontend/vite.config.ts kiku-frontend/index.html ./
COPY kiku-frontend/public ./public
COPY kiku-frontend/src ./src
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
