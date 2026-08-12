{
  lib,
  pkgs,
  providers,
  adapters,
  themeLib,
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
        cursor = lib.mkOption {
          type = lib.types.nullOr lib.types.attrs;
          default = null;
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
  inputs = {
    theme-broker = {
      homeModules.default = {};
      lib = themeLib;
    };
  };
  eval = path: let
    example = import path {inherit inputs lib;};
    result = lib.evalModules {
      specialArgs = {
        inherit pkgs;
        themeBrokerPlatform = "homeManager";
        themeBrokerProviders = providers;
        themeBrokerAdapters = adapters;
      };
      modules = [
        base
        {
          imports = [../../modules/home-manager.nix];
          _module.args = {
            themeBrokerProviders = providers;
            themeBrokerAdapters = adapters;
          };
        }
        example
      ];
    };
  in {
    inherit path;
    enabled = result.config.themeBroker.enable;
  };
in
  assert builtins.all (row: row.enabled) (map eval [
    ../../examples/catppuccin-home-manager/default.nix
    ../../examples/gruvbox-home-manager/default.nix
    ../../examples/mixed-native-generated/default.nix
    ../../examples/custom-provider/default.nix
  ]); true
