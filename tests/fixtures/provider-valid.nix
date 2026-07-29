{lib}: let
  themeLib = import ../../lib {inherit lib;};
  color = "#112233";
  ansi = {
    black = color;
    red = color;
    green = color;
    yellow = color;
    blue = color;
    magenta = color;
    cyan = color;
    white = color;
  };
  base16 = lib.genAttrs themeLib.types.base16Keys (_: color);
in
  themeLib.mkProvider {
    schema = "theme-broker.provider/v1";
    id = "fixture";
    name = "Fixture";
    description = "Provider validation fixture";
    provenance = {
      repository = "https://example.invalid/fixture";
      revision = "fixture";
      license = "MIT";
    };
    defaults = {
      variant = "dark";
      accent = null;
    };
    variants.dark = {
      metadata = {
        appearance = "dark";
        contrast = "medium";
      };
      named = {
        background = color;
        foreground = color;
      };
      roles = {
        ui = {
          background = "@background";
          backgroundAlt = "@background";
          surface = "@background";
          surfaceAlt = "@background";
          overlay = "@background";
          foreground = "@foreground";
          foregroundMuted = "@foreground";
          border = "@background";
          selectionBackground = "@background";
          selectionForeground = "@foreground";
          focus = "@background";
          accent = "@background";
          link = "@background";
        };
        status = {
          error = "@background";
          warning = "@background";
          success = "@background";
          info = "@background";
          hint = "@background";
        };
        syntax = lib.genAttrs ["comment" "string" "number" "boolean" "keyword" "function" "type" "variable" "constant" "operator" "punctuation" "tag" "attribute"] (_: "@foreground");
      };
      inherit ansi base16;
      accents = {};
      accentBindings = [];
    };
  }
