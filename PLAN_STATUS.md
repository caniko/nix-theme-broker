# Theme Broker implementation status

Updated 2026-08-15.  “Complete” means the task has an implementation and a
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
| TB-031 | complete | explicit pinned Stylix compatibility registry, canonical aliases, and generated-target safety metadata; dynamic option introspection remains intentionally disabled |
| TB-032 | complete | Home Manager, NixOS, and Darwin fixtures cover the registered platform-correct generated targets across both providers and light/dark selections |
| TB-040 | complete | adapter descriptors, JSON schema, strict trust/platform/capability validator, and merge/evaluation tests |
| TB-041 | complete | deterministic generated/native/auto resolver with R-001 through R-015 table coverage |
| TB-042 | complete | managed target coordination, direct-scheme conflict assertion, and managed=false escape hatch |
| TB-043 | complete | policy, target, nativeOptions, and read-only resolution options are documented and evaluated |
| TB-044 | complete | synthetic generated/native resolver slice |
| TB-050 | complete | pinned Catppuccin platform bridge disables auto-enrollment and applies the effective flavor/accent only for enrolled native targets |
| TB-051 | complete | deterministic 95-target manifest generator, pinned-source stale check, and official adapter registry |
| TB-052 | complete | profile-aware Firefox and all six VS Code-family renderers use the pinned upstream modules and profile option |
| TB-053 | complete | NixOS Plymouth, Home Assistant, graphical asset, and cursor option-path integrations are evaluated |
| TB-054 | complete | option-path, profile, plugin/extension, package, cursor, graphical, and service integration classes have focused evaluation coverage |
| TB-055 | complete | all 95 pinned Catppuccin inventory entries have a supported renderer kind and no unexplained support-matrix gaps |
| TB-060 | complete | pinned, hashed Gruvbox Vim and Neovim provenance with canonical/maintained trust tiers |
| TB-061–TB-063 | complete | reusable Vim/Neovim native modules, all six variant evaluations, and mixed native/generated end-to-end checks |
| TB-070 | complete | generated JSON/Markdown packages plus checked-in stale-file comparison |
| TB-071–TB-074 | complete | user, migration, authoring, troubleshooting, release docs, four evaluated examples, and CI gates |
| TB-080 | complete | thirteen variants, twenty accents, resolver policy cases, real Home Manager/NixOS/darwin evaluations, and all remaining pinned systems run; x86_64-darwin is omitted because pinned nixpkgs 26.11 dropped that system |
| TB-081 | complete | explicit Catppuccin, Gruvbox, native-manifest, and golden update wrappers with AST/no-IFD/stale checks |
| TB-082 | complete | independent schema/version policy, changelog, compatibility window, and release checklist |
| TB-083 | complete | v0.1 implementation was published and superseded by the v1.0.0 release |
| TB-090 | complete | ADR 0006 keeps provider selection global and documents the existing Stylix override escape hatch |
| TB-091 | complete | temporary COSMIC target is tracked by Stylix issue #265 with explicit removal conditions |
| TB-092 | complete | Rosé Pine is the third provider and passes the shared conformance, golden, and Tinted checks |
| TB-093 | complete | v1.0.0 tag and GitHub release published: https://github.com/caniko/nix-theme-broker/releases/tag/v1.0.0 |

The Atlas deployment slice selects Gruvbox `dark-hard` through the parent
canix Home Manager profile. Stylix owns generic targets, while the broker has
curated Gruvbox native adapters, a pinned Catppuccin renderer inventory, and a
Rosé Pine provider. Native profile targets delegate to the pinned upstream
Catppuccin modules rather than copying port implementations.

Atlas live verification on 2026-07-29 found the candidate persisted and
`home-manager-can.service` active. Ghostty, Helix, btop, and the Stylix palette
all expose Gruvbox `dark-hard` (`base00 = #1d2021`, `base05 = #d5c4a1`). The
activation command reported the pre-existing `foundryvtt.service` failure
caused by unmanaged `Data/systems/daggerheart`; that service was not changed.
