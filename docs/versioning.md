# Compatibility and versioning

The provider and adapter schemas are versioned independently from the flake.
This checkout implements `theme-broker.provider/v1`,
`theme-broker.adapter/v1`, and `theme-broker.support-matrix/v1`.

Before 1.0, new optional fields may be added without a schema bump. Removing a
field, changing an option type, changing resolver ordering, or changing the
meaning of an existing target requires a new schema version and a migration
note. Provider palette corrections are data changes and must update the pinned
source revision, golden fixtures, and support matrix together.

The supported compatibility window is the exact locked nixpkgs, Stylix, and
Catppuccin revisions in `flake.lock`; upgrades are reviewable input changes,
not floating runtime dependencies.
