# Release checklist

Before tagging a release:

1. run `nix develop -c alejandra --check .`;
2. run `nix flake check --no-update-lock-file --all-systems`;
3. build the `schema-validation`, `no-ifd`, `evaluation`, and
   `support-matrix-stale` checks;
4. run the explicit provider and native update validators when inputs changed;
5. run `python3 scripts/update-golden.py` and inspect any diff;
6. verify the support matrix, real Home Manager/NixOS/darwin evaluations, and
   all example evaluations;
7. review schema, option, provenance, and compatibility changes in the
   changelog;
8. tag only after `trunk` is pushed and all remote checks pass; publish the
   matching GitHub release.

The release gate is intentionally separate from deployment. The project uses
MIT licensing and publishes immutable version tags; downstream consumers should
pin a release tag or commit rather than a moving branch. Tag immutability is
enforced by a repository ruleset that blocks deletion and force-push on
`refs/tags/v*`.
