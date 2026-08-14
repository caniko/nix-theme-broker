# Catppuccin native bridge

The manifest records the pinned `catppuccin/nix` target inventory, including
simple options and renderer kinds for VS Code-family and Firefox profile
integrations. The broker imports the upstream platform module and does not copy
or rebuild Catppuccin port sources. Simple targets use their declared option
path; profile targets use the upstream profile module with
`nativeOptions.profile`.

Regenerate it from an explicit checkout with:

```console
python3 scripts/update-native.py /path/to/catppuccin-nix
```
