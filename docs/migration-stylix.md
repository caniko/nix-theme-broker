# Migrating from Stylix-only configuration

Keep existing Stylix font, opacity, cursor, and wallpaper settings. Add the
broker and select a provider; generic targets continue to be rendered by
Stylix:

```nix
themeBroker.enable = true;
themeBroker.selection = {
  provider = "gruvbox";
  variant = "dark-hard";
  accent = null;
};
```

Enroll one native target at a time with `themeBroker.targets.<id>.backend`.
