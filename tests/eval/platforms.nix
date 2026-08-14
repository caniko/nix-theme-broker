{
  lib,
  pkgs,
  providers,
  adapters,
}: let
  themeLib = import ../../lib {inherit lib;};
  targetNames = ["alacritty" "bat" "btop" "chromium" "console" "foot" "ghostty" "helix" "kitty" "mpv" "nushell" "obsidian" "opencode" "starship" "tmux" "waybar" "zed" "zellij"];
  selections = [
    {
      provider = "catppuccin";
      variant = "mocha";
      accent = "mauve";
      base00 = "#1e1e2e";
    }
    {
      provider = "catppuccin";
      variant = "latte";
      accent = "blue";
      base00 = "#eff1f5";
    }
    {
      provider = "gruvbox";
      variant = "dark-hard";
      accent = null;
      base00 = "#1d2021";
    }
    {
      provider = "gruvbox";
      variant = "light-hard";
      accent = null;
      base00 = "#f9f5d7";
    }
    {
      provider = "rose-pine";
      variant = "moon";
      accent = "iris";
      base00 = "#232136";
    }
  ];
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
      environment.systemPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
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
  platformTargets = platform:
    builtins.filter (
      target: builtins.elem platform themeLib.generatedTargets.${target}.platforms
    )
    targetNames;
  eval = platform: selection:
    lib.evalModules {
      specialArgs = {
        cosmicLib = null;
        inherit pkgs;
        themeBrokerPlatform = platform;
        themeBrokerProviders = providers;
        themeBrokerAdapters = adapters;
      };
      modules = [
        base
        {
          imports = [platformFiles.${platform}];
          _module.args = {
            themeBrokerProviders = providers;
            themeBrokerAdapters = adapters;
          };
        }
        {
          themeBroker = {
            enable = true;
            selection = {
              inherit (selection) provider variant accent;
            };
            targets = lib.genAttrs (platformTargets platform) (_: {
              backend = "generated";
            });
          };
        }
      ];
    };
  platforms = ["homeManager" "nixos" "darwin"];
  cases =
    lib.concatMap (
      platform:
        map (selection: let
          result = eval platform selection;
          configTargets = platformTargets platform;
        in {
          inherit platform;
          selected = result.config.themeBroker.selected.provider;
          variant = result.config.themeBroker.selected.variant;
          base00 = result.config.stylix.base16Scheme.base00;
          backends = map (target: result.config.themeBroker.resolved.targets.${target}.backend) configTargets;
          adapters = map (target: result.config.themeBroker.resolved.targets.${target}.adapter) configTargets;
          generatedEnabled = map (target: result.config.stylix.targets.${target}.enable) configTargets;
          inherit selection;
        })
        selections
    )
    platforms;
in
  assert builtins.all (
    row:
      row.selected
      == row.selection.provider
      && row.variant == row.selection.variant
      && row.base00 == row.selection.base00
      && builtins.all (backend: backend == "generated") row.backends
      && builtins.all (adapter: adapter == null) row.adapters
      && builtins.all (enabled: enabled) row.generatedEnabled
  )
  cases; true
