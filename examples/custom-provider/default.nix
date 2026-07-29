{
  lib,
  inputs,
  ...
}: {
  imports = [inputs.theme-broker.homeModules.default];
  themeBroker = {
    enable = true;
    selection = {
      provider = "example";
      variant = "dark";
      accent = null;
    };
  };
  themeBroker.registry.providers.example = {
    schema = "theme-broker.provider/v1";
    id = "example";
    name = "Example";
    description = "Documentation fixture; use the provider test harness.";
    provenance = {
      repository = "https://example.invalid/example";
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
        base = "#101010";
        text = "#f0f0f0";
      };
      roles = {
        ui = {
          background = "@base";
          backgroundAlt = "@base";
          surface = "@base";
          surfaceAlt = "@base";
          overlay = "@base";
          foreground = "@text";
          foregroundMuted = "@text";
          border = "@base";
          selectionBackground = "@base";
          selectionForeground = "@text";
          focus = "@text";
          accent = "@text";
          link = "@text";
        };
        status = {
          error = "@text";
          warning = "@text";
          success = "@text";
          info = "@text";
          hint = "@text";
        };
        syntax = lib.genAttrs ["comment" "string" "number" "boolean" "keyword" "function" "type" "variable" "constant" "operator" "punctuation" "tag" "attribute"] (_: "@text");
      };
      ansi = lib.genAttrs ["normal" "bright"] (_: lib.genAttrs ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"] (_: "@text"));
      base16 = lib.genAttrs inputs.theme-broker.lib.types.base16Keys (_: "@base");
      accents = {};
      accentBindings = [];
    };
  };
}
