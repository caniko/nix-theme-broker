# Options

All options live below `themeBroker` and are disabled by default.

| Option | Meaning |
| --- | --- |
| `enable` | Enable selection, Stylix bridge, and broker-managed targets. |
| `selection.provider` | Registered provider ID (`catppuccin` or `gruvbox`). |
| `selection.variant` | Optional provider variant ID; `null` uses the provider default. |
| `selection.accent` | Optional accent; `null` uses the provider default. |
| `selection.overrides` | Named, semantic-role, ANSI, Base16, or Base24 overrides. |
| `manageStylixScheme` | Keep the selected Base16 scheme in Stylix (default `true`). |
| `policy.defaultBackend` | Effective default: `auto`, `generated`, or `native`. |
| `policy.allowedNativeTiers` | Trust tiers accepted by the resolver. |
| `policy.requireAccentFidelity` | Reject native adapters without accent support. |
| `policy.requireOverrideFidelity` | Reject native adapters without override support. |
| `policy.onUnsupported` | `fallback`, `warn`, or `error` policy for unsupported requests. |
| `policy.preferNative` | Prefer an accepted native adapter over Stylix. |
| `targets.<id>.backend` | Per-target backend request. |
| `targets.<id>.managed` | Leave a target outside broker ownership when `false`. |
| `targets.<id>.nativeOptions` | Adapter-specific passthrough values. |

`selected`, `resolved`, and `generatedTargets` are read-only debug outputs. The broker does not own
Stylix fonts, opacity, cursor, wallpaper, or unrelated application options.
