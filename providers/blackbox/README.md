# Blackbox provider

`palette.json` is the authoritative, hand-maintained color inventory for
Blackbox: a true-black, Gruvbox-inspired theme maintained in this repository.
It is a **local Gruvbox-inspired derivative, not an official Gruvbox
release**. The normal/bright accent hexes and the cream foreground family
follow the pinned [`morhetz/gruvbox`](https://github.com/morhetz/gruvbox)
commit `5d15b2765f59754d7ac263c88a0f6e3e58124951`; the true-black background,
the gray surfaces, and the magenta accents are Blackbox-specific. There is no
upstream snapshot to pin, so `source.revision` is `local`.

`default.nix` turns the inventory into the standard provider shape: aliases
(one hop from `@name` to a literal color), semantic roles, the complete ANSI
banks, and the Base16 projection — all through `@name` references so named
overrides propagate everywhere.

There is deliberately no `update.py`: nothing here is generated from an
upstream source, so the repository has no updater step for this provider.
The preview image labels are known to be wrong (mislabeled bright blue/aqua,
an invalid purple hex, and `#1a1a1a` labeled `bright_black`); the JSON
inventory and the tests are authoritative instead.

The provider exposes three variants, `dark`, `light`, and `honey`. `dark` and
`light` expose `orange` ("Blackbox Orange", the default; `accent = null`
resolves to it) and `blue` ("Blackbox Blue", used by the web theme) accents
bound to `ui.accent` and `ui.focus`. `light` has its own `named` inventory
(`variants.light.named`) and a literal `border` alias; `honey` has a warm named
inventory plus alias and role overrides and no accent axis, so its accent and
focus stay on the honey ramp.
Variants without `named` share the top-level (dark) inventory.
Each variant may also carry a `figure` object, exposed as `roles.figure`.
`honey` uses `figureFrom = "dark"` to reuse the scientific figure group.
