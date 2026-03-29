# Pleiades

Minimal Electron app skeleton for local macOS development.

## Quick start

```bash
npm install
npm run dev
```

## Project structure

- `src/main/main.js`: Electron main process and window bootstrapping.
- `src/main/preload.js`: Secure bridge for exposing limited runtime data.
- `src/renderer/index.html`: Renderer entry point.
- `src/renderer/renderer.js`: Renderer-side UI wiring.
- `src/renderer/styles.css`: Starter styling.

## Packaging

```bash
npm run dist
```
