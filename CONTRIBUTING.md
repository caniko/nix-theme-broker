# Contributing

Keep provider data deterministic and reviewable.  Do not add network access to
Nix evaluation or activation-time downloads.

From this checkout:

```console
nix fmt
nix flake check --no-update-lock-file --all-systems
nix develop -c python3 providers/gruvbox/update.py
```

Update `PLAN_STATUS.md` when a tracked feature or release criterion changes.
Generated palette, manifest, golden, and support-matrix changes must be
committed with their source metadata. Upstream coordination belongs in
`docs/upstream.md`; do not copy upstream target implementations into this
repository.
