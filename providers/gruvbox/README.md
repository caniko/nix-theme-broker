# Gruvbox provider

`palette.json` is the reviewed, deterministic snapshot of the canonical
[`morhetz/gruvbox`](https://github.com/morhetz/gruvbox) palette.  Nix evaluation
reads this file directly; it never executes the updater or parses VimScript.

Run the updater after reviewing an upstream refresh:

```console
python3 scripts/update-gruvbox.py /path/to/morhetz-gruvbox
```

The provider exposes `dark-hard`, `dark-medium`, `dark-soft`, `light-hard`,
`light-medium`, and `light-soft`.  Gruvbox has no global accent axis; semantic
role overrides are the supported way to choose a different focus color.
