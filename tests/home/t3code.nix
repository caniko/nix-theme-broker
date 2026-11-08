{
  pkgs,
  homeManager,
  stylix,
  catppuccin,
  providers,
  adapters,
}: let
  inherit (pkgs) lib;
  # nix-t3code owns these options; the stub keeps the test independent of that
  # flake input while matching its declared surface.
  t3codeStub = {...}: {
    options.programs.t3code = {
      themes = lib.mkOption {
        type = lib.types.attrsOf (pkgs.formats.json {}).type;
        default = {};
      };
      defaultTheme = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };
  baseModules = [
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
      stylix.enable = false;
    }
  ];
  evalWith = extraModules: extra:
    (homeManager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = extraModules ++ [extra];
    }).config;
  eval = evalWith (baseModules ++ [t3codeStub]);
  # T3 Code's EnvironmentThemeFile role names; only these may be emitted.
  roles = [
    "canvas"
    "chrome"
    "surface"
    "surfaceRaised"
    "surfaceOverlay"
    "text"
    "textMuted"
    "border"
    "input"
    "focus"
    "accent"
    "accentForeground"
    "muted"
    "mutedForeground"
    "error"
    "errorForeground"
    "warning"
    "warningForeground"
    "codeBackground"
    "codeForeground"
    "sidebar"
    "sidebarForeground"
    "sidebarBorder"
    "terminalBackground"
    "terminalForeground"
    "terminalCursor"
    "terminalSelection"
  ];
  selections = [
    {
      selection = {
        provider = "blackbox";
        variant = "dark";
      };
      appearance = "dark";
    }
    {
      selection = {
        provider = "blackbox";
        variant = "light";
      };
      appearance = "light";
    }
    {
      selection = {
        provider = "gruvbox";
        variant = "dark-hard";
      };
      appearance = "dark";
    }
    {
      selection = {
        provider = "gruvbox";
        variant = "light-hard";
      };
      appearance = "light";
    }
    {
      selection = {
        provider = "catppuccin";
        variant = "mocha";
        accent = "mauve";
      };
      appearance = "dark";
    }
    {
      selection = {
        provider = "catppuccin";
        variant = "latte";
        accent = "blue";
      };
      appearance = "light";
    }
  ];
  check = {
    selection,
    appearance,
  }: let
    cfg = eval {
      themeBroker = {
        enable = true;
        inherit selection;
        targets.t3code.backend = "auto";
      };
    };
    theme = cfg.programs.t3code.themes.theme-broker;
    validColor = value: builtins.match "#[0-9a-f]{6}" value != null;
  in
    cfg.themeBroker.resolved.targets.t3code.backend
    == "generated"
    && cfg.themeBroker.resolved.targets.t3code.engine == "t3code"
    && cfg.themeBroker.resolved.targets.t3code.reasons != []
    && cfg.programs.t3code.themes ? theme-broker
    && cfg.programs.t3code.defaultTheme == "theme-broker"
    && theme.version == 1
    && builtins.isString theme.name
    && theme.name == lib.trim theme.name
    && theme.name != ""
    && builtins.stringLength theme.name <= 48
    && theme.appearance == appearance
    && theme.appearance == cfg.themeBroker.selected.metadata.appearance
    && validColor theme.canvas
    && validColor theme.accent
    && theme.canvas == cfg.themeBroker.selected.roles.ui.background.withHashtag
    && theme.accent == cfg.themeBroker.selected.roles.ui.accent.withHashtag
    && builtins.all (role: builtins.elem role roles) (builtins.attrNames theme.colors)
    && builtins.all (value: builtins.isString value && builtins.stringLength value <= 64 && validColor value) (builtins.attrValues theme.colors)
    && builtins.all (assertion: assertion.assertion) cfg.assertions;
  override = eval {
    themeBroker = {
      enable = true;
      selection.provider = "blackbox";
      targets.t3code.backend = "generated";
    };
    programs.t3code.defaultTheme = "custom";
  };
  unmanaged = eval {
    themeBroker = {
      enable = true;
      selection.provider = "blackbox";
      targets.t3code.managed = false;
    };
  };
  disabled = eval {};
  missing = evalWith baseModules {
    themeBroker = {
      enable = true;
      selection.provider = "blackbox";
      targets.t3code.backend = "generated";
    };
  };
  # Home Manager throws on failed assertions, so read the message from the target itself.
  missingTarget = import ../../targets/t3code.nix {
    inherit lib;
    options = {};
    selected = null;
  };
  missingMessage = "themeBroker.targets.t3code requires the nix-t3code Home Manager module (programs.t3code.themes)";
in
  assert builtins.all check selections;
  assert override.programs.t3code.defaultTheme == "custom";
  assert !(unmanaged.themeBroker.resolved.targets ? t3code);
  assert !(unmanaged.programs.t3code.themes ? theme-broker) && unmanaged.programs.t3code.defaultTheme == null;
  assert !(disabled.programs.t3code.themes ? theme-broker) && disabled.programs.t3code.defaultTheme == null;
  assert !(builtins.tryEval missing).success;
  assert (builtins.head missingTarget.contents).content.assertions
  == [
    {
      assertion = false;
      message = missingMessage;
    }
  ];
  assert builtins.elemAt missingTarget.contents 1 == {}; true
