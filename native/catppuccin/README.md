# Catppuccin native bridge

The manifest records the pinned `catppuccin/nix` target inventory, including
simple options and profile-based integrations. The broker imports the upstream
platform module and does not copy or rebuild Catppuccin port sources. Complex
targets are marked in the manifest and are only enrolled when a user selects
them explicitly.

Regenerate it from an explicit checkout with:

```console
python3 scripts/update-native.py /path/to/catppuccin-nix
```
