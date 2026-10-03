{manifest ? import ./manifest.nix}:
map (
  item: {
    schema = "theme-broker.adapter/v1";
    id = "catppuccin-${item.id}";
    provider = "catppuccin";
    target = item.id;
    platforms = item.platforms;
    priority =
      if item.autoSafe
      then 100
      else 50;
    autoSafe = item.autoSafe;
    provenance = {
      tier = item.trustTier;
      repository = manifest.source.repository;
      revision = manifest.source.revision;
      license = "MIT";
    };
    capabilities = {
      variants = item.variants;
      accent = item.accent;
      namedOverrides = false;
      roleOverrides = false;
      transparency = false;
      profiles = item.profiles or false;
      nativeOptions = item.nativeOptions or [];
    };
    optionPath = item.optionPath;
    optionValues =
      item.optionValues
      or (
        if item.id == "zed-editor"
        then {icons.enable = true;}
        else {}
      );
    class = item.class or "simple";
    rendererKind = item.rendererKind;
    module = "catppuccin";
  }
)
# The pinned upstream OpenCode port writes v1 tui.json settings. Keep it in
# the source inventory, but do not advertise it as a working v2 adapter.
(builtins.filter (item: item.id != "opencode") (builtins.attrValues manifest.targets))
