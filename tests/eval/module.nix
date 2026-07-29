{
  lib,
  pkgs,
  providers,
  adapters,
}: let
  targetNames = ["alacritty" "bat" "console" "foot" "kitty" "waybar" "neovim" "vim" "vscode"];
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
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf lib.types.anything;
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            autoEnable = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
            flavor = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
            accent = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
            alacritty = lib.mkOption {
              type = lib.types.attrs;
              default = {};
            };
            firefox = lib.mkOption {
              type = lib.types.attrs;
              default = {};
            };
            vscode = lib.mkOption {
              type = lib.types.attrs;
              default = {};
            };
            gtk = lib.mkOption {
              type = lib.types.attrs;
              default = {};
            };
            cursors = lib.mkOption {
              type = lib.types.attrs;
              default = {};
            };
          };
        };
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
  broker = {
    imports = [../../modules/common.nix];
    _module.args = {
      themeBrokerProviders = providers;
      themeBrokerAdapters = adapters;
      themeBrokerPlatform = "homeManager";
    };
  };
  eval = extra:
    lib.evalModules {
      specialArgs = {inherit pkgs;};
      modules = [base broker {config = extra;}];
    };
  disabled = eval {};
  generated = eval {
    themeBroker.enable = true;
    themeBroker.selection.provider = "gruvbox";
    themeBroker.selection.variant = "dark-hard";
    themeBroker.targets.alacritty.backend = "generated";
  };
  native = eval {
    themeBroker.enable = true;
    themeBroker.selection.provider = "gruvbox";
    themeBroker.selection.variant = "dark-medium";
    themeBroker.targets.neovim.backend = "native";
    themeBroker.targets.vim.backend = "native";
  };
  vscodeThemeNames = {
    "dark-hard" = "Gruvbox Dark Hard";
    "dark-medium" = "Gruvbox Dark Medium";
    "dark-soft" = "Gruvbox Dark Soft";
    "light-hard" = "Gruvbox Light Hard";
    "light-medium" = "Gruvbox Light Medium";
    "light-soft" = "Gruvbox Light Soft";
  };
  extensionIds = extensions: map (extension: extension.vscodeExtUniqueId or "") extensions;
  vscodeNative = eval {
    themeBroker.enable = true;
    themeBroker.selection.provider = "gruvbox";
    themeBroker.selection.variant = "dark-hard";
    themeBroker.targets.vscode.backend = "native";
  };
  vscodeVariants = map (variant: let
    result = eval {
      themeBroker.enable = true;
      themeBroker.selection.provider = "gruvbox";
      themeBroker.selection.variant = variant;
      themeBroker.targets.vscode.backend = "native";
    };
  in {
    inherit variant;
    settings = result.config.programs.vscode.profiles.default.userSettings;
  }) (builtins.attrNames vscodeThemeNames);
  nativeVariants = map (variant:
    eval {
      themeBroker.enable = true;
      themeBroker.selection.provider = "gruvbox";
      themeBroker.selection.variant = variant;
      themeBroker.targets.neovim.backend = "native";
      themeBroker.targets.vim.backend = "native";
    }) [
    "dark-hard"
    "dark-medium"
    "dark-soft"
    "light-hard"
    "light-medium"
    "light-soft"
  ];
  mixed = eval {
    themeBroker.enable = true;
    themeBroker.selection.provider = "gruvbox";
    themeBroker.selection.variant = "dark-medium";
    themeBroker.targets.neovim.backend = "native";
    themeBroker.targets.alacritty.backend = "generated";
  };
  unmanaged = eval {
    themeBroker.enable = true;
    themeBroker.targets.neovim.managed = false;
    stylix.targets.neovim.enable = true;
  };
  nativeOnly = eval {
    themeBroker.enable = true;
    themeBroker.manageStylixScheme = false;
    stylix.base16Scheme.base00 = "#000000";
  };
  catppuccinNative = eval {
    themeBroker.enable = true;
    themeBroker.selection = {
      provider = "catppuccin";
      variant = "mocha";
      accent = "mauve";
    };
    themeBroker.targets = {
      alacritty.backend = "native";
      firefox.backend = "native";
      vscode.backend = "native";
      gtk.backend = "native";
      cursors.backend = "native";
    };
  };
  assertions = result: builtins.all (item: item.assertion) result.config.assertions;
