# ADR 0006: Native VS Code theme adapters

## Status

Accepted

## Context

VS Code themes are extension-owned. Letting Stylix or a canix profile write a
theme name while separately managing extensions allowed the extension set and
the selected provider to drift. The Gruvbox Material icon extension is not in
nixpkgs, and its Marketplace package must remain reproducible.

## Decision

Theme Broker owns the VS Code adapter after canix explicitly enrolls the
`vscode` target with `backend = "native"`. The Gruvbox adapter installs
`jdinhlife.gruvbox` 1.29.1 and a fixed-hash Marketplace VSIX for
`navernoedenis.gruvbox-material-icons` 4.6.0. It writes flat
`workbench.colorTheme` and `workbench.iconTheme` settings and maps the broker
variant `dark-hard` to the exact label `Gruvbox Dark Hard`. Catppuccin has an
equivalent adapter for its color/icon extensions and keeps its broken generated
VS Code source disabled.

Native adapters disable `stylix.targets.vscode.enable`, so Stylix and native
settings do not compete. Extension provenance stays in the adapter metadata;
the Marketplace VSIX is packaged with `buildVscodeMarketplaceExtension` and a
fixed hash rather than a runtime download or JavaScript build.

## Consequences

Canix no longer needs to list provider theme extensions or nested theme names
in its VS Code profile. Switching providers replaces the adapter-owned
extensions and settings while unrelated VS Code extensions remain user-owned.
