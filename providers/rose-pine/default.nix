{lib}: let
  palette = builtins.fromJSON (builtins.readFile ./palette.json);
  accentNames = ["love" "gold" "rose" "pine" "foam" "iris"];
  accents = lib.genAttrs accentNames (name: "@${name}");
  mkVariant = _: source: {
    metadata = {
      inherit (source) appearance displayName;
      contrast = "medium";
    };
    named =
      source.colors
      // {
        accent = "@rose";
        base16Overlay = source.base16Overlay or source.colors.overlay;
      };
    roles = {
      ui = {
        background = "@base";
        backgroundAlt = "@surface";
        surface = "@surface";
        surfaceAlt = "@overlay";
        overlay = "@overlay";
        foreground = "@text";
        foregroundMuted = "@subtle";
        border = "@highlightHigh";
        selectionBackground = "@highlightMed";
        selectionForeground = "@text";
        focus = "@accent";
        accent = "@accent";
        link = "@iris";
      };
      status = {
        error = "@love";
        warning = "@gold";
        success = "@pine";
        info = "@foam";
        hint = "@iris";
      };
      syntax = {
        comment = "@muted";
        string = "@gold";
        number = "@rose";
        boolean = "@rose";
        keyword = "@love";
        function = "@pine";
        type = "@foam";
        variable = "@text";
        constant = "@gold";
        operator = "@subtle";
        punctuation = "@subtle";
        tag = "@foam";
        attribute = "@iris";
      };
    };
    ansi = {
      normal = {
        black = "@overlay";
        red = "@love";
        green = "@pine";
        yellow = "@gold";
        blue = "@foam";
        magenta = "@iris";
        cyan = "@rose";
        white = "@text";
      };
      bright = {
        black = "@muted";
        red = "@love";
        green = "@pine";
        yellow = "@gold";
        blue = "@foam";
        magenta = "@iris";
        cyan = "@rose";
        white = "@text";
      };
    };
    base16 = {
      base00 = "@base";
      base01 = "@surface";
      base02 = "@base16Overlay";
      base03 = "@muted";
      base04 = "@subtle";
      base05 = "@text";
      base06 = "@text";
      base07 = "@highlightHigh";
      base08 = "@love";
      base09 = "@gold";
      base0A = "@rose";
      base0B = "@pine";
      base0C = "@foam";
      base0D = "@iris";
      base0E = "@gold";
      base0F = "@highlightHigh";
    };
    base24 = null;
    inherit accents;
    accentBindings = [["ui" "accent"] ["ui" "focus"]];
  };
in {
  schema = "theme-broker.provider/v1";
  id = "rose-pine";
  name = "Rosé Pine";
  description = "The three canonical Rosé Pine palette variants";
  provenance = {
    inherit (palette.source) repository revision;
    license = "MIT";
  };
  defaults = {
    variant = "main";
    accent = "rose";
  };
  variants = lib.mapAttrs mkVariant palette.variants;
}
