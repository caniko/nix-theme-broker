{
  cosmicLib,
  lib,
  selected,
  enabled ? true,
  ...
}: let
  inherit (cosmicLib.cosmic) mkRON;

  ui = selected.roles.ui;
  status = selected.roles.status;
  base = selected.base16;
  ansi = selected.ansi;

  toRawFloat = value: mkRON "raw" (builtins.toJSON value);
  toSrgb = color: {
    red = toRawFloat (color.rgb.r / 255.0);
    green = toRawFloat (color.rgb.g / 255.0);
    blue = toRawFloat (color.rgb.b / 255.0);
  };
  toSrgba = color: (toSrgb color) // {alpha = toRawFloat 1.0;};
  optional = color: mkRON "optional" (toSrgb color);
  optionalSrgba = color: mkRON "optional" (toSrgba color);
  darkPalette = {
    name = "${selected.provider}-${selected.variant}";
    blue = toSrgba ansi.normal.blue;
    red = toSrgba ansi.normal.red;
    green = toSrgba ansi.normal.green;
    yellow = toSrgba ansi.normal.yellow;
    gray_1 = toSrgba base.base00;
    gray_2 = toSrgba base.base01;
    gray_3 = toSrgba base.base02;
    neutral_0 = toSrgba base.base00;
    neutral_1 = toSrgba base.base00;
    neutral_2 = toSrgba base.base01;
    neutral_3 = toSrgba base.base02;
    neutral_4 = toSrgba base.base03;
    neutral_5 = toSrgba base.base04;
    neutral_6 = toSrgba base.base05;
    neutral_7 = toSrgba base.base05;
    neutral_8 = toSrgba base.base06;
    neutral_9 = toSrgba base.base07;
    neutral_10 = toSrgba base.base07;
    bright_green = toSrgba ansi.bright.green;
    bright_red = toSrgba ansi.bright.red;
    bright_orange = toSrgba base.base09;
    ext_warm_grey = toSrgba base.base04;
    ext_orange = toSrgba base.base09;
    ext_yellow = toSrgba base.base0A;
    ext_blue = toSrgba base.base0D;
    ext_purple = toSrgba base.base0E;
    ext_pink = toSrgba base.base0E;
    ext_indigo = toSrgba ui.accent;
    accent_blue = toSrgba ansi.normal.blue;
    accent_red = toSrgba ansi.normal.red;
    accent_green = toSrgba ansi.normal.green;
    accent_warm_grey = toSrgba base.base04;
    accent_orange = toSrgba base.base09;
    accent_yellow = toSrgba ansi.normal.yellow;
    accent_purple = toSrgba ansi.normal.magenta;
    accent_pink = toSrgba ansi.normal.magenta;
    accent_indigo = toSrgba ui.accent;
  };
in {
  assertions = lib.mkIf enabled [
    {
      assertion = selected.metadata.appearance == "dark";
      message = "themeBroker: COSMIC generated target supports dark variants only";
    }
  ];

  stylix.targets.gtk.enable = lib.mkIf enabled (lib.mkForce false);

  wayland.desktopManager.cosmic = lib.mkIf enabled {
    configFile."com.system76.CosmicTheme.Dark" = {
      version = 2;
      entries.frosted_maximized_apps = false;
    };

    appearance = {
      theme = {
        dark = {
          palette = mkRON "enum" {
            variant = "Dark";
            value = [darkPalette];
          };
          bg_color = optionalSrgba ui.background;
          text_tint = optional ui.foreground;
          accent = optional ui.accent;
          success = optional status.success;
          warning = optional status.warning;
          destructive = optional status.error;
          window_hint = optional ui.focus;
          neutral_tint = optional ui.foregroundMuted;
          primary_container_bg = optionalSrgba ui.surface;
          secondary_container_bg = optionalSrgba ui.surfaceAlt;
        };
        mode = "dark";
      };
      toolkit = {
        apply_theme_global = true;
      };
    };
  };
}
