# Moegi Theme for Neovim

This repo ports the classic [Moegi VSCode theme](https://github.com/moegi-design/vscode-theme) to Neovim. It keeps the same nine variants, cold-green + warm-red accents, and palette structure while translating highlights, terminal colors, and statuslines for Neovim’s runtime.

## Highlights
- Transparent-friendly setup with helpers that blend VSCode-style alpha colors into solid hex values that Neovim accepts.
- Built-in support for `StatusLine`, `Lualine`, `Heirline`, and diagnostic highlight groups.
- Variants: Dark, Black, Space, Dawn, Iris, Light, Dark Vitesse, Light Vitesse, and Black Zen (see `colors/` for all entry points).

## Installation
1. Install via your favorite plugin manager or drop this repo into `~/.config/nvim/colors/`.
2. Configure and load the scheme in your `init.lua`:
   ```lua
   require('moegi').setup({ transparent = false })
   require('moegi').load('moegi-dark')
   ```
3. Swap variants at runtime with `require('moegi').load('moegi-space')`, `require('moegi').load('moegi-light')`, etc.

## Screenshots
| Variant | Preview |
| --- | --- |
| Moegi Dark | ![Moegi Dark](./images/moegi-dark.png) |
| Moegi Black | ![Moegi Black](./images/moegi-black.png) |
| Moegi Space | ![Moegi Space](./images/moegi-space.png) |
| Moegi Dark Vitesse | ![Moegi Dark Vitesse](./images/moegi-dark-vitesse.png) |
| Moegi Black Zen | ![Moegi Black Zen](./images/moegi-black-zen.png) |

## Contribution
If you spot inconsistencies with the upstream VSCode theme or have ideas for improvements, open a PR and we’ll get the Neovim port synced up.
