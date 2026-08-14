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
  eval = path: extra: let
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
        extra
      ];
    };
  in {
    inherit path;
    inherit (result) config;
    enabled = result.config.themeBroker.enable;
  };
  rosePineGenerated = eval ../../examples/catppuccin-home-manager/default.nix {
    themeBroker.selection = {
      provider = lib.mkForce "rose-pine";
      variant = lib.mkForce "moon";
      accent = lib.mkForce "iris";
    };
    themeBroker.targets.alacritty.backend = lib.mkForce "generated";
  };
in
  assert builtins.all (row: row.enabled) (map (path: eval path {}) [
    ../../examples/catppuccin-home-manager/default.nix
    ../../examples/gruvbox-home-manager/default.nix
    ../../examples/mixed-native-generated/default.nix
    ../../examples/custom-provider/default.nix
  ]);
  assert rosePineGenerated.config.themeBroker.selected.provider == "rose-pine";
  assert rosePineGenerated.config.themeBroker.resolved.targets.alacritty.backend == "generated";
  assert rosePineGenerated.config.stylix.targets.alacritty.enable; true
