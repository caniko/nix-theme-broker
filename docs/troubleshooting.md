# Troubleshooting

Inspect the effective selection and target decisions:

```console
nix eval --json .#nixosConfigurations.<host>.config.themeBroker.resolved
```

If a target reports that generated and native backends conflict, set exactly
one explicit backend or opt that target out with
`themeBroker.targets.<id>.managed = false`. A requested native backend fails
when no adapter matches the provider, variant, platform, and allowed trust
tier. Use `backend = "generated"` for the Stylix path.

An accent mismatch is reported as `partial` unless
`policy.requireAccentFidelity = true`; it never changes unrelated Base16
syntax colors.

A CI run that fails within seconds during action setup with `A task was
canceled` at `Getting action download info` is usually a transient
GitHub-hosted runner failure; rerun the failed check (`gh run rerun <run-id>`
or the Actions rerun button) and the release gate continues. First check
whether a newer push or pull-request run for the same branch superseded the
run: push and pull-request runs share a concurrency group per branch, and
`cancel-in-progress` intentionally stops the older run.
