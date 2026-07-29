{
  config,
  lib,
  options,
  pkgs,
  cosmicLib ? null,
  themeBrokerAdapters ? [],
  themeBrokerPlatform ? "homeManager",
  themeBrokerProviders,
  ...
}: let
  # Read only input options here.  `config.themeBroker` also contains the
  # read-only `selected`/`resolved` outputs defined below; forcing that whole
  # attrset while computing those outputs creates an evaluation cycle.
  brokerEnabled = config.themeBroker.enable;
  themeLib = import ../lib {inherit lib;};
  registryCfg = {
    providers = config.themeBroker.registry.providers;
    adapters = map themeLib.mkAdapter config.themeBroker.registry.adapters;
  };
  selectionCfg = {
    provider = config.themeBroker.selection.provider;
    variant = config.themeBroker.selection.variant;
    accent = config.themeBroker.selection.accent;
    overrides = config.themeBroker.selection.overrides;
  };
  policyCfg = {
    defaultBackend = config.themeBroker.policy.defaultBackend;
    allowedNativeTiers = config.themeBroker.policy.allowedNativeTiers;
    requireAccentFidelity = config.themeBroker.policy.requireAccentFidelity;
    requireOverrideFidelity = config.themeBroker.policy.requireOverrideFidelity;
    onUnsupported = config.themeBroker.policy.onUnsupported;
    preferNative = config.themeBroker.policy.preferNative;
  };
  targetsCfg = lib.filterAttrs (_: targetCfg: targetCfg.managed) config.themeBroker.targets;
  # Stylix owns target implementations; this registry only records the
  # stable IDs the broker may coordinate without copying those implementations.
  generatedRegistry = themeLib.generatedTargets;
  generatedTargets = builtins.attrNames generatedRegistry;
  cosmicAvailable =
    lib.hasAttrByPath ["wayland" "desktopManager" "cosmic" "appearance"] options
    && cosmicLib != null;
  complexRendererIds = ["catppuccin-vscode" "gruvbox-neovim" "gruvbox-vim" "gruvbox-vscode"];
  declaredAdapters = map themeLib.mkAdapter themeBrokerAdapters;
  declaredAdaptersById = lib.listToAttrs (map (adapter: {
      name = adapter.id;
      value = adapter;
    })
    declaredAdapters);
  hasRenderer = adapter: let
    declared = declaredAdaptersById.${adapter.id} or null;
  in
    declared
    != null
    && adapter == declared
    && (
      ((adapter.class or "simple") == "simple" && builtins.isList (adapter.optionPath or null))
      || builtins.elem adapter.id complexRendererIds
    );
  renderableAdapters = builtins.filter hasRenderer registryCfg.adapters;
  generatedConfigTargets =
    builtins.filter (
      target:
        (generatedRegistry.${target}.engine or "stylix")
        == "stylix"
        && builtins.elem themeBrokerPlatform (generatedRegistry.${target}.platforms or [])
    )
    generatedTargets;
  manageStylixScheme = config.themeBroker.manageStylixScheme;
  selected = themeLib.resolveSelection {
    providers = registryCfg.providers;
    selection = selectionCfg;
  };
  targetSelections =
    lib.mapAttrs (
      target: targetCfg: (
        themeLib.resolveBackend {
          providerId = selected.provider;
          variantId = selected.variant;
          selection =
            selectionCfg
            // {
              accent = selected.accent;
              backend =
                if targetCfg.backend == "auto"
                then policyCfg.defaultBackend
                else targetCfg.backend;
              nativeOptions = targetCfg.nativeOptions;
            };
          targetId = target;
          platform = themeBrokerPlatform;
          generatedAvailable =
            builtins.elem target generatedTargets
            && builtins.elem themeBrokerPlatform (generatedRegistry.${target}.platforms or [])
            && (
              (generatedRegistry.${target}.engine or "stylix")
              != "cosmic-manager"
              || (
                if cosmicLib == null
                then throw "themeBroker: COSMIC generated target requires cosmicLib"
                else if !cosmicAvailable
                then throw "themeBroker: COSMIC generated target requires cosmic-manager options"
                else if selected.metadata.appearance != "dark"
                then throw "themeBroker: COSMIC generated target supports dark variants only"
                else true
              )
            );
          adapters = renderableAdapters;
          policy = policyCfg;
        }
        // {nativeOptions = targetCfg.nativeOptions;}
      )
    )
    targetsCfg;
  adaptersById = lib.listToAttrs (map (adapter: {
      name = adapter.id;
      value = adapter;
    })
    registryCfg.adapters);
  simpleNativeConfig =
    map (
      adapter:
        if (adapter.class or "simple") != "simple"
        then {}
        else
          lib.setAttrByPath adapter.optionPath (
            lib.mkIf (
              targetSelections ? ${adapter.target}
              && targetSelections.${adapter.target}.backend == "native"
              && targetSelections.${adapter.target}.adapter == adapter.id
            ) ({enable = true;} // (adapter.optionValues or {}))
          )
    )
    (builtins.filter (
        adapter:
          (adapter.class or "simple")
          == "simple"
          && builtins.elem themeBrokerPlatform (adapter.platforms or [])
          && builtins.isList (adapter.optionPath or null)
      )
      declaredAdapters);
  catppuccinNative = builtins.any (
    targetCfg: let
      adapter =
        if targetCfg.adapter == null
        then {}
        else adaptersById.${targetCfg.adapter} or {};
    in
      (adapter.module or null) == "catppuccin"
  ) (builtins.attrValues targetSelections);
  nativeConfig =
    [
      (lib.mkIf catppuccinNative {
        catppuccin = {
          enable = true;
          autoEnable = lib.mkForce false;
          flavor = selected.variant;
          accent = selected.accent;
        };
      })
    ]
    ++ simpleNativeConfig
    ++ lib.optional (themeBrokerPlatform == "homeManager") (lib.mkMerge [
      (lib.mkIf (
          targetSelections ? neovim
          && targetSelections.neovim.backend == "native"
          && targetSelections.neovim.adapter == "gruvbox-neovim"
        ) (import ../native/gruvbox/neovim.nix {
          inherit lib pkgs selected;
          transparent = config.themeBroker.targets.neovim.nativeOptions.transparent or false;
        }))
      (lib.mkIf (
        targetSelections ? vim
        && targetSelections.vim.backend == "native"
        && targetSelections.vim.adapter == "gruvbox-vim"
      ) (import ../native/gruvbox/vim.nix {inherit lib pkgs selected;}))
    ])
    ++ lib.optional (themeBrokerPlatform == "homeManager") (lib.mkMerge [
      (lib.mkIf (
        targetSelections ? vscode
        && targetSelections.vscode.backend == "native"
        && targetSelections.vscode.adapter == "gruvbox-vscode"
      ) (import ../native/gruvbox/vscode.nix {inherit lib pkgs selected;}))
      (lib.mkIf (
        targetSelections ? vscode
        && targetSelections.vscode.backend == "native"
        && targetSelections.vscode.adapter == "catppuccin-vscode"
      ) (import ../native/catppuccin/home-manager/vscode.nix {inherit lib pkgs selected;}))
    ]);
  generatedConfig = targets:
    lib.map (target: {
      stylix.targets.${target}.enable = lib.mkIf (
        targetSelections ? ${target}
        && targetSelections.${target}.backend == "generated"
        && builtins.elem themeBrokerPlatform (generatedRegistry.${target}.platforms or [])
      ) (lib.mkForce true);
    })
    targets;
  disabledGeneratedConfig = targets:
    lib.map (target: {
      stylix.targets.${target}.enable = lib.mkIf (
        targetSelections ? ${target}
        && targetSelections.${target}.backend == "native"
        && builtins.elem themeBrokerPlatform (generatedRegistry.${target}.platforms or [])
      ) (lib.mkForce false);
    })
    targets;
  cosmicConfig =
    if themeBrokerPlatform == "homeManager" && cosmicAvailable
    then
      import ../targets/cosmic-manager.nix {
        inherit cosmicLib lib selected;
        enabled = targetSelections ? cosmic && targetSelections.cosmic.backend == "generated";
      }
    else {};
  ghosttyConfig =
    if themeBrokerPlatform == "homeManager"
    then {
      programs.ghostty.settings.window-theme = lib.mkIf (
        targetSelections ? ghostty && targetSelections.ghostty.backend == "generated"
      ) "ghostty";
    }
    else {};
in {
  options.themeBroker = {
    enable = lib.mkEnableOption "theme broker";

    platform = lib.mkOption {
      type = lib.types.enum ["homeManager" "nixos" "darwin"];
      default = "homeManager";
      internal = true;
    };

    registry = {
      providers = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = themeBrokerProviders;
        description = "Palette providers registered with the broker.";
      };
      adapters = lib.mkOption {
        type = lib.types.listOf lib.types.raw;
        default = map themeLib.mkAdapter themeBrokerAdapters;
        description = "Native target adapters registered with the broker.";
      };
    };

    selection = {
      provider = lib.mkOption {
        type = lib.types.str;
        default = "gruvbox";
        description = "Theme provider ID.";
      };
      variant = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Provider-defined variant ID; null uses the provider default.";
      };
      accent = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional provider accent.";
      };
      overrides = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Named, semantic-role, and projection overrides.";
      };
    };

    manageStylixScheme = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether the broker owns the Stylix Base16 scheme.";
    };

    policy = {
      defaultBackend = lib.mkOption {
        type = lib.types.enum ["auto" "generated" "native"];
        default = "auto";
        description = "Backend used when a target requests auto.";
      };
      allowedNativeTiers = lib.mkOption {
        type = lib.types.listOf (lib.types.enum ["official" "canonical" "maintained" "community" "local"]);
        default = ["official" "canonical" "maintained" "local"];
        description = "Native artifact trust tiers accepted by the resolver.";
      };
      requireAccentFidelity = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Require native adapters to preserve the selected accent.";
      };
      requireOverrideFidelity = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Require native adapters to preserve requested color overrides.";
      };
      onUnsupported = lib.mkOption {
        type = lib.types.enum ["fallback" "warn" "error"];
        default = "fallback";
        description = "Action when a requested native capability is unsupported.";
      };
      preferNative = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Prefer an accepted native adapter over a generated target.";
      };
    };

    targets = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({...}: {
        options = {
          backend = lib.mkOption {
            type = lib.types.enum ["auto" "generated" "native"];
            default = "auto";
            description = "Requested backend for this managed target.";
          };
          managed = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether the broker owns this target's backend switches.";
          };
          nativeOptions = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = "Validated adapter-specific options for this target.";
          };
        };
      }));
      default = {};
      description = "Targets whose generated/native backend is coordinated.";
    };

    selected = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      readOnly = true;
      description = "Resolved normalized theme.";
    };
    resolved = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      readOnly = true;
      description = "Read-only backend resolution records.";
    };
    generatedTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      description = "Stylix generated target IDs in the pinned compatibility registry.";
    };
  };

  config = lib.mkIf brokerEnabled (lib.mkMerge (
    [
      {
        themeBroker.selected = selected;
        themeBroker.resolved = targetSelections // {targets = targetSelections;};
        themeBroker.generatedTargets = generatedTargets;
        stylix.enable = lib.mkDefault true;
        stylix.base16Scheme = lib.mkIf manageStylixScheme (lib.mkDefault selected.formatted.base16Scheme);
        catppuccin.autoEnable = lib.mkForce false;
        assertions = lib.mkIf manageStylixScheme [
          {
            assertion = config.stylix.base16Scheme == selected.formatted.base16Scheme;
            message = "themeBroker: stylix.base16Scheme conflicts with the broker selection; remove the direct scheme or set themeBroker.manageStylixScheme = false.";
          }
        ];
      }
    ]
    ++ generatedConfig generatedConfigTargets
    ++ disabledGeneratedConfig generatedConfigTargets
    ++ nativeConfig
    ++ [cosmicConfig ghosttyConfig]
  ));
}
