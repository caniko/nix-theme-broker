{
  nixpkgs,
  homeManager,
  nixDarwin,
  stylix,
  catppuccin,
  providers,
  adapters,
  linuxSystem ? "x86_64-linux",
  darwinSystem ? "aarch64-darwin",
}: let
  brokerModule = platform:
    import ../../modules/${platform}.nix {
      themeBrokerProviders = providers;
      themeBrokerBuiltinAdapters = adapters;
      themeBrokerAdapters = [];
    };
  home = homeManager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${linuxSystem};
    modules = [
      (homeManager.outPath + "/modules/programs/vscode")
      (homeManager.outPath + "/modules/programs/firefox")
      stylix.homeModules.stylix
      catppuccin.homeModules.default
      (brokerModule "home-manager")
      {
        home = {
          username = "theme-broker-test";
          homeDirectory = "/home/theme-broker-test";
          stateVersion = "26.05";
        };
        stylix.enable = false;
        themeBroker = {
          enable = true;
          selection = {
            provider = "catppuccin";
            variant = "mocha";
            accent = "mauve";
          };
          targets = {
            vscode = {
              backend = "native";
              nativeOptions.profile = "work";
            };
            cursor = {
              backend = "native";
              nativeOptions.profile = "work";
            };
            vscodium = {
              backend = "native";
              nativeOptions.profile = "work";
            };
            windsurf = {
              backend = "native";
              nativeOptions.profile = "work";
            };
            kiro = {
              backend = "native";
              nativeOptions.profile = "work";
            };
            antigravity = {
              backend = "native";
              nativeOptions.profile = "work";
            };
            firefox = {
              backend = "native";
              nativeOptions.profile = "personal";
            };
          };
        };
      }
    ];
  };
  nixos = nixpkgs.lib.nixosSystem {
    system = linuxSystem;
    modules = [
      stylix.nixosModules.stylix
      catppuccin.nixosModules.default
      (brokerModule "nixos")
      {
        system.stateVersion = "26.11";
        stylix.enable = false;
        themeBroker = {
          enable = true;
          selection = {
            provider = "catppuccin";
            variant = "mocha";
            accent = "mauve";
          };
          targets = {
            plymouth.backend = "native";
            home-assistant.backend = "native";
          };
        };
      }
    ];
  };
  darwin = nixDarwin.lib.darwinSystem {
    system = darwinSystem;
    modules = [
      stylix.darwinModules.stylix
      catppuccin.darwinModules.catppuccin
      (brokerModule "darwin")
      {
        system.stateVersion = 6;
        programs.fish.enable = true;
        stylix.enable = false;
        themeBroker = {
          enable = true;
          selection = {
            provider = "catppuccin";
            variant = "mocha";
            accent = "mauve";
          };
          targets.fish.backend = "native";
        };
      }
    ];
  };
in
  assert home.config.themeBroker.resolved.targets.vscode.adapter == "catppuccin-vscode";
  assert home.config.catppuccin.vscode.profiles.work.enable;
  assert home.config.catppuccin.vscode.profiles.work.icons.enable;
  assert home.config.programs.vscode.profiles.work.userSettings."workbench.colorTheme" == "Catppuccin Mocha";
  assert builtins.all (target: home.config.catppuccin.${target}.profiles.work.enable) ["cursor" "vscodium" "windsurf" "kiro" "antigravity"];
  assert home.config.themeBroker.resolved.targets.firefox.adapter == "catppuccin-firefox";
  assert home.config.catppuccin.firefox.profiles.personal.enable;
  assert home.config.programs.firefox.profiles ? personal;
  assert nixos.config.themeBroker.resolved.targets.plymouth.adapter == "catppuccin-plymouth";
  assert nixos.config.boot.plymouth.theme == "catppuccin-mocha";
  assert nixos.config.themeBroker.resolved.targets.home-assistant.adapter == "catppuccin-home-assistant";
  assert nixos.config.services.home-assistant.config.frontend.themes == "!include_dir_merge_named ${nixos.config.catppuccin.sources.home-assistant}";
  assert nixos.config.services.home-assistant.config."automation catppuccin".id == "catppuccin_default_theme";
  assert darwin.config.themeBroker.resolved.targets.fish.adapter == "catppuccin-fish";
  assert builtins.attrNames darwin.config.themeBroker.resolved.targets == ["fish"];
  assert darwin.config.catppuccin.fish.enable;
  assert nixpkgs.lib.hasInfix ''fish_config theme choose "catppuccin-mocha"'' darwin.config.programs.fish.shellInit;
  assert nixpkgs.lib.hasSuffix "/static/catppuccin-mocha.theme" (toString darwin.config.environment.etc."fish/themes/catppuccin-mocha.theme".source); true
