# Theme Broker for Nix

This flake exposes a palette-neutral `themeBroker` module and provider library.
Gruvbox's six variants, Catppuccin's four appearances, and Rosé Pine's three
variants normalize into semantic roles, ANSI, Base16, and optional Base24
projections. The broker also ships curated Gruvbox Vim/Neovim/VS Code/cursor
adapters, complete pinned Catppuccin target renderers, and a deterministic
generated/native backend resolver.

For example, the Atlas Home Manager profile selects `gruvbox/dark-hard` and
lets Stylix consume the broker's Base16 projection:

```nix
themeBroker = {
  enable = true;
  selection = {
    provider = "gruvbox";
    variant = "dark-hard";
  };
};
```

Enroll the cursor target to select a provider-native cursor. Dark Gruvbox
variants use `Bibata-Original-Amber`; light variants use
`Bibata-Original-Classic`. Catppuccin uses its official flavor/accent cursor
package.

```nix
themeBroker.targets.cursors.backend = "auto";
```

Stylix remains the generic target engine. Native integrations are opt-in per
managed target:

```nix
themeBroker = {
  enable = true;
  selection = {
    provider = "catppuccin";
    variant = "mocha";
    accent = "mauve";
  };
  targets.alacritty.backend = "native";
};
```

Generic target IDs come from the checked-in `lib/generated-targets.nix`
compatibility registry for the pinned Stylix release. The broker records only
availability and platform metadata; Stylix still owns each target
implementation.

Use `backend = "generated"` to force Stylix, `backend = "native"` to require
an allowed adapter, or `backend = "auto"` (the default) to prefer an exact
native adapter. Inspect `themeBroker.resolved.targets` with `nix eval --json`.

Consumers may register relative wallpaper collections under
`themeBroker.registry.wallpapers`. The selected collection is exposed as
`themeBroker.selected.wallpapers`; the consumer still owns the source root and
desktop wallpaper configuration.

The flake exports `packages.<system>.support-matrix-json` and
`support-matrix-markdown`, plus the provider, normalized-theme, wallpaper
catalog, and adapter schemas. Nix evaluation reads only locked inputs and
reviewed files; updater scripts never run during a build.
