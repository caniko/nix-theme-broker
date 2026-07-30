{
  lib,
  providers,
}: let
  themeLib = import ../../lib {inherit lib;};
  wallpapers.catppuccin = {
    variants = ["mocha"];
    default = "wallpapers/catppuccin/default.png";
    paths = [
      "wallpapers/catppuccin/default.png"
      "wallpapers/catppuccin/alternate.jpg"
    ];
  };
  selected = themeLib.resolveSelection {
    inherit providers;
    inherit wallpapers;
    selection = {
      provider = "catppuccin";
      variant = "mocha";
      accent = "blue";
      overrides.roles.ui.background = "#000000";
    };
  };
  providerDefault = themeLib.resolveSelection {
    inherit providers;
    inherit wallpapers;
    selection = {
      provider = "catppuccin";
      variant = null;
      accent = null;
    };
  };
  unsupported = themeLib.resolveSelection {
    inherit providers wallpapers;
    selection = {
      provider = "catppuccin";
      variant = "latte";
      accent = "blue";
    };
  };
  invalid = builtins.tryEval (builtins.deepSeq (themeLib.validateRegistry {
      catppuccin = wallpapers.catppuccin // {default = "../outside.png";};
    })
    true);
in
  assert selected.provider == "catppuccin";
  assert selected.variant == "mocha";
  assert selected.accent == "blue";
  assert selected.roles.ui.background.withHashtag == "#000000";
  assert selected.base16.base00.withHashtag == "#1e1e2e";
  assert selected.wallpapers.default == "wallpapers/catppuccin/default.png";
  assert builtins.length selected.wallpapers.paths == 2;
  assert providerDefault.variant == providers.catppuccin.defaults.variant;
  assert providerDefault.accent == providers.catppuccin.defaults.accent;
  assert unsupported.wallpapers == null;
  assert !invalid.success; true
