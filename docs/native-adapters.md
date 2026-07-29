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

The Catppuccin registry is generated from the pinned upstream module inventory.
It registers the simple and profile-based target families (including Firefox,
VS Code, GTK icons, cursors, and NixOS assets) with official provenance. The
support matrix is the authoritative per-target list; a target is only applied
when it is explicitly enrolled under `themeBroker.targets.<id>`.

`community` artifacts are not trusted by default. A local adapter is
explicitly registered in `themeBroker.registry.adapters`; it is never fetched
from a remote registry or downloaded during activation.
