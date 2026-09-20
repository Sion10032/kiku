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

`kiku-backend/` 与 `kiku-frontend/` 均为独立 git 仓库（子模块），各有自己的 remote；提交、拉取、推送需分别在各子目录内进行，父仓库不直接管理其内部变更。子模块内改完代码，先在子仓库提交并推送，再回父仓库提交指针更新。

- 提交信息使用英文，遵循 Conventional Commits（`feat:` / `fix:` / `chore:` 等）。
- 提交前查看 `git status` 与 `git diff --cached`，仅基于已暂存内容生成。

## 开发环境

根仓库提供 Nix flake + direnv（`flake.nix`、`.envrc`），进入目录自动加载。

`devShells` 覆盖 `x86_64-linux`、`aarch64-linux`、`aarch64-darwin`。不含 `x86_64-darwin`：nixpkgs 26.11 起已移除该平台，硬列进 `systems` 会让所有平台的 `nix flake show` / `flake check` 一起失败。

## 参考

- `m3e-react-guide.md`：M3E 组件库使用指南（前端相关）
- `plans/`、`docs/`、`todo.md`：计划与草稿，非权威约定
