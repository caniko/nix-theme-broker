# Theme Broker vision

A palette-neutral theme broker and provider library for Nix. Providers —
Gruvbox's six variants, Catppuccin's four appearances, Rosé Pine's three
variants, and Blackbox's single true-black variant — normalize into semantic
roles, ANSI, Base16, and optional Base24 projections, and a deterministic
resolver decides which managed targets consume them.

## Problem

Theming a fleet means the same palette has to reach Stylix, native application
modules, terminal renderers, and cursor/wallpaper selection. Every consumer
otherwise re-derives colors from a provider's raw palette, invents its own
accent handling, and drifts from the upstream source it claims to mirror.

## Principles

- **Providers own palettes; targets consume projections.** A provider is a
  normalized registry entry, not a target implementation. Selection, accents,
  ordered overrides, and projections are separate concerns.
- **Stylix remains the generic target engine.** Generic target IDs come from a
  checked-in compatibility registry for the pinned Stylix release; the broker
  supplies a temporary COSMIC engine and an OpenCode v2 engine only where the
  pinned integrations are not compatible.
- **Native adapters are opt-in per target.** `backend = "generated"`,
  `"native"`, or `"auto"` (prefer an exact native adapter) is an explicit
  decision, with a managed-target conflict assertion and a `managed = false`
  escape hatch.
- **No evaluation-time network or generation.** Nix evaluation reads only locked
  inputs and reviewed files; updater scripts never run during a build.
- **Goldens are reviewed and guarded.** Provider snapshots are canonical-source
  compared, updated only through explicit wrapper scripts, and a stale-golden
  check fails when they diverge.
- **Pinned upstream inventories.** The Catppuccin target inventory is a
  deterministic manifest with a pinned-source stale check; unported or
  incompatible entries are excluded explicitly rather than silently.
- **Provider selection is global.** ADR 0006 keeps one provider per
  configuration and points per-target divergence at Stylix's existing override
  escape hatch.

## Scope

The `themeBroker` Home Manager, NixOS, and Darwin modules; provider packages and
their semantic/ANSI/Base16 projections; curated Gruvbox native adapters; pinned
Catppuccin renderers; the explicit generated/native/auto resolver; an OpenCode v2
terminal renderer with mergeable `cliSettings`; a wallpaper catalog; and exported
support-matrix JSON/Markdown plus provider, theme, wallpaper, and adapter
schemas.

## Non-goals

- It is not a Stylix replacement; Stylix keeps generic target implementations.
- Dynamic introspection of Stylix options is intentionally disabled in favour of
  the pinned compatibility registry.
- Wallpaper sources and desktop wallpaper configuration stay consumer-owned; the
  broker only exposes the selected collection.

## Direction

Unreleased work adds OpenCode v2 terminal theming for every provider (semantic
tokens, light/dark variants, accent and named/role overrides) and the Blackbox
true-black provider. Temporary engines are tracked for removal once their pinned
upstream integrations become compatible; COSMIC depends on an open Stylix
issue.

## Place in the fleet

canix pins the flake and consumes it through `home/modules/theme-broker.nix`;
the broker's `t3code` target fills `nix-t3code`'s `themes` and `defaultTheme`
from the broker palette. canix documentation and Atlas's update automation
reference the repository.
