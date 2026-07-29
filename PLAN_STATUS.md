# Theme Broker implementation status

Updated 2026-07-29.  “Complete” means the task has an implementation and a
passing narrow check in this checkout.  “Partial” means the public shape is in
place but the task's full acceptance matrix is still pending.

| Task | Status | Evidence / limitation |
| --- | --- | --- |
| TB-001 | complete | research baseline and ADRs |
| TB-002 | complete | locked flake, formatter, devShell, checks |
| TB-003 | complete | three platform module entry points; disabled by default |
| TB-004 | complete | CI, contribution, and status workflow |
| TB-010 | complete | parser, lowercase/hashtag/0x/RGB views |
| TB-011 | complete | Nix validator, path-aware errors, JSON schema, fixtures, and invalid-fixture evaluation check |
| TB-012 | complete | selection, accents, ordered overrides, projections |
| TB-013 | complete | public library and normalized schema |
| TB-014 | complete | reusable conformance harness, golden fixtures, explicit `scripts/update-golden.py`, and stale-golden check |
| TB-020 | complete | locked palette input, four variants, fourteen accents |
| TB-021 | complete | explicit pinned Tinted source input, all four Catppuccin variants, and source-backed Base16 conformance check |
| TB-022 | complete | reviewed JSON snapshot, canonical-source comparison, and deterministic updater |
| TB-023 | complete | six variants, reviewed JSON source, and source-backed Base16 conformance check for every Gruvbox variant |
| TB-024 | complete | built-in registry and full variant/accent conformance run in the evaluation check |
| TB-030 | complete | Stylix Base16 bridge leaves non-color settings alone |
| TB-031 | partial | explicit pinned Stylix compatibility registry and aliases; dynamic option introspection is intentionally not enabled because it recurses through the module system |
| TB-032 | partial | representative platform module evaluation and generated-target checks exist; the full per-provider/per-target platform matrix is still pending |
| TB-040 | complete | adapter descriptors, JSON schema, strict trust/platform/capability validator, and merge/evaluation tests |
| TB-041 | complete | deterministic generated/native/auto resolver with R-001 through R-015 table coverage |
| TB-042 | complete | managed target coordination, direct-scheme conflict assertion, and managed=false escape hatch |
| TB-043 | complete | policy, target, nativeOptions, and read-only resolution options are documented and evaluated |
| TB-044 | complete | synthetic generated/native resolver slice |
| TB-050 | partial | explicit Catppuccin Alacritty bridge disables auto-enrollment and applies selected flavor/accent; a generic upstream target map remains deferred because option ownership varies by platform |
| TB-051 | complete | deterministic 95-target manifest generator, pinned-source stale check, and official adapter registry |
| TB-052 | partial | profile and icon option paths are represented and tested through the bridge; dedicated complex adapter modules and class goldens remain |
| TB-053 | partial | NixOS target inventory is present; dedicated graphical/service adapter modules and tests remain |
| TB-054 | partial | Firefox, VS Code, GTK, cursor, Alacritty, and native bridge cases are covered; every upstream integration class is not yet exercised |
| TB-055 | partial | full pinned inventory is represented in the support matrix; unexplained parity gaps and class-specific tests remain a v1 gate |
| TB-060 | complete | pinned, hashed Gruvbox Vim and Neovim provenance with canonical/maintained trust tiers |
| TB-061–TB-063 | complete | reusable Vim/Neovim native modules, all six variant evaluations, and mixed native/generated end-to-end checks |
| TB-070 | complete | generated JSON/Markdown packages plus checked-in stale-file comparison |
| TB-071–TB-074 | complete | user, migration, authoring, troubleshooting, release docs, four evaluated examples, and CI gates |
| TB-080 | partial | all ten variants, fourteen Catppuccin accents, resolver cases, and Linux/Darwin module evaluations run; x86_64-darwin is omitted because pinned nixpkgs 26.11 dropped that system |
| TB-081 | complete | explicit Catppuccin, Gruvbox, native-manifest, and golden update wrappers with AST/no-IFD/stale checks |
| TB-082 | complete | independent schema/version policy, changelog, compatibility window, and release checklist |
| TB-083 | complete | v1 implementation published at `11b27d3a11ad1d609ce9d609c9d181d54b2e8118` on `origin/trunk`; canix consumes the immutable GitHub revision |
| TB-090–TB-093 | pending | post-MVP / v1 work |

The Atlas deployment slice selects Gruvbox `dark-hard` through the parent
canix Home Manager profile. Stylix owns generic targets, while the broker has
curated Gruvbox Vim/Neovim adapters, an explicit Catppuccin Alacritty bridge,
and a pinned Catppuccin native inventory.
The v1 Catppuccin complex-target parity work above remains deliberately
visible rather than being claimed from manifest metadata alone.

Atlas live verification on 2026-07-29 found the candidate persisted and
`home-manager-can.service` active. Ghostty, Helix, btop, and the Stylix palette
all expose Gruvbox `dark-hard` (`base00 = #1d2021`, `base05 = #d5c4a1`). The
activation command reported the pre-existing `foundryvtt.service` failure
caused by unmanaged `Data/systems/daggerheart`; that service was not changed.
