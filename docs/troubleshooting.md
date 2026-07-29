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
