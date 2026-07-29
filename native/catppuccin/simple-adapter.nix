{manifest ? import ./manifest.nix}: let
  item = manifest.targets.alacritty;
in {
  schema = "theme-broker.adapter/v1";
  id = "catppuccin-alacritty";
  provider = "catppuccin";
  target = "alacritty";
  platforms = item.platforms;
  priority = 100;
  autoSafe = item.autoSafe;
  provenance = {
    tier = item.trustTier;
    repository = "https://github.com/catppuccin/alacritty";
    revision = "8c3b8e9";
    license = "MIT";
  };
  capabilities = {
    variants = item.variants;
    accent = item.accent;
    namedOverrides = false;
    roleOverrides = false;
    transparency = false;
  };
  module = "catppuccin";
}
