# Better Fonts Market

This repository hosts font files and a cloud manifest for the uTools font preview plugin.

## Plugin Source Config

- Source Name: `better-fonts-market`
- Manifest URL: `https://cdn.jsdelivr.net/gh/leekitleung/better-fonts-market@main/manifest.json`

## Daily Workflow (Local)

1. Add font files (`.ttf/.otf/.ttc/.woff/.woff2`) anywhere in this repo.
2. Generate manifest:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\generate-manifest.ps1 -FontDir .
   ```

3. Commit and push.

## Optional Auto Update

GitHub Actions workflow `.github/workflows/manifest-auto.yml` auto-regenerates `manifest.json` when fonts are pushed.
