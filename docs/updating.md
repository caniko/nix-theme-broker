# Updating pinned inputs

Maintenance commands take explicit realized source paths. They never run from
Nix evaluation or a build sandbox.

```text
python3 scripts/update-catppuccin.py /path/to/catppuccin-palette --write-golden
python3 scripts/update-native.py /path/to/catppuccin-nix
python3 scripts/update-gruvbox.py /path/to/morhetz-gruvbox
python3 scripts/update-golden.py             # verify reviewed fixtures
python3 scripts/update-golden.py --write     # rewrite after reviewing a diff
```

After an update, inspect the provider, manifest, golden, and support-matrix
diffs together. An upstream target removal or a changed native capability is a
review item; it is never silently accepted by a build.
