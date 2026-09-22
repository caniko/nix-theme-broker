# Built-in providers

## Blackbox

`blackbox` is a local, true-black, Gruvbox-inspired derivative: it keeps the
Gruvbox hard-contrast color roles but replaces the primary background with a
genuine `#000000`. It is not an official Gruvbox release. The authoritative
inventory lives in `providers/blackbox/palette.json`
(`theme-broker.blackbox-palette/v1`); `providers/blackbox/default.nix` derives
aliases, semantic roles, ANSI, and Base16 from it. Provenance records the
derivation from Gruvbox revision
`5d15b2765f59754d7ac263c88a0f6e3e58124951` in this repository.

Select it (single `dark` variant, no accent axis):

```nix
themeBroker = {
  enable = true;
  selection = {
    provider = "blackbox";
    variant = "dark";
    accent = null;
  };
};
```

Return to a previous provider by restoring its selection, e.g.
`provider = "gruvbox"; variant = "dark-hard";`.

Named palette (hex values are exact; do not sample them from the preview
image, which carries errata recorded in `palette.json` under
`previewErrata`):

| Group | Colors |
| --- | --- |
| Backgrounds | `background #000000`, `surface_0 #1a1a1a`, `surface_1 #262626`, `surface_2 #3a3a3a` |
| Foregrounds | `foreground #ebdbb2`, `muted #bdae93`, `subtle #928374`, `foreground_bright #fbf1c7` |
| Normal | `red #cc241d`, `orange #d65d0e`, `yellow #d79921`, `green #98971a`, `aqua #689d6a`, `blue #458588`, `purple #b16286` |
| Bright | `bright_red #fb4934`, `bright_orange #fe8019`, `bright_yellow #fabd2f`, `bright_green #b8bb26`, `bright_aqua #8ec07c`, `bright_blue #83a598`, `bright_purple #d3869b` |
| Extra | `magenta #d3869b`, `bright_magenta #eb6f92` (inventoried; projections do not consume them) |

Semantic roles: `background` → `background`; `backgroundAlt` → `surface_0`;
`surface` → `surface_1`; `surfaceAlt`/`overlay`/`border` → `surface_2`;
`foregroundMuted` → `muted`; `selectionBackground` → `surface_1`;
`selectionForeground` → `foreground_bright`; `focus`/`accent` →
`bright_orange`; `link` → `bright_blue`. Status roles: `error` → `bright_red`,
`warning` → `bright_orange`, `success` → `bright_green`, `info` → `bright_blue`,
`hint` → `bright_aqua`. Syntax: `comment` → `subtle`, everything else follows
the Gruvbox assignments with the bright accents above.

ANSI banks: normal `black` = `background`, `white` = `foreground`,
`red`/`green`/`yellow`/`blue` = the normal accents, `magenta` = `purple`,
`cyan` = `aqua`; bright `black` = `subtle` (deliberately not `surface_0`),
`white` = `foreground_bright`, `red`/`green`/`yellow`/`blue` = the bright
accents, `magenta` = `bright_purple`, `cyan` = `bright_aqua`.

Base16: `base00` = `background` (so `base00 == #000000`), `base01` =
`surface_0`, `base02` = `surface_1`, `base03` = `subtle`, `base04` = `muted`,
`base05` = `foreground`, `base06` = `base07` = `foreground_bright`
(repetition is intentional), `base08` = `bright_red`, `base09` =
`bright_orange`, `base0A` = `bright_yellow`, `base0B` = `bright_green`,
`base0C` = `bright_aqua`, `base0D` = `bright_blue`, `base0E` = `bright_purple`,
`base0F` = `orange`. `base24` is `null` (no Base24 projection).

Limitations:

- Blackbox has no upstream Tinted scheme, so it is excluded from the
  Tinted/golden checks and pinned instead in `tests/eval/blackbox.nix`.
- Base16-only renderers collapse the ANSI banks. The pinned `tinted-kitty`
  base16 template maps `color1-6` to the bright accents, `color8` to `base02`
  (`#262626`) instead of the normalized bright-black `#928374`,
  `color9-14` duplicate `color1-6`, and `selection_background` becomes
  `base03` (`#928374`) rather than `selectionBackground` (`#262626`). Forced
  Base16 pipelines therefore lose the normal/bright distinction; inspect the
  generated file when ANSI fidelity matters.
- Blackbox declares no native adapters. `backend = "auto"` never selects a
  Gruvbox (or any other provider's) native adapter for it, and an explicit
  `backend = "native"` fails under the existing unsupported policy.

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
