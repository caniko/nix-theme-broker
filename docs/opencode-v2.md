# OpenCode v2 terminal themes

The Home Manager `opencode` target renders a provider-neutral v2 theme from
`themeBroker.selected`. It supports all built-in providers and variants,
selected accents, and named/semantic-role overrides.

```nix
themeBroker = {
  enable = true;
  selection = {
    provider = "catppuccin";
    variant = "latte";
    accent = "mauve";
  };
  targets.opencode.backend = "auto";
  opencode.cliSettings = {
    animations = false;
    tabs.mode = "off";
  };
};
```

`auto` and `generated` select the `opencode-v2` engine. Inspect it through
`themeBroker.resolved.targets.opencode.engine`. The pinned Catppuccin OpenCode
adapter is excluded from the active native registry because it writes v1
settings; an explicit `native` request fails unless a compatible custom
adapter is registered.

## Generated files

Files are relative to Home Manager's `xdg.configHome`:

- `opencode/themes/theme-broker.json`: a complete semantic token tree and the
  selected variant's single light or dark hue palette.
- `opencode/cli.json`: mergeable CLI preferences, with `theme.name` defaulting
  to `theme-broker` and `theme.mode` defaulting to the variant's appearance.

Core UI, status, and syntax colors use the selected semantic roles exactly.
Hue scales, feedback fills, and diff highlights use deterministic integer sRGB
interpolation. Blackbox's base background remains exactly `#000000`. Dialogs
use the palette's raised surfaces. Generated themes define action states,
form fields, Markdown, diffs, scrollbars, and agent/category colors.

OpenCode v2 permits a single-mode theme and falls back to its available mode.
Set `themeBroker.opencode.cliSettings.theme.mode = "system"` to follow the
terminal's mode preference; this does not synthesize an opposite broker
variant. A different light/dark palette is selected through
`themeBroker.selection.variant`.

## Settings ownership and migration

Declare other CLI preferences through `themeBroker.opencode.cliSettings` so
they merge as structured Nix values with the generated theme defaults. This
option uses the same JSON value type as other Home Manager settings.

If another module currently owns `xdg.configFile."opencode/cli.json"`, move its
declarative settings into `themeBroker.opencode.cliSettings` before enrolling
the target. Existing hand-edited CLI preferences should likewise be transferred
before Home Manager takes ownership. Home Manager's normal file-collision
handling applies; activation does not edit an existing unmanaged file.

The pinned `programs.opencode.tui` option writes v1 `tui.json`, not v2
`cli.json`. Move v2 CLI settings to the broker option using the
[v2 settings reference](https://opencode.ai/v2/docs/cli/config); some field
names differ. Server/project settings stay in `programs.opencode.settings`.

The generated target disables the pinned Stylix and Catppuccin OpenCode
writers. An unmanaged target (`targets.opencode.managed = false`) or disabled
broker produces no broker-owned OpenCode files.

Restart OpenCode after first installing the custom theme, then inspect it with
`/themes`. Valid CLI setting edits reload while the TUI is running. The
`OPENCODE_CLI_CONFIG_CONTENT` environment variable has higher precedence than
the file, and a project-local theme with the same filename can replace the
global theme.

## Upstream format

The implementation follows the [v2 theme reference](https://opencode.ai/v2/docs/cli/theme)
and the complete Theme Tool contract inspected on 2026-10-03 in
[`index-CQ7B4SMg.js`](https://opencode.ai/theme/assets/index-CQ7B4SMg.js).
`tests/fixtures/opencode-v2-theme.schema.json` records the emitted subset of
that contract for offline validation. The advertised theme-schema endpoint
returned 404 at inspection time, so checks use this reviewed local fixture.
Nix evaluation and activation never fetch theme definitions.
