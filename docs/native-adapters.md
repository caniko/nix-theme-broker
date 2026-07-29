# Native adapters

An adapter is a pinned, provenance-bearing application implementation. The
resolver filters by provider, canonical target ID, platform, variant, trust
tier, and fidelity before applying a stable priority order.

Built-ins currently include:

| Adapter | Tier | Targets |
| --- | --- | --- |
| `catppuccin-alacritty` | official | Catppuccin Alacritty module |
| `gruvbox-vim` | canonical | Vim |
| `gruvbox-neovim` | maintained | Neovim |
| `gruvbox-vscode` | maintained | VS Code color and Material icon extensions |

The VS Code adapters own both Marketplace extension provenance and the flat
`workbench.colorTheme`/`workbench.iconTheme` settings. Gruvbox uses the pinned
`jdinhlife.gruvbox` 1.29.1 extension and the fixed 4.6.0
`navernoedenis.gruvbox-material-icons` VSIX; its canonical `dark-hard` variant
maps to the extension label `Gruvbox Dark Hard`. Catppuccin uses its matching
color/icon extensions and preserves the existing disabled generated-source
workaround. Selecting a native VS Code adapter disables the Stylix VS Code
target so only the explicitly enrolled broker backend writes these settings.

The Catppuccin registry is generated from the pinned upstream module inventory.
It registers the simple and profile-based target families (including Firefox,
VS Code, GTK icons, cursors, and NixOS assets) with official provenance. The
support matrix is the authoritative per-target list; a target is only applied
when it is explicitly enrolled under `themeBroker.targets.<id>`.

`community` artifacts are not trusted by default. A local adapter is
explicitly registered in `themeBroker.registry.adapters`; it is never fetched
from a remote registry or downloaded during activation.
