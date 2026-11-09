{
  lib,
  providers,
  publicLib,
}: let
  web = publicLib.web;
  select = provider: variant: {
    inherit provider variant;
    accent = null;
  };
  # The web theme uses Blackbox Blue.
  blue = variant: (select "blackbox" variant) // {accent = "blue";};
  args = {
    inherit providers;
    light = blue "light";
    dark = blue "dark";
  };
  css = web.css args;
  json = builtins.fromJSON (web.json args);
  honeyArgs = {
    inherit providers;
    light = args.light;
    dark = select "blackbox" "honey";
  };
  honeyCss = web.css honeyArgs;
  honeyJson = builtins.fromJSON (web.json honeyArgs);
  has = needle: lib.hasInfix needle css;
  honeyHas = needle: lib.hasInfix needle honeyCss;
  # canix's mdBook palette: roles.ui as plain hex, unchanged by the move.
  ui = web.uiPalette (publicLib.resolveSelection {
    inherit providers;
    selection = blue "dark";
  });
  # A provider without figure roles still renders; only chrome variables exist.
  plain = web.css {
    inherit providers;
    light = select "gruvbox" "light-hard";
    dark = select "gruvbox" "dark-hard";
  };
in
  assert lib.hasPrefix ":root {\n  color-scheme: light;\n  --tb-ui-accent: #076678;" css;
  assert has "@media (prefers-color-scheme: dark) {\n  :root:not([data-theme=light]) {\n    color-scheme: dark;";
  assert has "[data-theme=dark] {\n  color-scheme: dark;";
  assert has "[data-theme=light] {\n  color-scheme: light;";
  assert has "--tb-ui-selection-background: #f2f2f0;";
  assert has "--tb-figure-surface-alt: #eef1f5;";
  assert has "--tb-figure-surface-alt: #1f2630;";
  # Lists and colormap names stay in theme.json.
  assert !has "categorical";
  assert !has "cmap";
  assert json.light.variant == "light";
  assert json.dark.appearance == "dark";
  assert json.light.roles.ui.background == "#ffffff";
  assert json.dark.roles.ui.background == "#000000";
  assert builtins.length json.dark.roles.figure.categorical == 10;
  assert json.light.roles.figure.sequential_cmap == "viridis";
  assert json.dark.roles.figure.time_range == [0.25 1.0];
  assert ui.background == "#000000";
  assert ui.link == "#83a598";
  # The Honey pair reuses the light snapshot and adds the optional UI roles.
  assert honeyHas "--tb-ui-accent: #e5a72b;";
  assert honeyHas "--tb-ui-accent-hover: #f3c04f;";
  assert honeyHas "--tb-ui-foreground-subtle: #928374;";
  assert honeyJson.light.variant == "light";
  assert honeyJson.dark.variant == "honey";
  assert honeyJson.light.roles.ui.accent == "#076678";
  assert honeyJson.dark.roles.ui.onAccent == "#000000";
  assert honeyJson.light.roles ? figure;
  assert honeyJson.dark.roles ? figure;
  assert honeyJson.dark.roles.figure.background == "#0f1318";
  assert honeyJson.light.roles.figure.surface == "#f6f7f9";
  assert lib.hasInfix "--tb-ui-background: #1d2021;" plain;
  assert !lib.hasInfix "--tb-figure" plain; true
