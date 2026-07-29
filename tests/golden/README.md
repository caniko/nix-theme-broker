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
