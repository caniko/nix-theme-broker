# Blackbox Home Manager

Import `default.nix` from a Home Manager configuration and provide the
checked-in `theme-broker` flake input as `inputs`.

Blackbox is a local, true-black (`#000000` background), Gruvbox-inspired
derivative provider. It has a single `dark` variant and no accents, so
`accent` stays `null`.

```nix
{
  inputs.theme-broker.url = "github:caniko/nix-theme-broker";

  # In the Home Manager configuration:
  imports = [inputs.theme-broker.homeModules.default];
  themeBroker = {
    enable = true;
    selection = {
      provider = "blackbox";
      variant = "dark";
      accent = null;
    };
  };
}
```

To return to a previous provider, change `themeBroker.selection.provider`
(and the matching `variant`/`accent`) back to the earlier values — for
example `provider = "gruvbox"; variant = "dark-hard";`.
