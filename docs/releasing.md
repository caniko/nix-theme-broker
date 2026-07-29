# Release checklist

Before tagging a release:

1. run `nix fmt -- --check .`;
2. run `nix flake check --no-update-lock-file --all-systems`;
3. run the explicit provider and native update validators when inputs changed;
4. run `python3 scripts/update-golden.py` and inspect any diff;
5. verify the support-matrix stale-file check and example evaluations;
6. review schema, option, provenance, and compatibility changes in the
   changelog;
7. tag only after the upstream remote has a writable branch and the release
   artifacts are available.

The release gate is intentionally separate from deployment. A local checkout
with no remote refs can pass all reproducible checks but cannot claim a
published `v0.1.0` or `v1.0.0` release.
