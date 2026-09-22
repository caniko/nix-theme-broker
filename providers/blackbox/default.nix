{lib}: let
  palette = builtins.fromJSON (builtins.readFile ./palette.json);
  mkVariant = id: source: let
    # Aliases are data-only convenience names for consumers, adapters, and
    # overrides.  Each alias points one hop at a literal color in
    # `palette.json` (the provider validator forbids alias chains), so a named
    # override on an inventory color propagates through every dependent alias,
    # semantic role, ANSI bank, and Base16 slot during selection.
    aliases = {
      # UI-facing semantic names (inventory colors are the source of truth).
      backgroundAlt = "@surface_0";
      surface = "@surface_1";
      surfaceAlt = "@surface_2";
      overlay = "@surface_2";
      border = "@surface_2";
      foregroundMuted = "@muted";
      selectionBackground = "@surface_1";
      selectionForeground = "@foreground_bright";
      focus = "@bright_orange";
      accent = "@bright_orange";
      link = "@bright_blue";
      # Short names in the shape Gruvbox consumers already use.
      bg0 = "@background";
      bg1 = "@surface_0";
      bg2 = "@surface_1";
      bg3 = "@surface_2";
      fg0 = "@foreground_bright";
      fg1 = "@foreground";
      fg2 = "@muted";
      fg3 = "@muted";
      fg4 = "@subtle";
      gray = "@subtle";
    };
  in {
    metadata = {
      inherit (source) appearance contrast;
      displayName = "Blackbox ${id}";
    };
    named = palette.named // aliases;
    accents = {};
    accentBindings = [];
    roles = {
      ui = {
        background = "@background";
        backgroundAlt = "@backgroundAlt";
        surface = "@surface";
        surfaceAlt = "@surfaceAlt";
        overlay = "@overlay";
        foreground = "@foreground";
        foregroundMuted = "@foregroundMuted";
        border = "@border";
        selectionBackground = "@selectionBackground";
        selectionForeground = "@selectionForeground";
        focus = "@focus";
        accent = "@accent";
        link = "@link";
      };
      status = {
        error = "@bright_red";
        warning = "@bright_orange";
        success = "@bright_green";
        info = "@bright_blue";
        hint = "@bright_aqua";
      };
      # Same role assignments as the Gruvbox provider, expressed with the
      # corresponding Blackbox bright accents; comments use `subtle`.
      syntax = {
        comment = "@subtle";
        string = "@bright_green";
        number = "@bright_purple";
        boolean = "@bright_purple";
        keyword = "@bright_red";
        function = "@bright_green";
        type = "@bright_yellow";
        variable = "@foreground";
        constant = "@bright_orange";
        operator = "@bright_orange";
        punctuation = "@muted";
        tag = "@bright_aqua";
        attribute = "@bright_yellow";
      };
    };
    ansi = {
      normal = {
        black = "@background";
        red = "@red";
        green = "@green";
        yellow = "@yellow";
        blue = "@blue";
        magenta = "@purple";
        cyan = "@aqua";
        white = "@foreground";
      };
      bright = {
        # `subtle` is readable ANSI bright-black text; surface_0 is a UI
        # surface and must never land here.
        black = "@subtle";
        red = "@bright_red";
        green = "@bright_green";
        yellow = "@bright_yellow";
        blue = "@bright_blue";
        magenta = "@bright_purple";
        cyan = "@bright_aqua";
        white = "@foreground_bright";
      };
    };
    base16 = {
      base00 = "@background";
      base01 = "@surface_0";
      base02 = "@surface_1";
      base03 = "@subtle";
      base04 = "@muted";
      base05 = "@foreground";
      # base06/base07 intentionally repeat foreground_bright; Base16 has no
      # separate slot for it and inventing colors would break the projection.
      base06 = "@foreground_bright";
      base07 = "@foreground_bright";
      base08 = "@bright_red";
      base09 = "@bright_orange";
      base0A = "@bright_yellow";
      base0B = "@bright_green";
      base0C = "@bright_aqua";
      base0D = "@bright_blue";
      base0E = "@bright_purple";
      base0F = "@orange";
    };
    base24 = null;
  };
in {
  schema = "theme-broker.provider/v1";
  id = "blackbox";
  name = "Blackbox";
  description = "True-black, Gruvbox-inspired palette maintained in this repository";
  provenance = palette.source // {license = "MIT";};
  defaults = {
    variant = "dark";
    accent = null;
  };
  variants = lib.mapAttrs mkVariant palette.variants;
}
