{
  lib,
  options,
  selected,
  enabled ? true,
  ...
}: let
  render = import ../lib/renderers/t3code.nix {inherit lib;};
  # nix-t3code declares the theme options. Guard every definition on them:
  # definitions of undeclared options fail even under `mkIf false`.
  hasT3Code =
    lib.hasAttrByPath ["programs" "t3code" "themes"] options
    && lib.hasAttrByPath ["programs" "t3code" "defaultTheme"] options;
in
  lib.mkMerge [
    (lib.mkIf (enabled && !hasT3Code) {
      assertions = [
        {
          assertion = false;
          message = "themeBroker.targets.t3code requires the nix-t3code Home Manager module (programs.t3code.themes)";
        }
      ];
    })
    (lib.optionalAttrs hasT3Code {
      programs.t3code.themes = lib.mkIf enabled {theme-broker = render selected;};
      programs.t3code.defaultTheme = lib.mkIf enabled (lib.mkDefault "theme-broker");
    })
  ]
