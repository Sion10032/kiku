# AGENTS.md

## 项目

kiku：自托管 DLsite 音声作品媒体服务器。

| 目录 | 说明 |
|---|---|
| `kiku-backend/` | Bun + Fastify + Drizzle ORM + Zod + Biome，测试用 `bun test` |
| `kiku-frontend/` | React 19 + @m3e/react + Vite + TanStack Router/Query + Tailwind 4 + Zustand，测试用 Vitest |

## 子项目约定

各子项目的开发约定（命令、分层、测试、风格、i18n）以各自的 AGENTS.md 为准，本文件不重复：

- 后端 → [`kiku-backend/AGENTS.md`](kiku-backend/AGENTS.md)
- 前端 → [`kiku-frontend/AGENTS.md`](kiku-frontend/AGENTS.md)

## git

`kiku-backend/` 与 `kiku-frontend/` 均为独立 git 仓库（子模块），各有自己的 remote；提交、拉取、推送需分别在各子目录内进行，父仓库不直接管理其内部变更。子模块内改完代码，在子仓库提交并推送，父仓库不动。

- 提交信息使用英文，遵循 Conventional Commits（`feat:` / `fix:` / `chore:` 等）。
- 提交前查看 `git status` 与 `git diff --cached`，仅基于已暂存内容生成。

## 开发环境

根仓库提供 Nix flake + direnv（`flake.nix`、`.envrc`），进入目录自动加载。

`devShells` 覆盖 `x86_64-linux`、`aarch64-linux`、`aarch64-darwin`。不含 `x86_64-darwin`：nixpkgs 26.11 起已移除该平台，硬列进 `systems` 会让所有平台的 `nix flake show` / `flake check` 一起失败。

## Docker

镜像在**父仓库根**构建（`Dockerfile` 多阶段：后端 `bun run build` + 前端 `vite build`），构建上下文是父仓库，两个子模块必须先初始化：

```bash
git submodule update --init
docker compose up -d --build
```

- 单容器自包含：后端产物（`index.js` + `migrations/`）落在 `/app`，前端产物落在 `/app/public`（后端静态目录）。
- 数据卷 `./data:/app/data`：`config.json` 与 `sqlite/`（首启自动生成配置与随机 secret）。
  宿主机目录不存在时 Docker 会以 root 创建它，入口脚本 `docker-entrypoint.sh` 会 `mkdir`，
  并在 `PUID`（默认 1000）确实写不了时把它及一级子目录的属主改成 `PUID:PGID` 再降权运行，
  所以不需要预先 `mkdir`、也不会出现 root 属主的数据文件。从开发目录迁库：`cp -a kiku-backend/data/. ./data/`。
- 媒体库：`MEDIA_DIR` 指定宿主机目录（默认 `./data/library`），容器内固定只读挂到 `/media`；首启后在设置页把根目录配成 `/media/...`，后端不写媒体目录，所以只读是安全的。
- 镜像内 `ffmpeg` 由 `apk add` 提供（响度分析 spawn 它；`config.ffmpegPath` 默认 `ffmpeg`）。
- 端口 8888，`HOST` / `PORT` 环境变量可覆盖；`PUID` / `PGID`（默认 1000）控制数据目录属主；`HEALTHCHECK` 打 `/api/health`（私有模式白名单路径，无需 token，`/api/version` 同样在列）。
- 版本显示：设置页底部显示前端 + 服务端版本，格式 `<版本>-<短 hash>`，前端 / 服务端各一行
  各自独立，**前后端版本不需要一致**。两端都**不做 git 解析、也不读 package.json**，四个值
  全部构建期注入（前端 vite `define`、后端 `build.ts` 的 `define`），通过 build arg 传：
  `APP_VERSION_FRONTEND` / `APP_VERSION_BACKEND` 与 `GIT_COMMIT_FRONTEND` /
  `GIT_COMMIT_BACKEND`。不传就显示 `dev-unknown`（版本与 commit 各自独立兜底为 `dev` /
  `unknown`）。未打包的 `bun run dev` / `bun test` 同样是 `dev-unknown`。手动构建示例
  （版本取子模块当前 commit 的 tag）：

```bash
APP_VERSION_FRONTEND=$(git -C kiku-frontend tag --points-at HEAD | head -1) \
APP_VERSION_BACKEND=$(git -C kiku-backend tag --points-at HEAD | head -1) \
GIT_COMMIT_FRONTEND=$(git -C kiku-frontend rev-parse --short HEAD) \
GIT_COMMIT_BACKEND=$(git -C kiku-backend rev-parse --short HEAD) \
docker compose up -d --build
```

- CI 发布（`.github/workflows/release.yml`）：父仓库 push `v*` tag 触发。父 tag 只决定镜像
  版本（`ghcr.io/sion10032/kiku:<tag>` + `latest`）与触发发布；前端 / 后端版本由 CI 自动取
  各自子模块当前引用 commit 上的 tag（版本互不相干），发布时无需人工填任何版本号。门禁
  要求这些 commit 在子仓库有 tag（缺则失败，在子仓库补 tag 后 re-run 即可，父 tag 不用删）。
  Release notes 列出两个子模块 tag 从上一次发布到本次的变化（附子仓库 compare 链接），
  不汇总父仓库 commit（都是 submodule 更新，无信息量）。

## 参考

- `m3e-react-guide.md`：M3E 组件库使用指南（前端相关）
- `plans/`、`docs/`、`todo.md`：计划与草稿，非权威约定
