# Migrating from Stylix-only configuration

Keep existing Stylix font, opacity, and wallpaper settings. Add the broker and
select a provider; generic targets continue to be rendered by Stylix:

```nix
themeBroker.enable = true;
themeBroker.selection = {
  provider = "gruvbox";
  variant = "dark-hard";
  accent = null;
};
```

Enroll one native target at a time with `themeBroker.targets.<id>.backend`.

The broker can also manage the cursor through `themeBroker.targets.cursors`.
Set that target to `managed = false` if an existing direct `stylix.cursor`
configuration should remain authoritative.
