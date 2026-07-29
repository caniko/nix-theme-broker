# Migrating from direct Catppuccin modules

Keep direct Catppuccin integrations that the broker does not manage. For a
managed target, move flavor/accent selection into the broker and let it set
`catppuccin.autoEnable = false`:

```nix
themeBroker = {
  enable = true;
  selection = {provider = "catppuccin"; variant = "mocha"; accent = "mauve";};
  targets.alacritty.backend = "native";
};
```

The bridge delegates target implementation to the pinned `catppuccin/nix`
module; it does not copy Catppuccin port sources.
