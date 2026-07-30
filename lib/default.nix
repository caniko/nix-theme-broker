{lib}: let
  color = import ./color.nix {inherit lib;};
  types = import ./types.nix {inherit lib;};
  validation = import ./validation.nix {inherit lib;};
  projection = import ./projection.nix {inherit lib;};
  supportMatrix = import ./support-matrix.nix {inherit lib;};
  provider = import ./provider.nix {inherit lib color;};
  wallpaper = import ./wallpaper.nix {inherit lib;};
  selection = import ./selection.nix {inherit lib provider wallpaper;};
  adapter = import ./adapter.nix {inherit lib;};
  target = import ./target.nix {inherit lib;};
  generatedTargets = import ./generated-targets.nix;
in {
  inherit color;
  inherit types validation projection;
  inherit supportMatrix;
  inherit target;
  inherit generatedTargets;
  inherit (wallpaper) validateRegistry;
  resolveWallpapers = wallpaper.resolve;
  inherit (provider) mkProvider normalizeProvider;
  inherit (adapter) mkAdapter;
  targetAliases = adapter.aliases or {};
  resolveBackend = adapter.resolve;
  resolveSelection = args:
    selection {
      providers = lib.mapAttrs (_: provider.normalizeProvider) args.providers;
      selection = args.selection;
      wallpapers = args.wallpapers or {};
    };
}
