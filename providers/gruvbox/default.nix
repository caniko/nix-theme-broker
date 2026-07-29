{lib}: let
  palette = builtins.fromJSON (builtins.readFile ./palette.json);
  requiredChromatic = ["red" "green" "yellow" "blue" "purple" "aqua" "orange"];
  mkVariant = id: source: let
    light = source.appearance == "light";
    chromaticPrefix =
      if light
      then "faded_"
      else "bright_";
    active = name: "@${chromaticPrefix}${name}";
    aliases =
      {
        background = source.background;
        backgroundAlt = source.backgroundAlt;
        surface = source.surface;
        foreground = source.foreground;
        foregroundMuted = source.foregroundMuted;
        border = "@dark3";
        bg0 = "@background";
        bg1 = "@backgroundAlt";
        bg2 = "@surface";
        bg3 = "@dark3";
        fg0 = "@foreground";
        fg1 = "@foreground";
        fg2 = "@foregroundMuted";
        fg3 = "@foregroundMuted";
        fg4 = "@foregroundMuted";
      }
      // lib.genAttrs requiredChromatic (name: active name)
      # Keep short provider-local names for semantic mappings and adapters.
      # `@name` references are resolved by the core provider validator.
      # The source inventory remains untouched in `palette.json`.
      #
      # The explicit aliases are deliberately data-only; no target-specific
      # names leak into the provider core.
      #
      # Nix attrset merging keeps the generated palette easy to audit.
      #
      # (The comments also document why these aliases exist.)
      // {
        red = active "red";
        green = active "green";
        yellow = active "yellow";
        blue = active "blue";
        purple = active "purple";
        aqua = active "aqua";
        orange = active "orange";
      };
  in {
    metadata = {
      inherit (source) appearance contrast;
      displayName = id;
    };
    named = palette.named // aliases;
    accents = {};
    accentBindings = [];
    roles = {
      ui = {
        background = "@background";
        backgroundAlt = "@backgroundAlt";
        surface = "@surface";
        surfaceAlt = "@border";
        overlay = "@gray";
        foreground = "@foreground";
        foregroundMuted = "@foregroundMuted";
        border = "@border";
        selectionBackground = "@surface";
        selectionForeground = "@foreground";
        focus = "@orange";
        accent = "@orange";
        link = "@blue";
      };
      status = {
        error = "@red";
        warning = "@yellow";
        success = "@green";
        info = "@blue";
        hint = "@aqua";
      };
      syntax = {
        comment = "@gray";
        string = "@green";
        number = "@purple";
        boolean = "@purple";
        keyword = "@red";
        function = "@green";
        type = "@yellow";
        variable = "@foreground";
        constant = "@orange";
        operator = "@orange";
        punctuation = "@foregroundMuted";
        tag = "@aqua";
        attribute = "@yellow";
      };
    };
    ansi = {
      normal = {
        black = "@dark0";
        red = "@red";
        green = "@green";
        yellow = "@yellow";
        blue = "@blue";
        magenta = "@purple";
        cyan = "@aqua";
        white = "@foreground";
      };
      bright = {
        black = "@gray";
        red = "@red";
        green = "@green";
        yellow = "@yellow";
        blue = "@blue";
        magenta = "@purple";
        cyan = "@aqua";
        white = "@light0";
      };
    };
    base16 =
      if light
      then {
        base00 = "@background";
        base01 = "@backgroundAlt";
        base02 = "@surface";
        base03 = "@light3";
        base04 = "@dark3";
        base05 = "@dark2";
        base06 = "@dark1";
        base07 = "@dark0";
        base08 = "@faded_red";
        base09 = "@faded_orange";
        base0A = "@faded_yellow";
        base0B = "@faded_green";
        base0C = "@faded_aqua";
        base0D = "@faded_blue";
        base0E = "@faded_purple";
        base0F = "@neutral_orange";
      }
      else {
        base00 = "@background";
        base01 = "@backgroundAlt";
        base02 = "@surface";
        base03 = "@dark3";
        base04 = "@foregroundMuted";
        # The Tinted/Base16 Gruvbox scheme uses light2 (#d5c4a1) for base05;
        # the semantic foreground remains light1 (#ebdbb2).
        base05 = "@light2";
        base06 = "@light1";
        base07 = "@light0";
        base08 = "@bright_red";
        base09 = "@bright_orange";
        base0A = "@bright_yellow";
        base0B = "@bright_green";
        base0C = "@bright_aqua";
        base0D = "@bright_blue";
        base0E = "@bright_purple";
        base0F = "@neutral_orange";
      };
    base24 = null;
  };
in {
  schema = "theme-broker.provider/v1";
  id = "gruvbox";
  name = "Gruvbox";
  description = "The canonical Gruvbox palette family";
  provenance = {
    repository = palette.source.repository;
    revision = palette.source.revision;
    license = "MIT";
  };
  defaults = {
    variant = "dark-medium";
    accent = null;
  };
  variants = lib.mapAttrs mkVariant palette.variants;
}
