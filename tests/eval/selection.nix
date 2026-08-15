{
  lib,
  providers,
}: let
  themeLib = import ../../lib {inherit lib;};
  wallpapers.catppuccin = {
    variants = ["mocha"];
    default = "wallpapers/catppuccin/default.png";
    paths = [
      "wallpapers/catppuccin/default.png"
      "wallpapers/catppuccin/alternate.jpg"
    ];
  };
  selected = themeLib.resolveSelection {
    inherit providers;
    inherit wallpapers;
    selection = {
      provider = "catppuccin";
      variant = "mocha";
      accent = "blue";
      overrides.roles.ui.background = "#000000";
    };
  };
  providerDefault = themeLib.resolveSelection {
    inherit providers;
    inherit wallpapers;
    selection = {
      provider = "catppuccin";
      variant = null;
      accent = null;
    };
  };
  unsupported = themeLib.resolveSelection {
    inherit providers wallpapers;
    selection = {
      provider = "catppuccin";
      variant = "latte";
      accent = "blue";
    };
  };
  mappedProviders =
    providers
    // {
      mapped =
        providers.catppuccin
        // {
          id = "mapped";
          defaults = {
            variant = "mocha";
            accent = "special";
          };
          variants.mocha =
            providers.catppuccin.variants.mocha
            // {
              accents = providers.catppuccin.variants.mocha.accents // {special = "@red";};
              base24.extension = "@blue";
            };
        };
    };
  mapped = themeLib.resolveSelection {
    providers = mappedProviders;
    selection = {
      provider = "mapped";
      variant = "mocha";
      accent = "special";
      overrides.named.red = "#112233";
      overrides.base24.extension = "#000000";
    };
  };
  base24Override = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "gruvbox";
      variant = "dark-hard";
      overrides.base24.extension = "#000000";
    };
  };
  invalidOverride = overrides:
    builtins.tryEval (builtins.deepSeq (themeLib.resolveSelection {
        providers = mappedProviders;
        selection = {
          provider = "mapped";
          variant = "mocha";
          accent = "special";
          inherit overrides;
        };
      })
      true);
  invalidAnsi = invalidOverride {ansi.normal.orange = "#000000";};
  invalidBase16 = invalidOverride {base16.base10 = "#000000";};
  invalidBase24 = invalidOverride {base24.extra = "#000000";};
  invalidSourceName = builtins.tryEval (builtins.deepSeq (themeLib.resolveSelection {
      providers =
        mappedProviders
        // {
          rest =
            mappedProviders.mapped
            // {
              variants.mocha =
                mappedProviders.mapped.variants.mocha
                // {
                  named.background = {
                    hex = "#000000";
                    sourceName = 5;
                  };
                };
            };
        };
      selection = {
        provider = "rest";
        variant = "mocha";
      };
    })
    true);
  invalid = builtins.tryEval (builtins.deepSeq (themeLib.validateRegistry {
      catppuccin = wallpapers.catppuccin // {default = "../outside.png";};
    })
    true);
in
  assert selected.provider == "catppuccin";
  assert selected.variant == "mocha";
  assert selected.accent == "blue";
  assert selected.roles.ui.background.withHashtag == "#000000";
  assert selected.base16.base00.withHashtag == "#1e1e2e";
  assert selected.wallpapers.default == "wallpapers/catppuccin/default.png";
  assert builtins.length selected.wallpapers.paths == 2;
  assert providerDefault.variant == providers.catppuccin.defaults.variant;
  assert providerDefault.accent == providers.catppuccin.defaults.accent;
  assert unsupported.wallpapers == null;
  assert mapped.roles.ui.accent.withHashtag == mapped.named.red.withHashtag;
  assert mapped.roles.ui.accent.withHashtag == "#112233";
  assert mapped.base24.extension.withHashtag == "#000000";
  assert base24Override.base24.extension.withHashtag == "#000000";
  assert !invalidAnsi.success && !invalidBase16.success && !invalidBase24.success;
  assert !invalidSourceName.success;
  assert !invalid.success; true
