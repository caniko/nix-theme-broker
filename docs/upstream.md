# Upstream coordination

The broker deliberately does not copy Stylix target implementations. Generic
targets remain owned by Stylix; the broker only coordinates their enable flags.

## OpenCode v2

At the pinned revisions, Stylix's OpenCode target emits the v1 flat theme
format, and Catppuccin's port selects a built-in theme through v1 `tui.json`.
Neither writes v2's `cli.json` settings or complete semantic theme format.

`targets/opencode-v2.nix` is a temporary compatibility engine using the broker's
normalized semantic palette, implemented against OpenCode's v2 contract rather
than copied from the upstream targets. The generated target disables both v1
writers. The Catppuccin port remains in the reviewed source manifest but is
excluded from the active adapter registry and generated support matrix.

Remove this engine after pinned Home Manager/Stylix integrations support v2
CLI-settings composition and complete themes with broker accent/override
fidelity. Re-enable Catppuccin's native adapter only after its pinned port
supports v2. See [OpenCode v2 integration](opencode-v2.md).

The temporary COSMIC manager target is tracked upstream in
[Stylix issue #265](https://github.com/nix-community/stylix/issues/265).
As checked on 2026-08-15, the issue is still open and Stylix has not shipped a
compatible target; the latest upstream note points to pending shared COSMIC
module work in Home Manager and nixpkgs.
Remove `targets/cosmic-manager.nix` and its registry entry when Stylix ships a
compatible COSMIC target with the required palette and v2 frosted-theme
behavior. Until then, `cosmicLib` and the COSMIC module options remain explicit
integration inputs.

Per-target provider selection was considered and rejected for v1; see
`adr/0006-per-target-generated-selection.md`.
