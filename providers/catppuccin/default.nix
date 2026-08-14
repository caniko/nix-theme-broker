{
  lib,
  palette ? null,
  revision ? null,
}: let
  paletteData =
    if palette == null
    then throw "themeBroker: Catppuccin palette input is required"
    else if builtins.isAttrs palette && palette ? outPath
    then builtins.fromJSON (builtins.readFile "${palette.outPath}/palette.json")
    else if builtins.isAttrs palette
    then palette
    else builtins.fromJSON (builtins.readFile "${palette}/palette.json");
  accentNames = [
    "rosewater"
    "flamingo"
    "pink"
    "mauve"
    "red"
    "maroon"
    "peach"
    "yellow"
    "green"
    "teal"
    "sky"
    "sapphire"
    "blue"
    "lavender"
  ];
  accentMap = lib.genAttrs accentNames (name: "@${name}");
  mkVariant = id: let
    source = paletteData.${id};
    named =
      (lib.mapAttrs (name: value:
        {
          hex = value.hex;
          sourceName = name;
        }
        // lib.optionalAttrs (value ? hsl) {hsl = value.hsl;}
        // lib.optionalAttrs (value ? oklch) {oklch = value.oklch;})
      source.colors)
      // {
        # The semantic role is replaced by accentBindings during selection.
        # Keep a valid default reference so provider validation remains local.
        accent = "@mauve";
      };
  in {
    metadata = {
      appearance =
        if source.dark
        then "dark"
        else "light";
      contrast = "medium";
      displayName = source.name;
    };
    inherit named;
    roles = {
      ui = {
        background = "@base";
        backgroundAlt = "@mantle";
        surface = "@surface0";
        surfaceAlt = "@surface1";
        overlay = "@overlay0";
        foreground = "@text";
        foregroundMuted = "@subtext0";
        border = "@surface2";
        selectionBackground = "@surface2";
        selectionForeground = "@text";
        focus = "@accent";
        accent = "@accent";
        link = "@blue";
      };
      status = {
        error = "@red";
        warning = "@yellow";
        success = "@green";
        info = "@blue";
        hint = "@teal";
      };
      syntax = {
        comment = "@overlay1";
        string = "@green";
        number = "@peach";
        boolean = "@peach";
        keyword = "@mauve";
        function = "@blue";
        type = "@yellow";
        variable = "@text";
        constant = "@peach";
        operator = "@sky";
        punctuation = "@overlay2";
        tag = "@mauve";
        attribute = "@yellow";
      };
    };
    ansi = {
      normal = {
        black = "@surface1";
        red = "@red";
        green = "@green";
        yellow = "@yellow";
        blue = "@blue";
        magenta = "@mauve";
        cyan = "@teal";
        white = "@text";
      };
      bright = {
        black = "@surface2";
        red = "@red";
        green = "@green";
        yellow = "@yellow";
        blue = "@blue";
        magenta = "@pink";
        cyan = "@sky";
        white = "@subtext1";
      };
    };
    base16 = {
      base00 = "@base";
      base01 = "@mantle";
      base02 = "@surface0";
      base03 = "@surface1";
      base04 = "@surface2";
      base05 = "@text";
      base06 = "@rosewater";
      base07 = "@lavender";
      base08 = "@red";
      base09 = "@peach";
      base0A = "@yellow";
      base0B = "@green";
      base0C = "@teal";
      base0D = "@blue";
      base0E = "@mauve";
      base0F = "@flamingo";
    };
    base24 = null;
    accents = accentMap;
    accentBindings = [["ui" "accent"] ["ui" "focus"]];
  };
in {
  schema = "theme-broker.provider/v1";
  id = "catppuccin";
  name = "Catppuccin";
  description = "The four upstream Catppuccin palette variants";
  provenance = {
    repository = "https://github.com/catppuccin/palette";
    revision =
      if revision == null
      then "07d02aa110ef9eb7e7427afca5c73ba9cf7f8ebd"
      else revision;
    license = "MIT";
  };
  defaults = {
    variant = "mocha";
    accent = "mauve";
  };
  variants = lib.genAttrs ["latte" "frappe" "macchiato" "mocha"] mkVariant;
}
