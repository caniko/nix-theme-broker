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

Select it (`dark` or `light`, no accent axis):

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

### Light variant

`light` keeps every role key and alias of `dark` on a near-white canvas. It
carries its own `named` inventory in `palette.json` (`variants.light.named`) and
a literal `border` alias:

| Group | Colors |
| --- | --- |
| Backgrounds | `background #ffffff`, `surface_0 #f7f7f5`, `surface_1 #f2f2f0`, `surface_2 #e8e8e5`; `border #d9d9d6` |
| Foregrounds | `foreground #1d2021`, `muted #5a5550`, `subtle #7c6f64`, `foreground_bright #000000` |
| Normal | Gruvbox-light's regular hues: `red #cc241d`, `orange #d65d0e`, `yellow #d79921`, `green #98971a`, `aqua #689d6a`, `blue #458588`, `purple #b16286` |
| Bright | Gruvbox-light's darker hues, which the status and syntax roles use: `bright_red #9d0006`, `bright_orange #af3a03`, `bright_yellow #b57614`, `bright_green #79740e`, `bright_aqua #427b58`, `bright_blue #076678`, `bright_purple #8f3f71` |
| Extra | `magenta #8f3f71`, `bright_magenta #b4637a` |

`foreground` and `muted` reach at least 6.0:1 against all four surface steps
(WCAG AA needs 4.5:1).

### Figure roles

Both Blackbox variants carry the optional `roles.figure` group (see
[Figure roles](#figure-roles)).

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

## Figure roles

`roles.figure` is an optional group for scientific figures and web charts. A
provider that omits it stays valid; one that declares it must declare every key.
Colour keys (hex or `@name`) are `background`, `surface`, `surface_alt`,
`border`, `ink`, `muted`, `link`, `accent`, `positive`, `negative`,
`highlight`, `on_status`, `true_mask`, `false_mask`, `unavailable`, `point`,
`box_fill`, `reference`, and `categorical` (a list of exactly 10 colours). Data
keys pass through unresolved: `sequential_cmap`, `density_cmap`, `time_cmap`
(matplotlib colormap names) and `time_range` (`[lo, hi]` fractions of the
colormap). Blackbox `dark` and `light` hold the values bekiper's `themekit`
crate shipped, verbatim, so published figures keep their colours; they are
deliberately independent of the `ui` chrome.

## Web renderer

`lib.web` turns a `{providers, light, dark}` pair of selections (each resolved
through `resolveSelection`) into:

- `lib.web.css`: `:root` for light, an `@media (prefers-color-scheme: dark)`
  block scoped to `:root:not([data-theme=light])`, and `[data-theme=dark]` /
  `[data-theme=light]` overrides. Every scalar colour of `ui`, `status`,
  `syntax` and `figure` becomes `--tb-<group>-<role>` (camelCase and
  snake_case kebab-cased, e.g. `--tb-ui-background-alt`,
  `--tb-figure-surface-alt`).
- `lib.web.json`: both modes with every role, including figure lists and
  colormap names.
- `lib.web.uiPalette selected`: `roles.ui` as plain `"#rrggbb"` strings, the
  mapping web surfaces without the module consume.

`packages.<system>.web-theme-blackbox` contains `theme.css` and `theme.json` for
`blackbox/light` + `blackbox/dark`. The Rust crate `crates/theme-broker`
embeds committed copies in `crates/theme-broker/generated/`; refresh them after
a palette change with

```console
nix build .#web-theme-blackbox
cp result/theme.css result/theme.json crates/theme-broker/generated/
chmod u+w crates/theme-broker/generated/*
```

The `theme-broker-snapshot` check fails when they drift, and `web-golden`
pins the figure-less Gruvbox path in `tests/golden/web-gruvbox.css`.
