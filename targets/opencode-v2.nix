{
  config,
  lib,
  selected,
  enabled ? true,
  managed ? enabled,
}: let
  render = import ../lib/renderers/opencode-v2.nix {inherit lib;};
in
  lib.mkMerge [
    (lib.mkIf managed {
      # Neither pinned upstream writer understands the v2 format. Also keep
      # them off when a consumer selects its own compatible native adapter.
      stylix.targets.opencode.enable = lib.mkForce false;
      catppuccin.opencode.enable = lib.mkForce false;
    })
    (lib.mkIf enabled {
      themeBroker.opencode.cliSettings = {
        "$schema" = lib.mkDefault "https://opencode.ai/v2/cli.json";
        theme = {
          name = lib.mkDefault "theme-broker";
          mode = lib.mkDefault selected.metadata.appearance;
        };
      };
      xdg.configFile = {
        "opencode/cli.json".text = builtins.toJSON config.themeBroker.opencode.cliSettings;
        "opencode/themes/theme-broker.json".text = builtins.toJSON (render selected);
      };
    })
  ]
