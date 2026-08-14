# canon-adapter

Lumina camera adapter for a **Canon DSLR** on a single-board computer.

The orchestrator (`lumina`) does not talk to Canon or gphoto2. It talks to this adapter over HTTP. Point Star Watcher at this host and choose the **Canon DSLR** adapter.

```
Canon DSLR ──USB──► canon-adapter (gphoto2 → ffmpeg → MediaMTX)
                         │ HTTP :3001  +  WHEP :8889
                         ▼
              Lumina / Star Watcher
```

## Protocol (`lumina.camera.v1`)

| Method | Path | Notes |
|--------|------|--------|
| GET | `/adapter` | Manifest: id `canon`, stream path, capabilities |
| GET | `/status` | Connected body, lens if known, `adapter: "canon"` |
| GET/POST | `/config/:key` | Exposure keys (`iso`, `shutterspeed`, `whitebalance`, …) |
| POST | `/capture` | Still frame |
| GET | `/events` | SSE activity log |
| POST | `/whep/:path` | WebRTC SDP proxy to MediaMTX |
| * | `/timelapse/*` | Sessions |
| POST | `/stream/start` `/stream/stop` | LiveView pipeline |

## Pi

```bash
# first time
make setup-pi

# cross-build armv7 + push
make deploy
```

Stack on the board: `/opt/canon-adapter` — services `mediamtx` + `canon-adapter` (host network).

Copy `.env.example` → `.env` and set `SBC_IP`.

## Local

```bash
pnpm install
pnpm dev          # :3001, needs gphoto2 + a body on USB
```
