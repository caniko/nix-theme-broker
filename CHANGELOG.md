# Changelog

## 1.0.1 - 2026-08-15

- Reject native options that the selected adapter does not declare or consume.
- Reserve built-in renderer kinds for their built-in adapters and improve
  fallback diagnostics.
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
