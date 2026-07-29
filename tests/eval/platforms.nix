{
  lib,
  pkgs,
  providers,
  adapters,
}: let
  targetNames = ["alacritty" "bat" "console" "foot" "kitty" "waybar" "neovim" "vim"];
  base = {
    options = {
      stylix = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        base16Scheme = lib.mkOption {
          type = lib.types.attrs;
          default = {};
        };
        targets = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule ({...}: {
            options.enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          }));
          default = lib.genAttrs targetNames (_: {});
        };
      };
      catppuccin = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };
      programs = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
      };
      assertions = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [];
      };
    };
  };
  platformFiles = {
    homeManager = ../../modules/home-manager.nix;
    nixos = ../../modules/nixos.nix;
    darwin = ../../modules/darwin.nix;
  };
  eval = platform:
    lib.evalModules {
      specialArgs = {inherit pkgs;};
      modules = [
        base
        {
          imports = [platformFiles.${platform}];
          _module.args = {
            themeBrokerProviders = providers;
            themeBrokerAdapters = adapters;
            themeBrokerPlatform = platform;
          };
        }
        {
          themeBroker = {
            enable = true;
            selection.provider = "gruvbox";
            selection.variant = "dark-hard";
            targets.alacritty.backend = "generated";
          };
        }
      ];
    };
  platforms = map (platform: let
    result = eval platform;
  in {
    inherit platform;
    selected = result.config.themeBroker.selected.provider;
    backend = result.config.themeBroker.resolved.targets.alacritty.backend;
  }) ["homeManager" "nixos" "darwin"];
in
  assert builtins.all (row: row.selected == "gruvbox" && row.backend == "generated") platforms; true
