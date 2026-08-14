# Built-in providers

## Catppuccin

`catppuccin/palette` supplies `latte`, `frappe`, `macchiato`, and `mocha` at
evaluation time. All fourteen upstream accents are available. Accent changes
semantic `ui.accent` and `ui.focus`; Base16 syntax slots remain stable.

## Gruvbox

The reviewed canonical snapshot supplies `dark-hard`, `dark-medium`,
`dark-soft`, `light-hard`, `light-medium`, and `light-soft`. Gruvbox has no
global accent axis; use a semantic role override when a different focus color
is needed:

```nix
themeBroker.selection.overrides.roles.ui.accent = "@bright_blue";
```

## Rosé Pine

The pinned `rose-pine/rose-pine-palette` snapshot supplies `main`, `moon`, and
`dawn`. The provider exposes the six semantic accents `love`, `gold`, `rose`,
`pine`, `foam`, and `iris`. Its Base16 projections are checked against the
pinned Tinted schemes; Dawn keeps the canonical palette colors for semantic
roles while recording Tinted's compatible Base16 values where they differ.

Provider IDs and variant IDs are data, not core assumptions. Third-party
providers can be added through the mergeable registry option.
