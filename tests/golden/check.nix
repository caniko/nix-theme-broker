{
  lib,
  providers,
}: let
  themeLib = import ../../lib {inherit lib;};
  check = file: selection: let
    expected = builtins.fromJSON (builtins.readFile file);
    actual = themeLib.resolveSelection {inherit providers selection;};
    base16Checks = lib.mapAttrsToList (name: value: actual.base16.${name}.withHashtag == value) expected.base16;
  in
    expected.source.repository
    == "https://github.com/tinted-theming/schemes"
    && expected.source.revision == "9bd28ed313560db3c5b605c63bc4e309e78e3fc8"
    && actual.provider == expected.provider
    && actual.variant == expected.variant
    && actual.accent == expected.accent
    && actual.roles.ui.background.withHashtag == expected.background
    && (
      if expected ? accentColor
      then actual.roles.ui.accent.withHashtag == expected.accentColor
      else true
    )
    && builtins.all (value: value) base16Checks;
in
  builtins.all (value: value) [
    (check ./catppuccin-latte-blue.json {
      provider = "catppuccin";
      variant = "latte";
      accent = "blue";
    })
    (check ./catppuccin-mocha-mauve.json {
      provider = "catppuccin";
      variant = "mocha";
      accent = "mauve";
    })
    (check ./gruvbox-dark-medium.json {
      provider = "gruvbox";
      variant = "dark-medium";
      accent = null;
    })
    (check ./gruvbox-light-hard.json {
      provider = "gruvbox";
      variant = "light-hard";
      accent = null;
    })
    (check ./rose-pine-main-rose.json {
      provider = "rose-pine";
      variant = "main";
      accent = "rose";
    })
    (check ./rose-pine-moon-iris.json {
      provider = "rose-pine";
      variant = "moon";
      accent = "iris";
    })
    (check ./rose-pine-dawn-pine.json {
      provider = "rose-pine";
      variant = "dawn";
      accent = "pine";
    })
  ]
