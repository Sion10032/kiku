<p align="center">
  <img src="assets/logo.svg" width="128" alt="kiku logo" />
</p>

<h1 align="center">kiku</h1>

<p align="center">
  <a href="README.md">English</a> · 简体中文
</p>

<p align="center">
  用户手册：<a href="docs/manual/zh-CN/README.md">简体中文</a> · <a href="docs/manual/en/README.md">English</a>
</p>

<p align="center">
  自托管的 DLsite 音声作品媒体服务器：流媒体播放 + 媒体库管理，
  <a href="https://github.com/kikoeru-project/kikoeru-express">kikoeru</a>
  （kikoeru-express + kikoeru-quasar）的重写版。
</p>

| 子项目                          | 说明                                                 |
| ------------------------------- | ---------------------------------------------------- |
| [kiku-backend](kiku-backend/)   | Bun + Fastify + Drizzle ORM（bun:sqlite）+ Zod       |
| [kiku-frontend](kiku-frontend/) | React 19 + @m3e/react + Vite + TanStack Router/Query |

## 功能

**媒体库**

- [x] 多根目录媒体库扫描，实时显示扫描日志与进度
- [x] 增量更新与全量重扫两种扫描模式
- [x] DLsite 元数据抓取：标题、封面、社团、声优、标签、系列、评分、发售日、年龄分级
- [x] 压缩包作品：`.tar` 与仅存储（stored）的 `.zip`，免解压随机访问直接播放
- [x] 人工编号作品：自定义编号前缀的本地作品（如 `UW123456`），封面从作品文件夹自动导入
- [x] 元数据覆盖编辑、刷新元数据、同步音轨
- [x] 标题净化：正则规则批量替换
- [x] 作品软删除（单个与批量）

**播放**

- [x] 流媒体在线播放
- [x] 断点续播：按作品与音轨记住播放位置，点击继续
- [x] WavPack（.wv）格式播放
- [x] 播放队列，播放模式：顺序 / 列表循环 / 单曲循环 / 随机
- [x] 快进快退（时长可配置）
- [x] 歌词显示与浮动歌词
- [x] 睡眠定时器
- [x] 系统级媒体控制（媒体键 / 通知栏）
- [x] 响度分析与播放音量均衡（目标响度与最大增益可配置）

**数据与个人化**

- [x] 已读 / 未读标记
- [x] 星级评分与评语
- [x] 播放历史
- [x] 收藏：作品 / 系列 / 声优 / 社团
- [x] 检索：关键字与字段过滤；按社团 / 标签 / 声优 / 系列浏览
- [x] 排序：发售日 / 编号正逆序 / 随机；分页或无限滚动
- [x] 设置备份与恢复

**界面与账号**

- [x] Material 3 Expressive 界面
- [x] 主题：明 / 暗 / 跟随系统，动态取色
- [x] 界面缩放与内容宽度调节
- [x] 文件应用内预览：文本（编码检测、字号 / 换行）与图片（缩放 / 旋转 / 画廊）
- [x] 界面语言：简体中文 / English
- [x] R18 封面模糊策略（始终 / 悬停 / 从不）
- [x] 私有模式（登录鉴权）
- [x] 首次启动 setup 向导，检测并迁移 kikoeru 旧数据

## 与 kikoeru 的功能对比

以 kikoeru v0.6.2（kikoeru-express + kikoeru-quasar）为基准。

| 功能                           | kikoeru                           | kiku                             |
| ------------------------------ | --------------------------------- | -------------------------------- |
| 后端技术栈                     | Node.js + Express + Knex + SQLite | Bun + Fastify + Drizzle + SQLite |
| 前端技术栈                     | Vue 2 + Quasar v1                 | React 19 + @m3e/react            |
| 扫描进度实时推送               | socket.io                         | SSE                              |
| DLsite 元数据抓取              | ✓                                 | ✓                                |
| 多根文件夹 / Web 端改配置      | ✓                                 | ✓                                |
| 星级评分 / 评语  | ✓                                 | ✓                                |
| 进度标记（想听 / 在听 / 听过 / 重听 / 搁置）  | ✓                                 | ✗                                |
| 歌词显示                       | ✓                                 | ✓                                |
| 收藏                           | ✗（收藏页实为评价 / 进度管理）    | ✓（作品 / 系列 / 声优 / 社团）   |
| 关键字与标签检索               | ✓                                 | ✓                                |
| 已读 / 未读标记                | ✗                                 | ✓                                |
| JWT 认证可开关                 | ✓                                 | ✓                                |
| PWA / 可安装                   | ✓（SPA / PWA 双构建）             | ✓（manifest）                    |
| 年龄分级标记                   | ✓（全年龄标记）                   | ✓（R15 / R18 / 全年龄）          |
| 暗色模式                       | ✗                                 | ✓                                |
| 界面语言                       | 中文                              | 中文 + English                   |
| 响度分析 / 音量均衡            | ✗                                 | ✓                                |
| WavPack（.wv）播放             | ✗                                 | ✓                                |
| 压缩包作品（.tar / 仅存储 .zip） | ✗                                | ✓                                |
| 播放历史                       | ✗                                 | ✓                                |
| 设置备份 / 恢复                | ✗                                 | ✓                                |
| PDF 支持                       | ✓                                 | ✗                                |
| 静态媒体 offload（Nginx 分流） | ✓                                 | ✗                                |

## 部署（Docker）

```yaml
services:
  kiku:
    image: ghcr.io/sion10032/kiku:latest
    restart: always
    ports:
      - "8888:8888"
    environment:
      HOST: 0.0.0.0
      PORT: 8888
      # 数据目录属主：设成宿主机运行用户的 uid/gid（也可写进同级 .env）
      PUID: ${PUID:-1000}
      PGID: ${PGID:-1000}
    volumes:
      # config.json + sqlite（容器内以 uid 1000 运行，宿主机目录需对 1000 可写）
      - ./data:/app/data
      # 媒体库：宿主机目录用 MEDIA_DIR 指定，容器内固定只读挂到 /media
      - ${MEDIA_DIR:-./data/library}:/media:ro

```

## 开发

推荐 Nix flake + direnv（进入目录自动加载），运行时需要 [Bun](https://bun.sh/)。

```bash
cd kiku-backend  && bun install && bun run dev   # API :8888
cd kiku-frontend && bun install && bun run dev   # Vite :5173，/api 代理到后端
```

命令与约定见两个子项目的 README 与 AGENTS.md。

## License

GPL-3.0-or-later，与原项目一致。

基于 [kikoeru-quasar](https://github.com/kikoeru-project/kikoeru-quasar) 与 [kikoeru-express](https://github.com/kikoeru-project/kikoeru-express) 重写。原项目版权：Copyright (C) Watanuki-Kimihiro 及贡献者（yodhcn、umonaca）；kikoeru-express 的后端代码源自 [kikoeru](https://github.com/nortonandrews/kikoeru)，一并致谢。
