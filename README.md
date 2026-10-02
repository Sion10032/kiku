<p align="center">
  <img src="https://raw.githubusercontent.com/Sion10032/kiku/main/assets/logo.svg" width="128" alt="kiku logo" />
</p>

<h1 align="center">kiku</h1>

<p align="center">
  English · <a href="README.zh-CN.md">简体中文</a>
</p>

<p align="center">
  User Manual: <a href="docs/manual/en/README.md">English</a> · <a href="docs/manual/zh-CN/README.md">简体中文</a>
</p>

<p align="center">
  A self-hosted media server for DLsite voice works: streaming playback + library management.
  A rewrite of <a href="https://github.com/kikoeru-project/kikoeru-express">kikoeru</a>
  (kikoeru-express + kikoeru-quasar).
</p>

| Subproject                     | Description                                           |
| ------------------------------ | ----------------------------------------------------- |
| [kiku-backend](kiku-backend/)  | Bun + Fastify + Drizzle ORM (bun:sqlite) + Zod        |
| [kiku-frontend](kiku-frontend/) | React 19 + @m3e/react + Vite + TanStack Router/Query |

## Features

**Library**

- [x] Multi-root library scanning with live scan logs and progress
- [x] Incremental update and full rescan modes
- [x] DLsite metadata scraping: title, cover, circle, voice actors, tags, series, rating, release date, age rating
- [x] Archive-based works: `.tar` and stored (uncompressed) `.zip` streamed in place with random access, no extraction
- [x] Manual works: local works with custom ID prefixes (e.g. `UW123456`), covers auto-imported from the work folder
- [x] Metadata override editing, metadata refresh, track sync
- [x] Bulk title sanitization with regex rules
- [x] Soft delete for works (single & batch)

**Playback**

- [x] Online streaming playback
- [x] Resume playback: listening position remembered per work & track, click to continue
- [x] WavPack (.wv) playback
- [x] Play queue with play modes: order / repeat all / repeat one / shuffle
- [x] Rewind / forward (configurable duration)
- [x] Lyrics display and floating lyrics
- [x] Sleep timer
- [x] System media controls (media keys / notification)
- [x] Loudness analysis and playback volume leveling (target loudness and max gain configurable)

**Data & personalization**

- [x] Read / unread marks
- [x] Star ratings and reviews
- [x] Listen history
- [x] Favourites: works / series / voice actors / circles
- [x] Search: keywords with field filters; browse by circle / tag / voice actor / series
- [x] Sorting: release date / ID ascending & descending / random; pagination or infinite scroll
- [x] Server-side settings backup & restore (multiple snapshots)

**UI & account**

- [x] Material 3 Expressive UI
- [x] Themes: light / dark / follow system, dynamic color
- [x] UI scale and content width adjustments
- [x] In-app file preview: text (encoding detection, font size / wrap) and images (zoom / rotate / gallery)
- [x] UI language: Simplified Chinese / English
- [x] R18 cover blur policy (always / hover / never)
- [x] Private mode (login required)
- [x] First-run setup wizard that detects and migrates legacy kikoeru data

## Feature comparison with kikoeru

Based on kikoeru v0.6.2 (kikoeru-express + kikoeru-quasar).

| Feature                        | kikoeru                           | kiku                             |
| ------------------------------ | --------------------------------- | -------------------------------- |
| Backend stack                  | Node.js + Express + Knex + SQLite | Bun + Fastify + Drizzle + SQLite |
| Frontend stack                 | Vue 2 + Quasar v1                 | React 19 + @m3e/react            |
| Real-time scan progress        | socket.io                         | SSE                              |
| DLsite metadata scraping       | ✓                                 | ✓                                |
| Multiple root folders / web config | ✓                             | ✓                                |
| Star ratings / reviews         | ✓                                 | ✓                                |
| Progress marking (marked / listening / listened / replay / postponed) | ✓ | ✗ |
| Lyrics display                 | ✓                                 | ✓                                |
| Favourites                     | ✗ (favourites page is actually reviews / progress management) | ✓ (works / series / voice actors / circles) |
| Keyword & tag search           | ✓                                 | ✓                                |
| Read / unread marks            | ✗                                 | ✓                                |
| Toggleable JWT auth            | ✓                                 | ✓                                |
| PWA / installable              | ✓ (SPA / PWA dual build)          | ✓ (manifest)                     |
| Age rating badge               | ✓ (all-age badge)                 | ✓ (R15 / R18 / all-age)          |
| Dark mode                      | ✗                                 | ✓                                |
| UI language                    | Chinese                           | Chinese + English                |
| Loudness analysis / volume leveling | ✗                            | ✓                                |
| WavPack (.wv) playback         | ✗                                 | ✓                                |
| Archive works (.tar / stored .zip) | ✗                             | ✓                                |
| Listen history                 | ✗                                 | ✓                                |
| Settings backup / restore      | ✗                                 | ✓                                |
| PDF support                    | ✓                                 | ✗                                |
| Static media offload (Nginx)   | ✓                                 | ✗                                |

## Deployment (Docker)

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
      # Data dir owner: set to the host user's uid/gid (or put it in a sibling .env)
      PUID: ${PUID:-1000}
      PGID: ${PGID:-1000}
    volumes:
      # config.json + sqlite (the container runs as uid 1000, so the host dir must be writable by 1000)
      - ./data:/app/data
      # Media library: point MEDIA_DIR at the host directory; mounted read-only at /media
      - ${MEDIA_DIR:-./data/library}:/media:ro

```

## Development

Nix flake + direnv recommended (loaded automatically when entering the directory); requires [Bun](https://bun.sh/).

```bash
cd kiku-backend  && bun install && bun run dev   # API :8888
cd kiku-frontend && bun install && bun run dev   # Vite :5173, /api proxied to the backend
```

See each subproject's README and AGENTS.md for commands and conventions.

## License

GPL-3.0-or-later, same as the original project.

Rewritten from [kikoeru-quasar](https://github.com/kikoeru-project/kikoeru-quasar) and [kikoeru-express](https://github.com/kikoeru-project/kikoeru-express). Original copyright: Copyright (C) Watanuki-Kimihiro and contributors (yodhcn, umonaca); kikoeru-express's backend code originates from [kikoeru](https://github.com/nortonandrews/kikoeru), with thanks.
