# Upstream coordination

The broker deliberately does not copy Stylix target implementations. Generic
targets remain owned by Stylix; the broker only coordinates their enable flags.

The temporary COSMIC manager target is tracked upstream in
[Stylix issue #265](https://github.com/nix-community/stylix/issues/265).
Remove `targets/cosmic-manager.nix` and its registry entry when Stylix ships a
compatible COSMIC target with the required palette and v2 frosted-theme
behavior. Until then, `cosmicLib` and the COSMIC module options remain explicit
integration inputs.

Per-target provider selection was considered and rejected for v1; see
`adr/0006-per-target-generated-selection.md`.
