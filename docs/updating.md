# Updating pinned inputs

Maintenance commands take explicit realized source paths. They never run from
Nix evaluation or a build sandbox.

```text
python3 scripts/update-catppuccin.py /path/to/catppuccin-palette --write-golden
python3 scripts/update-native.py /path/to/catppuccin-nix
python3 scripts/update-gruvbox.py /path/to/morhetz-gruvbox
python3 scripts/update-rose-pine.py /path/to/rose-pine-palette
python3 scripts/update-golden.py             # verify reviewed fixtures
python3 scripts/update-golden.py --write     # rewrite after reviewing a diff
python3 scripts/update-golden.py --refresh-source # provenance only; refuses color changes
```

After an update, inspect the provider, manifest, golden, and support-matrix
diffs together. An upstream target removal or a changed native capability is a
review item; it is never silently accepted by a build.

`canix-update.toml` registers the provenance refresh after dependency updates.
It verifies the existing golden values against both provider output and the
new pinned Tinted source before advancing the source revision. Color changes
remain an explicit review item; the unattended operation does not rewrite them.
