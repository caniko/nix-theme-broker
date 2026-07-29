# Contributing

Keep provider data deterministic and reviewable.  Do not add network access to
Nix evaluation or activation-time downloads.

From this checkout:

```console
nix fmt
nix flake check --no-update-lock-file --all-systems
nix develop -c python3 providers/gruvbox/update.py
```

When a task from `docs/src/planning/theme/theme-broker-nix-task-graph.yaml`
changes, update `PLAN_STATUS.md` with the task, files, checks, and known
limitations.  Generated palette and support-matrix changes must be committed
with their source metadata.
