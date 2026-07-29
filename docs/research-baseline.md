# Research baseline

The first implementation is pinned to the following upstream snapshots.  The
pins are recorded here so a provider or native adapter update produces a
reviewable input diff instead of silently changing evaluation behavior.

| Component | Revision | Date | Purpose |
| --- | --- | --- | --- |
| `catppuccin/nix` | `673f730d0fc8db3468c51575f1d3d777cc55e51f` | 2026-07-18 | native Catppuccin modules |
| `catppuccin/palette` | `07d02aa110ef9eb7e7427afca5c73ba9cf7f8ebd` | 2026-03-21 | evaluation-time palette data |
| `nix-community/stylix` | `66714e5ce44269ecc58c20d9196da8dbe1b27a31` | 2026-07-21 | generic target engine and Base16 bridge |
| `morhetz/gruvbox` | `5d15b2765f59754d7ac263c88a0f6e3e58124951` | 2025-02-11 | canonical Gruvbox palette source |
| `tinted-theming/schemes` | `9bd28ed313560db3c5b605c63bc4e309e78e3fc8` | 2026-07-27 | Base16 comparison source and conformance input |
| `ellisonleao/gruvbox.nvim` | `154eb5ff5b96d0641307113fa385eaf0d36d9796` | 2024-03-17 | maintained Neovim native adapter source |

The Catppuccin palette is read from the locked non-flake input's
`palette.json`; no derivation is imported.  Native adapter provenance is kept
separate from palette provenance so a maintained application port cannot be
mistaken for the canonical palette source.
