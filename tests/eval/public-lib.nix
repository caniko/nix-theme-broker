{
  lib,
  providers,
}: let
  themeLib = import ../../lib {inherit lib;};
  selected = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "gruvbox";
      variant = "dark-hard";
      accent = null;
    };
  };
in
  assert builtins.isAttrs selected;
  assert builtins.isAttrs selected.formatted.base16Scheme;
  assert builtins.isAttrs themeLib.types;
  assert builtins.isAttrs themeLib.projection;
    builtins.toJSON selected != ""
