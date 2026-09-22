{
  pkgs,
  homeManager,
  stylix,
  catppuccin,
  providers,
  adapters,
}: let
  lib = pkgs.lib;
  home = homeManager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      (homeManager.outPath + "/modules/programs/kitty.nix")
      (homeManager.outPath + "/modules/programs/helix.nix")
      stylix.homeModules.stylix
      catppuccin.homeModules.default
      (import ../../modules/home-manager.nix {
        themeBrokerProviders = providers;
        themeBrokerBuiltinAdapters = adapters;
        themeBrokerAdapters = [];
      })
      {
        home = {
          username = "theme-broker-test";
          homeDirectory = "/home/theme-broker-test";
          stateVersion = "26.05";
        };
        themeBroker = {
          enable = true;
          selection = {
            provider = "blackbox";
            variant = "dark";
            accent = null;
          };
          # kitty (terminal) and helix (editor) both resolve through the
          # Stylix generated path: Blackbox registers no native adapters.
          targets = {
            kitty.backend = "generated";
            helix.backend = "generated";
          };
        };
        programs.kitty.enable = true;
        programs.helix.enable = true;
      }
    ];
  };
  cfg = home.config;
  includeLines = builtins.filter (line: lib.hasPrefix "include /nix/store/" line) (
    lib.splitString "\n" cfg.programs.kitty.extraConfig
  );
in {
  inherit home;
  # Store paths of the generated per-target theme files; the checks build and
  # inspect their contents rather than only the normalized palette.
  kittyTheme = lib.removePrefix "include " (builtins.head includeLines);
  helixTheme = toString cfg.programs.helix.themes.stylix;
}
