# Options

All options live below `themeBroker` and are disabled by default.

| Option | Meaning |
| --- | --- |
| `enable` | Enable selection, Stylix bridge, and broker-managed targets. |
| `selection.provider` | Registered provider ID (`catppuccin`, `gruvbox`, or `rose-pine`). |
| `selection.variant` | Optional provider variant ID; `null` uses the provider default. |
| `selection.accent` | Optional accent; `null` uses the provider default. |
| `selection.overrides` | Named, semantic-role, ANSI, Base16, or Base24 overrides. |
| `registry.wallpapers` | Relative wallpaper collections keyed by provider ID. |
| `manageStylixScheme` | Keep the selected Base16 scheme in Stylix (default `true`). |
| `policy.defaultBackend` | Effective default: `auto`, `generated`, or `native`. |
| `policy.allowedNativeTiers` | Trust tiers accepted by the resolver. |
| `policy.requireAccentFidelity` | Reject native adapters without accent support. |
| `policy.requireOverrideFidelity` | Reject native adapters without override support. |
| `policy.onUnsupported` | `fallback`, `warn`, or `error` policy for unsupported requests. |
| `policy.preferNative` | Prefer an accepted native adapter over Stylix. |
| `targets.<id>.backend` | Per-target backend request. |
| `targets.<id>.managed` | Leave a target outside broker ownership when `false`. |
| `targets.<id>.nativeOptions` | Adapter-declared values only: `name` for Gruvbox cursors, `transparent` for Gruvbox Neovim, and `profile` for Catppuccin profile targets. Unsupported values fail resolution instead of being ignored. |

`selected`, `resolved`, and `generatedTargets` are read-only debug outputs.
`selected.wallpapers` is the matching `{ default, paths }` collection or `null`.
The broker exposes wallpaper metadata but does not configure Stylix or desktop
wallpaper options. The managed `cursors` target selects a provider-native
cursor and uses size 24.

Base24 overrides may create an optional Base24 projection for providers that do
not publish one; providers that already publish Base24 retain their fixed key
set.

For Gruvbox, the broker selects `Bibata-Original-Amber` for dark variants and
`Bibata-Original-Classic` for light variants. Override the name when needed:

```nix
themeBroker.targets.cursors = {
  backend = "native";
  nativeOptions.name = "Bibata-Modern-Ice";
};
```

Set `themeBroker.targets.cursors.managed = false` to keep a direct
`stylix.cursor` configuration instead.