in
  assert disabled.config.themeBroker.selected == null;
  assert generated.config.themeBroker.selected.provider == "gruvbox";
  assert generated.config.stylix.targets.alacritty.enable;
  assert generated.config.themeBroker.generatedTargets != [];
  assert native.config.themeBroker.resolved.targets.neovim.backend == "native";
  assert native.config.themeBroker.resolved.targets.neovim.adapter == "gruvbox-neovim";
  assert lib.hasInfix "colorscheme(\"gruvbox\")" native.config.programs.neovim.extraLuaConfig;
  assert lib.hasInfix "colorscheme gruvbox" native.config.programs.vim.extraConfig;
  assert vscodeNative.config.themeBroker.resolved.targets.vscode.backend == "native";
  assert vscodeNative.config.themeBroker.resolved.targets.vscode.adapter == "gruvbox-vscode";
  assert vscodeNative.config.programs.vscode.profiles.default.userSettings."workbench.colorTheme" == "Gruvbox Dark Hard";
  assert vscodeNative.config.programs.vscode.profiles.default.userSettings."workbench.iconTheme" == "gruvbox-material-icons";
  assert builtins.elem "jdinhlife.gruvbox" (extensionIds vscodeNative.config.programs.vscode.profiles.default.extensions);
  assert builtins.elem "navernoedenis.gruvbox-material-icons" (extensionIds vscodeNative.config.programs.vscode.profiles.default.extensions);
  assert vscodeNative.config.stylix.targets.vscode.enable == false;
  assert builtins.all (
    row:
      row.settings."workbench.colorTheme" == vscodeThemeNames.${row.variant}
      && row.settings."workbench.iconTheme" == "gruvbox-material-icons"
  ) vscodeVariants;
  assert builtins.all (result: result.config.themeBroker.resolved.targets.neovim.backend == "native" && result.config.themeBroker.resolved.targets.vim.backend == "native") nativeVariants;
  assert mixed.config.themeBroker.resolved.targets.neovim.backend == "native";
  assert mixed.config.themeBroker.resolved.targets.alacritty.backend == "generated";
  assert mixed.config.stylix.targets.alacritty.enable;
  assert !(unmanaged.config.themeBroker.resolved.targets ? neovim);
  assert unmanaged.config.stylix.targets.neovim.enable;
  assert nativeOnly.config.stylix.base16Scheme.base00 == "#000000";
  assert assertions nativeOnly;
  assert catppuccinNative.config.catppuccin.enable;
  assert catppuccinNative.config.catppuccin.flavor == "mocha";
  assert catppuccinNative.config.catppuccin.accent == "mauve";
  assert catppuccinNative.config.catppuccin.alacritty.enable;
  assert catppuccinNative.config.themeBroker.resolved.targets.vscode.adapter == "catppuccin-vscode";
  assert catppuccinNative.config.programs.vscode.profiles.default.userSettings."workbench.colorTheme" == "Catppuccin Mocha";
  assert catppuccinNative.config.programs.vscode.profiles.default.userSettings."workbench.iconTheme" == "catppuccin-mocha";
  assert catppuccinNative.config.programs.vscode.profiles.default.userSettings."catppuccin.accentColor" == "mauve";
  assert builtins.elem "catppuccin.catppuccin-vsc" (extensionIds catppuccinNative.config.programs.vscode.profiles.default.extensions);
  assert builtins.elem "catppuccin.catppuccin-vsc-icons" (extensionIds catppuccinNative.config.programs.vscode.profiles.default.extensions);
  assert catppuccinNative.config.stylix.targets.vscode.enable == false;
  assert assertions generated;
  assert assertions native;
  assert !(
    builtins.tryEval (
      assert assertions (eval {
        themeBroker.enable = true;
        stylix.base16Scheme.base00 = "#000000";
      }); true
    )
  ).success; true
