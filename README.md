# canon-adapter

Reference **Lumina camera adapter** for a Canon DSLR on a single-board computer.

This process implements [`lumina.camera.v1`](https://github.com/lumina-stream/lumina/blob/main/packages/shared/PROTOCOL.md). Star Watcher does not know about Canon or gphoto2. It probes `GET /adapter` and then uses the same routes any other adapter would.

```
Canon DSLR ──USB──► canon-adapter (gphoto2 → ffmpeg → MediaMTX)
                         │ HTTP :3001  +  WHEP :8889
                         ▼
              Lumina / Star Watcher  (Remote adapter → Probe)
```

To drive a different body, do not fork this into the app. Write another adapter that answers the same handshake.

## Protocol

See the spec in lumina: `packages/shared/PROTOCOL.md`.

This adapter:

| Field | Value |
|-------|--------|
| `id` | `canon` |
| `protocol` | `lumina.camera.v1` |
| `streamPath` | `canon` (override with `STREAM_PATH`) |
| capabilities | live view, capture, timelapse, exposure |

## Pi

```bash
make setup-pi
make deploy
```

Stack: `/opt/canon-adapter` — `mediamtx` + this service (host network).

Copy `.env.example` → `.env` and set `SBC_IP`.

## Local

```bash
pnpm install
pnpm dev          # :3001, needs gphoto2 + a body on USB
```
