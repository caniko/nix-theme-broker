{
  lib,
  providers,
}: let
  themeLib = import ../../lib {inherit lib;};
  selected = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "catppuccin";
      variant = "mocha";
      accent = "blue";
      overrides.roles.ui.background = "#000000";
    };
  };
  providerDefault = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "catppuccin";
      variant = null;
      accent = null;
    };
  };
in
  assert selected.provider == "catppuccin";
  assert selected.variant == "mocha";
  assert selected.accent == "blue";
  assert selected.roles.ui.background.withHashtag == "#000000";
  assert selected.base16.base00.withHashtag == "#1e1e2e";
  assert providerDefault.variant == providers.catppuccin.defaults.variant;
  assert providerDefault.accent == providers.catppuccin.defaults.accent; true
