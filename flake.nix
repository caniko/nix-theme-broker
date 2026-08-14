{
  description = "Palette-neutral theme broker for Stylix and native adapters";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.tinted-schemes.follows = "tinted-schemes";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-palette = {
      url = "github:catppuccin/palette";
      flake = false;
    };
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    nixpkgs,
    stylix,
    catppuccin,
    catppuccin-palette,
    tinted-schemes,
    ...
  }: let
    lib = nixpkgs.lib;
    themeBrokerLib = import ./lib {inherit (nixpkgs) lib;};
    catppuccinProvider = import ./providers/catppuccin {
      inherit (nixpkgs) lib;
      palette = catppuccin-palette;
    };
    gruvbox = import ./providers/gruvbox {inherit (nixpkgs) lib;};
    rosePine = import ./providers/rose-pine {inherit (nixpkgs) lib;};
    providers = {
      catppuccin = catppuccinProvider;
      inherit gruvbox;
      rose-pine = rosePine;
    };
    catppuccinManifest = import ./native/catppuccin/manifest.nix;
    catppuccinAdapters = import ./native/catppuccin/default.nix {manifest = catppuccinManifest;};
    rawAdapters =
      catppuccinAdapters
      ++ [
        {
          schema = "theme-broker.adapter/v1";
          id = "gruvbox-vim";
          provider = "gruvbox";
          target = "vim";
          platforms = ["homeManager"];
          priority = 100;
          autoSafe = true;
          provenance = {
            tier = "canonical";
            repository = "https://github.com/morhetz/gruvbox";
            revision = "5d15b2765f59754d7ac263c88a0f6e3e58124951";
            license = "MIT";
          };
          capabilities = {
            variants = "all";
            accent = "none";
            namedOverrides = false;
            roleOverrides = false;
            transparency = false;
          };
          rendererKind = "gruvbox-vim";
        }
        {
          schema = "theme-broker.adapter/v1";
          id = "gruvbox-neovim";
          provider = "gruvbox";
          target = "neovim";
          platforms = ["homeManager"];
          priority = 100;
          autoSafe = true;
          provenance = {
            tier = "maintained";
            repository = "https://github.com/ellisonleao/gruvbox.nvim";
            revision = "154eb5ff5b96d0641307113fa385eaf0d36d9796";
            license = "MIT";
          };
          capabilities = {
            variants = "all";
            accent = "none";
            namedOverrides = false;
            roleOverrides = false;
            transparency = true;
          };
          rendererKind = "gruvbox-neovim";
        }
        {
          schema = "theme-broker.adapter/v1";
          id = "gruvbox-vscode";
          provider = "gruvbox";
          target = "vscode";
          platforms = ["homeManager"];
          priority = 100;
          autoSafe = false;
          provenance = {
            tier = "maintained";
            repository = "https://github.com/jdinhify/vscode-theme-gruvbox";
            revision = "ca3b8ad203e84a884ca33fb84b5795cf43032709";
            license = "MIT";
          };
          capabilities = {
            variants = "all";
            accent = "none";
            namedOverrides = false;
            roleOverrides = false;
            transparency = false;
          };
          rendererKind = "gruvbox-vscode";
        }
        {
          schema = "theme-broker.adapter/v1";
          id = "gruvbox-cursors";
          provider = "gruvbox";
          target = "cursors";
          platforms = ["homeManager" "nixos"];
          priority = 100;
          autoSafe = true;
          provenance = {
            tier = "maintained";
            repository = "https://github.com/ful1e5/Bibata_Cursor";
            revision = "v2.0.7";
            license = "GPL-3.0-only";
          };
          capabilities = {
            variants = "all";
            accent = "none";
            namedOverrides = false;
            roleOverrides = false;
            transparency = false;
          };
          class = "complex";
          rendererKind = "gruvbox-cursors";
        }
      ];
    adapters = map themeBrokerLib.mkAdapter rawAdapters;
    syntheticProvider = lib.recursiveUpdate gruvbox {
      id = "synthetic";
      name = "Synthetic";
      description = "First-slice resolver fixture";
      defaults.variant = "dark-hard";
      variants = {"dark-hard" = gruvbox.variants.dark-hard;};
    };
    syntheticAdapter = themeBrokerLib.mkAdapter {
      schema = "theme-broker.adapter/v1";
      id = "synthetic-alacritty";
      provider = "synthetic";
      target = "alacritty";
      platforms = ["homeManager"];
      priority = 1;
      autoSafe = true;
      provenance = {
        tier = "local";
        repository = "https://example.invalid/theme-broker-fixture";
        revision = "fixture";
        license = "MIT";
      };
      capabilities = {
        variants = "all";
        accent = "none";
        namedOverrides = false;
        roleOverrides = false;
        transparency = false;
      };
    };
    platformModules = {
      homeManager = ./modules/home-manager.nix;
      nixos = ./modules/nixos.nix;
      darwin = ./modules/darwin.nix;
    };
    brokerModule = platform: {
      imports = [
        (import platformModules.${platform} {
          themeBrokerProviders = providers;
          themeBrokerAdapters = adapters;
        })
      ];
    };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      # nixpkgs 26.11 dropped x86_64-darwin; keep the darwin module portable
      # while avoiding an impossible package-system evaluation at this pin.
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      flake = {
        lib = themeBrokerLib // {inherit providers adapters;};
        homeModules.default = {
          imports = [
            stylix.homeModules.stylix
            catppuccin.homeModules.default
            (brokerModule "homeManager")
          ];
        };
        nixosModules.default = {
          imports = [
            stylix.nixosModules.stylix
            catppuccin.nixosModules.default
            (brokerModule "nixos")
          ];
        };
        darwinModules.default = {
          imports = [
            stylix.darwinModules.stylix
            catppuccin.darwinModules.catppuccin
            (brokerModule "darwin")
          ];
        };
      };

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        darkHard = themeBrokerLib.resolveSelection {
          inherit providers;
          selection = {
            provider = "gruvbox";
            variant = "dark-hard";
            accent = null;
          };
        };
        lightHard = themeBrokerLib.resolveSelection {
          inherit providers;
          selection = {
            provider = "gruvbox";
            variant = "light-hard";
            accent = null;
          };
        };
        namedOverride = themeBrokerLib.resolveSelection {
          inherit providers;
          selection = {
            provider = "gruvbox";
            variant = "dark-hard";
            accent = null;
            overrides.named.background = "#000000";
          };
        };
        nativeResolution = themeBrokerLib.resolveBackend {
          providerId = "gruvbox";
          variantId = "dark-hard";
          selection = {
            backend = "auto";
            accent = null;
            overrides = {};
          };
          targetId = "neovim";
          platform = "homeManager";
          inherit adapters;
          policy = {
            allowedNativeTiers = ["official" "canonical" "maintained" "local"];
            requireAccentFidelity = false;
            requireOverrideFidelity = true;
            preferNative = true;
          };
        };
        syntheticGenerated = themeBrokerLib.resolveBackend {
          providerId = "synthetic";
          variantId = "dark-hard";
          selection = {
            backend = "generated";
            accent = null;
            overrides = {};
          };
          targetId = "alacritty";
          platform = "homeManager";
          adapters = [syntheticAdapter];
          policy = {
            allowedNativeTiers = ["local"];
            requireAccentFidelity = false;
            requireOverrideFidelity = true;
            preferNative = true;
          };
        };
        syntheticNative = themeBrokerLib.resolveBackend {
          providerId = "synthetic";
          variantId = "dark-hard";
          selection = {
            backend = "auto";
            accent = null;
            overrides = {};
          };
          targetId = "alacritty";
          platform = "homeManager";
          adapters = [syntheticAdapter];
          generatedAvailable = true;
          policy = {
            allowedNativeTiers = ["local"];
            requireAccentFidelity = false;
            requireOverrideFidelity = true;
            preferNative = true;
          };
        };
        evaluationTests = [
          (import ./tests/eval/color.nix {inherit lib;})
          (import ./tests/eval/selection.nix {inherit lib providers;})
          (import ./tests/eval/public-lib.nix {inherit lib providers;})
          (import ./tests/eval/adapter.nix {inherit lib;})
          (import ./tests/eval/generated-targets.nix {inherit lib;})
          (import ./tests/resolver/table.nix {inherit lib;})
          (import ./tests/eval/module.nix {inherit lib pkgs providers adapters;})
          (import ./tests/eval/platforms.nix {inherit lib pkgs providers adapters;})
          (import ./tests/eval/examples.nix {
            inherit lib pkgs providers adapters;
            themeLib = themeBrokerLib;
          })
          (import ./tests/eval/catppuccin-manifest.nix {inherit lib;})
          (import ./tests/golden/check.nix {inherit lib providers;})
        ];
        invalidProvider = builtins.tryEval (themeBrokerLib.mkProvider (import ./tests/fixtures/provider-invalid.nix {inherit lib;}));
        providerConformance =
          lib.mapAttrsToList (
            _: provider:
              (import ./tests/providers/harness.nix {inherit lib;} provider).valid
          )
          providers;
        supportMatrix = themeBrokerLib.supportMatrix {inherit providers adapters;};
        resolveBase16 = provider: variant: accent: let
          selected = themeBrokerLib.resolveSelection {
            inherit providers;
            selection = {
              inherit provider variant accent;
            };
          };
        in
          lib.mapAttrs (_: color: color.withHashtag) selected.base16;
        tintedBase16 = pkgs.writeText "theme-broker-tinted-base16.json" (builtins.toJSON {
          catppuccin = lib.mapAttrs (variant: _: resolveBase16 "catppuccin" variant "mauve") catppuccinProvider.variants;
          gruvbox = lib.mapAttrs (variant: _: resolveBase16 "gruvbox" variant null) gruvbox.variants;
          rose-pine = lib.mapAttrs (variant: _: resolveBase16 "rose-pine" variant "rose") rosePine.variants;
        });
      in {
        formatter = pkgs.alejandra;
        devShells.default = pkgs.mkShell {packages = [pkgs.alejandra pkgs.python3];};
        packages = {
          support-matrix-json = pkgs.writeText "theme-broker-support-matrix.json" supportMatrix.json;
          support-matrix-markdown = pkgs.writeText "theme-broker-support-matrix.md" supportMatrix.markdown;
          provider-schema = pkgs.writeText "theme-broker-provider.schema.json" (builtins.readFile ./schema/provider.schema.json);
          normalized-theme-schema = pkgs.writeText "theme-broker-normalized-theme.schema.json" (builtins.readFile ./schema/normalized-theme.schema.json);
          adapter-schema = pkgs.writeText "theme-broker-adapter.schema.json" (builtins.readFile ./schema/adapter.schema.json);
          wallpaper-catalog-schema = pkgs.writeText "theme-broker-wallpaper-catalog.schema.json" (builtins.readFile ./schema/wallpaper-catalog.schema.json);
        };
        checks = {
          gruvbox-dark-hard = pkgs.runCommand "theme-broker-gruvbox-dark-hard" {} ''
            test ${pkgs.lib.escapeShellArg darkHard.base16.base00.withHashtag} = '#1d2021'
            test ${pkgs.lib.escapeShellArg darkHard.roles.ui.background.withHashtag} = '#1d2021'
            touch "$out"
          '';
          provider-shape = pkgs.runCommand "theme-broker-provider-shape" {} ''
            test ${toString (builtins.length (builtins.attrNames gruvbox.variants))} = 6
            test ${toString (builtins.length (builtins.attrNames catppuccinProvider.variants))} = 4
            test ${toString (builtins.length (builtins.attrNames catppuccinProvider.variants.mocha.accents))} = 14
            test ${toString (builtins.length (builtins.attrNames rosePine.variants))} = 3
            test ${toString (builtins.length (builtins.attrNames rosePine.variants.main.accents))} = 6
            touch "$out"
          '';
          named-override-propagation = pkgs.runCommand "theme-broker-named-override-propagation" {} ''
            test ${pkgs.lib.escapeShellArg namedOverride.roles.ui.background.withHashtag} = '#000000'
            test ${pkgs.lib.escapeShellArg namedOverride.base16.base00.withHashtag} = '#000000'
            touch "$out"
          '';
          resolver-native = pkgs.runCommand "theme-broker-resolver-native" {} ''
            test ${pkgs.lib.escapeShellArg nativeResolution.backend} = native
            test ${pkgs.lib.escapeShellArg nativeResolution.adapter} = gruvbox-neovim
            touch "$out"
          '';
          resolver-synthetic-slice = pkgs.runCommand "theme-broker-resolver-synthetic-slice" {} ''
            test ${pkgs.lib.escapeShellArg syntheticGenerated.backend} = generated
            test ${pkgs.lib.escapeShellArg syntheticNative.backend} = native
            test ${pkgs.lib.escapeShellArg syntheticNative.adapter} = synthetic-alacritty
            touch "$out"
          '';
          evaluation = pkgs.runCommand "theme-broker-evaluation-tests" {} ''
            test ${
              if builtins.all (value: value) evaluationTests && !invalidProvider.success
              then "true"
              else "false"
            } = true
            test ${
              if builtins.all (value: value) providerConformance
              then "true"
              else "false"
            } = true
            touch "$out"
          '';
          cosmic-target-shape = let
            cosmicLib = {
              cosmic.mkRON = kind: value:
                if kind == "enum" && builtins.isAttrs value
                then {
                  __type = kind;
                  inherit (value) value variant;
                }
                else {
                  __type = kind;
                  inherit value;
                };
            };
            forcedValue = value:
              if value ? content
              then forcedValue value.content
              else value;
            cosmic = import ./targets/cosmic-manager.nix {
              inherit cosmicLib lib;
              selected = darkHard;
            };
            light = import ./targets/cosmic-manager.nix {
              inherit cosmicLib lib;
              selected = lightHard;
            };
          in
            pkgs.runCommand "theme-broker-cosmic-target-shape" {} ''
              test ${
                if cosmic.wayland.desktopManager.cosmic.content.appearance.theme.mode == "dark"
                then "true"
                else "false"
              } = true
              test ${
                let
                  theme = cosmic.wayland.desktopManager.cosmic.content.configFile."com.system76.CosmicTheme.Dark";
                in
                  if theme.version == 2 && theme.entries.frosted_maximized_apps == false
                  then "true"
                  else "false"
              } = true
              test ${
                if
                  builtins.length cosmic.wayland.desktopManager.cosmic.content.appearance.theme.dark.palette.value
                  == 1
                  && builtins.isAttrs (builtins.head cosmic.wayland.desktopManager.cosmic.content.appearance.theme.dark.palette.value)
                  && !(builtins.head cosmic.wayland.desktopManager.cosmic.content.appearance.theme.dark.palette.value) ? __type
                then "true"
                else "false"
              } = true
              test ${
                let
                  palette = builtins.head cosmic.wayland.desktopManager.cosmic.content.appearance.theme.dark.palette.value;
                in
                  if palette.blue.red.__type == "raw" && builtins.isString palette.blue.red.value
                  then "true"
                  else "false"
              } = true
              test ${
                if cosmic.wayland.desktopManager.cosmic.content.appearance.toolkit.apply_theme_global
                then "true"
                else "false"
              } = true
              test ${
                if forcedValue cosmic.stylix.targets.gtk.enable == false
                then "true"
                else "false"
              } = true
              test ${
                if
                  !(cosmic ? home)
                  && !(cosmic.wayland.desktopManager.cosmic.content ? wallpapers)
                  && !(cosmic.wayland.desktopManager.cosmic.content.appearance.toolkit ? icon_theme)
                  && !(builtins.all (assertion: assertion.assertion) light.assertions.content)
                then "true"
                else "false"
              } = true
              touch "$out"
            '';
          support-matrix = pkgs.runCommand "theme-broker-support-matrix" {} ''
            test ${pkgs.lib.escapeShellArg (toString (builtins.length supportMatrix.matrix.providers))} = 3
            test ${pkgs.lib.escapeShellArg (toString (builtins.length supportMatrix.matrix.adapters))} -ge 3
            test ${
              if builtins.all (adapter: adapter.status == "supported") supportMatrix.matrix.adapters
              then "true"
              else "false"
            } = true
            touch "$out"
          '';
          catppuccin-target-inventory = pkgs.runCommand "theme-broker-catppuccin-target-inventory" {} ''
            test ${toString (builtins.length (builtins.attrNames catppuccinManifest.targets))} -ge 80
            touch "$out"
          '';
          vscode-adapter = let
            colorTheme = pkgs.vscode-extensions.jdinhlife.gruvbox;
            iconTheme = import ./native/gruvbox/vscode-icons.nix {inherit lib pkgs;};
          in
            pkgs.runCommand "theme-broker-vscode-adapter" {} ''
              test -f ${colorTheme}/share/vscode/extensions/jdinhlife.gruvbox/package.json
              test -f ${iconTheme}/share/vscode/extensions/navernoedenis.gruvbox-material-icons/package.json
              touch "$out"
            '';
          catppuccin-manifest =
            pkgs.runCommand "theme-broker-catppuccin-manifest" {
              nativeBuildInputs = [pkgs.python3];
            } ''
              python3 ${./native/catppuccin/generate-manifest.py} ${catppuccin.outPath} --output generated.nix
              diff -u ${./native/catppuccin/manifest.nix} generated.nix
              touch "$out"
            '';
          catppuccin-palette =
            pkgs.runCommand "theme-broker-catppuccin-palette" {
              nativeBuildInputs = [pkgs.python3];
            } ''
              python3 ${./providers/catppuccin/update.py} ${catppuccin-palette}
              touch "$out"
            '';
          tinted-base16 =
            pkgs.runCommand "theme-broker-tinted-base16" {
              nativeBuildInputs = [pkgs.python3];
            } ''
              python3 ${./scripts/check-tinted.py} --source ${tinted-schemes} --actual ${tintedBase16}
              touch "$out"
            '';
          support-matrix-stale = pkgs.runCommand "theme-broker-support-matrix-stale" {} ''
            printf '%s' ${pkgs.lib.escapeShellArg supportMatrix.markdown} > generated.md
            diff -u ${./docs/support-matrix.md} generated.md
            touch "$out"
          '';
          update-scripts =
            pkgs.runCommand "theme-broker-update-scripts" {
              nativeBuildInputs = [pkgs.python3];
            } ''
              python3 -c 'import ast, pathlib; [ast.parse(path.read_text()) for path in pathlib.Path("${./scripts}").glob("*.py")]'
              touch "$out"
            '';
          no-ifd = pkgs.runCommand "theme-broker-no-ifd" {} ''
            if ${pkgs.ripgrep}/bin/rg -n 'import-from-derivation|builtins\\.derivation' ${./lib} ${./modules} ${./native} ${./providers}; then
              echo "theme-broker: import-from-derivation pattern found" >&2
              exit 1
            fi
            touch "$out"
          '';
        };
      };
    };
}
