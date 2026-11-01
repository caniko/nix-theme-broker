# Golden fixtures

Golden files record stable, user-visible projections rather than every Nix
thunk in a normalized value.  Regenerate them only after reviewing a provider
mapping change:

```console
python3 scripts/update-golden.py
python3 scripts/update-golden.py --write  # only after reviewing the diff
```

The checked-in fixtures below are intentionally small and catch accidental
Base16 or semantic-role drift.

`web-gruvbox.css` pins the web renderer on a provider without figure roles
(`gruvbox/light-hard` + `gruvbox/dark-hard`). Refresh it after reviewing a
renderer change:

```console
nix eval --raw --impure --expr 'let f = builtins.getFlake (toString ./.); in f.lib.web.css {providers = f.lib.providers; light = {provider = "gruvbox"; variant = "light-hard"; accent = null;}; dark = {provider = "gruvbox"; variant = "dark-hard"; accent = null;};}' > tests/golden/web-gruvbox.css
```
