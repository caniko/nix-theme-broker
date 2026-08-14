# Rosé Pine provider

`palette.json` is a deterministic snapshot of `source/index.ts` from
[`rose-pine/rose-pine-palette`](https://github.com/rose-pine/rose-pine-palette)
at revision `92af52b465ab6e47437aca223c9b8d3009a2023b`. Base16 follows
[`tinted-theming/schemes`](https://github.com/tinted-theming/schemes) revision
`9bd28ed313560db3c5e605c63bc4e309e78e3fc8`.

At the pinned palette revision, Dawn's canonical `overlay.hex` is `#f2e9e1`
while its RGB value and Tinted `base02` resolve to `#f2e9de`. The snapshot keeps
the canonical overlay for semantic and ANSI output and records the Tinted value
separately for Base16.

Wire the provider into `flake.nix` beside the existing imports:

```nix
rosePine = import ./providers/rose-pine {inherit (nixpkgs) lib;};
providers = {
  catppuccin = catppuccinProvider;
  inherit gruvbox;
  rose-pine = rosePine;
};
```

Also add the provider to `tintedBase16` and update the provider-count checks:

```nix
rose-pine = lib.mapAttrs (variant: _: resolveBase16 "rose-pine" variant "rose") rosePine.variants;
```

`provider-shape` should assert 3 variants and 6 accents for `rosePine`, while
`support-matrix` should expect 3 providers. Provider conformance is already
derived from `providers` and needs no separate entry.

Add these checks to the list in `tests/golden/check.nix`:

```nix
(check ./rose-pine-main-rose.json {
  provider = "rose-pine";
  variant = "main";
  accent = "rose";
})
(check ./rose-pine-moon-iris.json {
  provider = "rose-pine";
  variant = "moon";
  accent = "iris";
})
(check ./rose-pine-dawn-pine.json {
  provider = "rose-pine";
  variant = "dawn";
  accent = "pine";
})
```

The repository-wide Tinted check can cover this provider once
`scripts/check-tinted.py` maps `main`, `moon`, and `dawn` to `rose-pine`,
`rose-pine-moon`, and `rose-pine-dawn`; that shared-file change is outside this
provider slice.
