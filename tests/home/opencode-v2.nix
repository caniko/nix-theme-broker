{
  pkgs,
  homeManager,
  stylix,
  catppuccin,
  providers,
  adapters,
}: let
  inherit (pkgs) lib;
  modules = [
    stylix.homeModules.stylix
    catppuccin.homeModules.default
    (import ../../modules/home-manager.nix {
      themeBrokerProviders = providers;
      themeBrokerBuiltinAdapters = adapters;
    })
    {
      home = {
        username = "theme-broker-test";
        homeDirectory = "/home/theme-broker-test";
        stateVersion = "26.05";
      };
      xdg.configHome = "/home/theme-broker-test/custom-config";
      stylix.enable = false;
      programs.opencode = {
        enable = true;
        package = null;
        settings.model = "example/model";
      };
    }
  ];
  eval = extra:
    (homeManager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = modules ++ [extra];
    }).config;
  selections = [
    {
      provider = "blackbox";
      variant = "dark";
    }
    {
      provider = "gruvbox";
      variant = "dark-hard";
    }
    {
      provider = "gruvbox";
      variant = "light-hard";
    }
    {
      provider = "catppuccin";
      variant = "mocha";
      accent = "blue";
    }
    {
      provider = "catppuccin";
      variant = "latte";
      accent = "mauve";
    }
    {
      provider = "rose-pine";
      variant = "dawn";
      accent = "iris";
    }
  ];
  check = selection: let
    cfg = eval {
      themeBroker = {
        enable = true;
        inherit selection;
        targets.opencode.backend = "auto";
        opencode.cliSettings = {
          tabs.mode = "off";
          keybinds."app.exit" = ["ctrl+c" "ctrl+d"];
          theme.mode = "system";
        };
      };
      catppuccin.opencode.enable = true;
    };
    cli = builtins.fromJSON cfg.xdg.configFile."opencode/cli.json".text;
    themeFile = cfg.xdg.configFile."opencode/themes/theme-broker.json";
    theme = builtins.fromJSON themeFile.text;
    mode = cfg.themeBroker.selected.metadata.appearance;
  in
    cfg.themeBroker.resolved.targets.opencode.backend
    == "generated"
    && cfg.themeBroker.resolved.targets.opencode.engine == "opencode-v2"
    && cfg.themeBroker.resolved.targets.opencode.adapter == null
    && !cfg.stylix.targets.opencode.enable
    && !cfg.catppuccin.opencode.enable
    && !(cfg.xdg.configFile ? "opencode/tui.json")
    && cfg.programs.opencode.settings.model == "example/model"
    && cli."$schema" == "https://opencode.ai/v2/cli.json"
    && cli.theme
    == {
      name = "theme-broker";
      mode = "system";
    }
    && cli.tabs.mode == "off"
    && cli.keybinds."app.exit" == ["ctrl+c" "ctrl+d"]
    && "${cfg.home.homeDirectory}/${themeFile.target}" == "${cfg.xdg.configHome}/opencode/themes/theme-broker.json"
    && theme.base.background.base == cfg.themeBroker.selected.roles.ui.background.withHashtag
    && theme.${mode}.hue.accent."200" == cfg.themeBroker.selected.roles.ui.accent.withHashtag
    && builtins.all (assertion: assertion.assertion) cfg.assertions;
  unmanaged = eval {
    themeBroker = {
      enable = true;
      selection.provider = "blackbox";
      targets.opencode.managed = false;
    };
  };
  disabled = eval {};
  defaults = eval {
    themeBroker = {
      enable = true;
      selection = {
        provider = "catppuccin";
        variant = "latte";
      };
      targets.opencode.backend = "generated";
    };
  };
  native = eval {
    themeBroker = {
      enable = true;
      selection.provider = "catppuccin";
      targets.opencode.backend = "native";
    };
  };
in
  assert builtins.all check selections;
  assert !(unmanaged.xdg.configFile ? "opencode/cli.json");
  assert !(unmanaged.xdg.configFile ? "opencode/themes/theme-broker.json");
  assert !(disabled.xdg.configFile ? "opencode/cli.json");
  assert !(disabled.xdg.configFile ? "opencode/themes/theme-broker.json");
  assert (builtins.fromJSON defaults.xdg.configFile."opencode/cli.json".text).theme
  == {
    name = "theme-broker";
    mode = "light";
  };
  assert !(builtins.tryEval native.themeBroker.resolved.targets.opencode.backend).success; true
