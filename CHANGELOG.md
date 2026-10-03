# Changelog

## Unreleased

- Add OpenCode v2 terminal theming for every provider: complete semantic tokens,
  light/dark variants, accent and named/role override fidelity, and mergeable
  `themeBroker.opencode.cliSettings` written to `cli.json`. The generated
  `opencode` backend now uses the broker's v2 compatibility engine. Disable
  the pinned v1 writers and exclude `catppuccin-opencode` from the active
  native registry; existing native users should switch to `auto` or
  `generated` and move v2 CLI preferences out of `programs.opencode.tui`.

- Add the `blackbox` built-in provider: a local, true-black (`#000000`),
  Gruvbox-inspired derivative with a single `dark` variant, no accent axis,
  and no Base24 projection. Ships its authoritative `palette.json` inventory,
  semantic/ANSI/Base16 projections, an eval assertion suite, a real Home
  Manager generated-file check, and a `blackbox-home-manager` example.
  Gruvbox is unchanged; Blackbox declares no native adapters, so `auto` never
  picks a provider-mismatched adapter.

## 1.0.3 - 2026-08-15

- Reserve exported built-in adapter IDs in the public resolver and validate
  every `trustedAdapters` entry by exact built-in identity; custom adapters
  reuse those IDs only at their own risk and are rejected.
- Restore simple-adapter `nativeOptions` support: declared keys are validated
  and forwarded into the adapter's option path, restoring `adapter/v1`
  compatibility with v1.0.1 behavior.
- Require a non-empty `provenance.repository` at runtime, matching the JSON
  Schema.
- Separate push and pull-request CI concurrency groups so an older branch
  event is not cancelled by its newer counterpart.

## 1.0.2 - 2026-08-15

- Reject duplicate adapter IDs across built-in, module, registry, and public
  resolver inputs; the public resolver keeps accepting the released
  `trustedAdapters` argument.
- Allow the exported built-in adapter registry to compose with the public
  resolver while keeping forged renderer descriptors on the custom path.
- Require adapters declaring native options to be complex and align the JSON
  Schema with runtime renderer ownership, native-option, and provenance
  validation.
- Prefer content hashes over dirty revisions for input provenance.

## 1.0.1 - 2026-08-15

- Reject native options that the selected adapter does not declare or consume.
- Reserve built-in renderer kinds for their built-in adapters and improve
  fallback diagnostics.
- Keep built-in renderer adapters in a trusted channel and validate custom
  adapters through the normal resolver path.
- Correct the Rosé Pine snapshot and validator to use canonical
  `source/index.ts`; regenerate and verify the goldens.
- Allow Base24 overrides to create an optional projection when a provider does
  not publish Base24 colors.
- Use revisions from evaluated flake inputs for provider provenance and tighten
  resolver, schema, and provider-conformance checks.

## 1.0.0 - 2026-08-15

- Added the Rosé Pine provider with three variants, six accents, and Tinted
  Base16 conformance.
- Added renderer-aware native target metadata, profile-based Home Manager
  bridges, stricter option validation, and safer generated fallback handling.
- Added palette-neutral provider normalization for Catppuccin, Gruvbox, and
  Rosé Pine.
- Added deterministic generated/native resolution with provenance-aware
  adapters.
- Added Stylix coordination, complete pinned Catppuccin target renderers,
  profile-aware Firefox and VS Code-family adapters, and Gruvbox Vim, Neovim,
  VS Code, and cursor adapters.
- Added reproducible provider, manifest, golden, and support-matrix checks.
- Added real Home Manager, NixOS, and nix-darwin evaluation coverage, schema
  validation, provenance synchronization, and a no-IFD gate.
