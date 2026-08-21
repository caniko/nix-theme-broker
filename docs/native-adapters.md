# Native adapters

An adapter is a pinned, provenance-bearing application implementation. The
resolver filters by provider, canonical target ID, platform, variant, trust
tier, and fidelity before applying a stable priority order.

Built-ins currently include:

| Adapter | Tier | Targets |
| --- | --- | --- |
| `catppuccin-alacritty` | official | Catppuccin Alacritty module |
| `catppuccin-cursors` | official | Catppuccin pointer cursors |
| `gruvbox-cursors` | maintained | Bibata cursor variants selected for Gruvbox |
| `gruvbox-vim` | canonical | Vim |
| `gruvbox-neovim` | maintained | Neovim |
| `gruvbox-vscode` | maintained | VS Code color and Material icon extensions |
| `gruvbox-chromium`, `gruvbox-brave` | canonical | Permissionless Gruvbox dark-hard browser theme |

The VS Code adapters own both Marketplace extension provenance and the flat
`workbench.colorTheme`/`workbench.iconTheme` settings. Gruvbox uses the pinned
`jdinhlife.gruvbox` 1.29.1 extension and the fixed 4.6.0
`navernoedenis.gruvbox-material-icons` VSIX; its canonical `dark-hard` variant
maps to the extension label `Gruvbox Dark Hard`. Catppuccin uses its matching
color/icon extensions and preserves the existing disabled generated-source
workaround. Selecting a native VS Code adapter disables the Stylix VS Code
target so only the explicitly enrolled broker backend writes these settings.

The Catppuccin registry is generated from the pinned upstream module inventory.
All 95 entries have an implemented renderer: simple targets use the recorded
upstream option path, while Firefox and the six VS Code-family targets use
profile renderers. The support matrix is the authoritative per-target list; a
target is only applied when it is explicitly enrolled under
`themeBroker.targets.<id>`.

The Gruvbox browser adapters share a locally built Manifest V3 CRX. Its
repository-owned signing key is an identity, not a credential: the extension
contains only explicit theme colors and has no permissions, scripts, images,
or remote update URL.

`community` artifacts are not trusted by default. A local simple adapter is
declared through the platform module's `themeBrokerAdapters` argument with an
`optionPath`; the exact active registry entry must match that declared renderer
before resolution. It is never fetched from a remote registry or downloaded
during activation. Automatic native selection also requires exact
accent/override fidelity and `autoSafe = true`.
