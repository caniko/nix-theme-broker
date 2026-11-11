{
  lib,
  providers,
  adapters,
}: let
  themeLib = import ../../lib {inherit lib;};
  raw = providers.blackbox;
  # The authoritative inventory; palette.json must match exactly.
  expectedNamed = {
    background = "#000000";
    surface_0 = "#1a1a1a";
    surface_1 = "#262626";
    surface_2 = "#3a3a3a";
    foreground = "#ebdbb2";
    muted = "#bdae93";
    subtle = "#928374";
    foreground_bright = "#fbf1c7";
    red = "#cc241d";
    orange = "#d65d0e";
    yellow = "#d79921";
    green = "#98971a";
    aqua = "#689d6a";
    blue = "#458588";
    purple = "#b16286";
    bright_red = "#fb4934";
    bright_orange = "#fe8019";
    bright_yellow = "#fabd2f";
    bright_green = "#b8bb26";
    bright_aqua = "#8ec07c";
    bright_blue = "#83a598";
    bright_purple = "#d3869b";
    magenta = "#d3869b";
    bright_magenta = "#eb6f92";
  };
  selected = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "blackbox";
      variant = "dark";
      accent = null;
    };
  };
  defaulted = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "blackbox";
      variant = null;
      accent = null;
    };
  };
  # `figure` mixes colours with colormap names; it has its own assertions below.
  colorRoles = removeAttrs selected.roles ["figure"];
  formattedRoles = lib.mapAttrs (_: group: lib.mapAttrs (_: color: color.withHashtag) group) colorRoles;
  formattedAnsi = lib.mapAttrs (_: group: lib.mapAttrs (_: color: color.withHashtag) group) selected.ansi;
  formattedBase16 = lib.mapAttrs (_: color: color.withHashtag) selected.base16;
  expectedRoles = {
    ui = {
      background = "#000000";
      backgroundAlt = "#1a1a1a";
      surface = "#262626";
      surfaceAlt = "#3a3a3a";
      overlay = "#3a3a3a";
      foreground = "#ebdbb2";
      foregroundMuted = "#bdae93";
      border = "#3a3a3a";
      selectionBackground = "#262626";
      selectionForeground = "#fbf1c7";
      focus = "#fe8019";
      accent = "#fe8019";
      link = "#83a598";
    };
    status = {
      error = "#fb4934";
      warning = "#fe8019";
      success = "#b8bb26";
      info = "#83a598";
      hint = "#8ec07c";
    };
    syntax = {
      comment = "#928374";
      string = "#b8bb26";
      number = "#d3869b";
      boolean = "#d3869b";
      keyword = "#fb4934";
      function = "#b8bb26";
      type = "#fabd2f";
      variable = "#ebdbb2";
      constant = "#fe8019";
      operator = "#fe8019";
      punctuation = "#bdae93";
      tag = "#8ec07c";
      attribute = "#fabd2f";
    };
  };
  expectedAnsi = {
    normal = {
      black = "#000000";
      red = "#cc241d";
      green = "#98971a";
      yellow = "#d79921";
      blue = "#458588";
      magenta = "#b16286";
      cyan = "#689d6a";
      white = "#ebdbb2";
    };
    bright = {
      black = "#928374";
      red = "#fb4934";
      green = "#b8bb26";
      yellow = "#fabd2f";
      blue = "#83a598";
      magenta = "#d3869b";
      cyan = "#8ec07c";
      white = "#fbf1c7";
    };
  };
  expectedBase16 = {
    base00 = "#000000";
    base01 = "#1a1a1a";
    base02 = "#262626";
    base03 = "#928374";
    base04 = "#bdae93";
    base05 = "#ebdbb2";
    base06 = "#fbf1c7";
    base07 = "#fbf1c7";
    base08 = "#fb4934";
    base09 = "#fe8019";
    base0A = "#fabd2f";
    base0B = "#b8bb26";
    base0C = "#8ec07c";
    base0D = "#83a598";
    base0E = "#d3869b";
    base0F = "#d65d0e";
  };
  namedChecks = lib.mapAttrsToList (name: hex: (selected.named.${name} or {withHashtag = null;}).withHashtag == hex) expectedNamed;
  rawHexFormatChecks = lib.mapAttrsToList (
    name: hex:
      builtins.elem name (builtins.attrNames expectedNamed)
      && builtins.isString hex
      && builtins.match "#[0-9a-f]{6}" hex != null
  ) (lib.filterAttrs (name: _: expectedNamed ? ${name}) raw.variants.dark.named);
  requiredRoleChecks = map (path: lib.hasAttrByPath path selected.roles) themeLib.types.requiredRoles;
  light = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "blackbox";
      variant = "light";
      accent = null;
    };
  };
  hexOf = lib.mapAttrs (_: group: lib.mapAttrs (_: color: color.withHashtag) group);
  lightRoles = hexOf (removeAttrs light.roles ["figure"]);
  honey = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "blackbox";
      variant = "honey";
      accent = null;
    };
  };
  honeyRoles = hexOf (removeAttrs honey.roles ["figure"]);
  pink = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "blackbox";
      variant = "pink";
      accent = null;
    };
  };
  pinkRoles = hexOf (removeAttrs pink.roles ["figure"]);
  pinkLight = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "blackbox";
      variant = "pink-light";
      accent = null;
    };
  };
  pinkLightRoles = hexOf (removeAttrs pinkLight.roles ["figure"]);
  # Exact Honey inventory from the owner request.
  honeyNamed = {
    background = "#000000";
    surface_0 = "#181714";
    surface_1 = "#24221d";
    surface_2 = "#353128";
    foreground = "#ebdbb2";
    muted = "#bdae93";
    subtle = "#928374";
    foreground_bright = "#fff1c4";
    honey_dark = "#8f6317";
    honey = "#c88a22";
    honey_primary = "#e5a72b";
    honey_bright = "#f3c04f";
    honey_soft = "#f6d784";
    honey_pale = "#ffe6a3";
    red = "#cc241d";
    bright_red = "#fb4934";
    orange = "#d65d0e";
    bright_orange = "#fe8019";
    yellow = "#d6a52a";
    bright_yellow = "#f3c04f";
    green = "#98971a";
    bright_green = "#b8bb26";
    aqua = "#689d6a";
    bright_aqua = "#8ec07c";
    blue = "#458588";
    bright_blue = "#83a598";
    purple = "#b16286";
    bright_purple = "#d3869b";
    magenta = "#d3869b";
    bright_magenta = "#eb6f92";
  };
  honeyNamedChecks = lib.mapAttrsToList (name: hex: (honey.named.${name} or {withHashtag = null;}).withHashtag == hex) honeyNamed;
  figureHex = selected: {
    colors = lib.mapAttrs (_: color: color.withHashtag) (removeAttrs selected.roles.figure ["categorical" "sequential_cmap" "density_cmap" "time_cmap" "time_range"]);
    categorical = map (color: color.withHashtag) selected.roles.figure.categorical;
    inherit (selected.roles.figure) sequential_cmap density_cmap time_cmap time_range;
  };
  # Figure values are the bekiper themekit DARK/LIGHT snapshot, verbatim.
  darkFigure = figureHex selected;
  lightFigure = figureHex light;
  # Providers without a figure group stay valid and expose none.
  gruvboxNoFigure =
    !(themeLib.resolveSelection {
      inherit providers;
      selection = {
        provider = "gruvbox";
        variant = "dark-hard";
        accent = null;
      };
    }).roles ? figure;
  badFigure = builtins.tryEval (builtins.deepSeq
    (themeLib.mkProvider (raw
      // {
        variants =
          raw.variants
          // {
            dark = raw.variants.dark // {roles = raw.variants.dark.roles // {figure = raw.variants.dark.roles.figure // {categorical = ["#000000"];};};};
          };
      })).variants
    true);
  # Named overrides must propagate through aliases, roles, ANSI, and Base16.
  surfaceOverride = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "blackbox";
      variant = "dark";
      accent = null;
      overrides.named = {
        surface_0 = "#0a0a0a";
        bright_orange = "#123456";
        bright_blue = "#654321";
      };
    };
  };
  backgroundOverride = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "blackbox";
      variant = "dark";
      accent = null;
      overrides.named.background = "#050505";
    };
  };
  blueOverride = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "blackbox";
      variant = "dark";
      accent = "blue";
      overrides.named = {
        bright_orange = "#123456";
        bright_blue = "#654321";
      };
    };
  };
  accentOf = variant: accent:
    (themeLib.resolveSelection {
      inherit providers;
      selection = {
        provider = "blackbox";
        inherit variant accent;
      };
    }).roles.ui;
  accentChecks = builtins.all (c: c) (lib.concatMap (variant:
      lib.concatMap (accent: let
        ui = accentOf variant accent;
      in [
        (ui.accent.withHashtag == ui.focus.withHashtag)
      ]) [null "orange" "blue"]) ["dark" "light"]
    ++ [
      # Selections with accent = null stay orange, exactly as before blue was added.
      ((accentOf "dark" null).accent.withHashtag == "#fe8019")
      ((accentOf "dark" null).focus.withHashtag == "#fe8019")
      ((accentOf "dark" "orange").accent.withHashtag == "#fe8019")
      ((accentOf "light" null).accent.withHashtag == "#af3a03")
      ((accentOf "light" "orange").focus.withHashtag == "#af3a03")
      ((accentOf "dark" "blue").accent.withHashtag == "#83a598")
      ((accentOf "dark" "blue").focus.withHashtag == "#83a598")
      ((accentOf "light" "blue").accent.withHashtag == "#076678")
      ((accentOf "light" "blue").focus.withHashtag == "#076678")
    ]);
  propagationChecks = [
    (surfaceOverride.named.bg1.withHashtag == "#0a0a0a")
    (surfaceOverride.named.backgroundAlt.withHashtag == "#0a0a0a")
    (surfaceOverride.roles.ui.backgroundAlt.withHashtag == "#0a0a0a")
    (surfaceOverride.base16.base01.withHashtag == "#0a0a0a")
    (surfaceOverride.named.focus.withHashtag == "#123456")
    (surfaceOverride.roles.ui.focus.withHashtag == "#123456")
    (surfaceOverride.roles.ui.accent.withHashtag == "#123456")
    (blueOverride.roles.ui.focus.withHashtag == "#654321")
    (blueOverride.roles.ui.accent.withHashtag == "#654321")
    (blueOverride.roles.status.warning.withHashtag == "#123456")
    (surfaceOverride.roles.ui.link.withHashtag == "#654321")
    (surfaceOverride.roles.status.warning.withHashtag == "#123456")
    (surfaceOverride.roles.syntax.constant.withHashtag == "#123456")
    (surfaceOverride.base16.base09.withHashtag == "#123456")
    (backgroundOverride.roles.ui.background.withHashtag == "#050505")
    (backgroundOverride.base16.base00.withHashtag == "#050505")
    (backgroundOverride.ansi.normal.black.withHashtag == "#050505")
  ];
  backendPolicy = {
    allowedNativeTiers = ["official" "canonical" "maintained" "local"];
    requireAccentFidelity = false;
    requireOverrideFidelity = true;
    preferNative = true;
    onUnsupported = "fallback";
  };
  # Auto on a Stylix-backed target: generated, never a Gruvbox adapter.
  autoKitty = themeLib.resolveBackend {
    providerId = "blackbox";
    variantId = "dark";
    selection = {
      backend = "auto";
      accent = null;
      overrides = {};
    };
    targetId = "kitty";
    platform = "homeManager";
    trustedAdapters = adapters;
    generatedAvailable = true;
    generatedAutoSafe = true;
    policy = backendPolicy;
  };
  # vscode is generated-available but not autoSafe: only an explicit
  # generated request resolves.
  forcedVscode = themeLib.resolveBackend {
    providerId = "blackbox";
    variantId = "dark";
    selection = {
      backend = "generated";
      accent = null;
      overrides = {};
    };
    targetId = "vscode";
    platform = "homeManager";
    trustedAdapters = adapters;
    generatedAvailable = true;
    generatedAutoSafe = false;
    policy = backendPolicy;
  };
  # Explicit native requests without a compatible adapter must fail closed
  # (the gruvbox adapters are provider-bound and must never match).
  explicitNativeNeovim = builtins.tryEval (builtins.deepSeq (themeLib.resolveBackend {
      providerId = "blackbox";
      variantId = "dark";
      selection = {
        backend = "native";
        accent = null;
        overrides = {};
      };
      targetId = "neovim";
      platform = "homeManager";
      trustedAdapters = adapters;
      generatedAvailable = false;
      policy = backendPolicy;
    })
    true);
  # Auto with no generated target and no adapter must fail rather than pick a
  # provider-mismatched native adapter.
  autoNeovim = builtins.tryEval (builtins.deepSeq (themeLib.resolveBackend {
      providerId = "blackbox";
      variantId = "dark";
      selection = {
        backend = "auto";
        accent = null;
        overrides = {};
      };
      targetId = "neovim";
      platform = "homeManager";
      trustedAdapters = adapters;
      generatedAvailable = false;
      policy = backendPolicy;
    })
    true);
  explicitNativeCursors = builtins.tryEval (builtins.deepSeq (themeLib.resolveBackend {
      providerId = "blackbox";
      variantId = "dark";
      selection = {
        backend = "native";
        accent = null;
        overrides = {};
      };
      targetId = "cursors";
      platform = "homeManager";
      trustedAdapters = adapters;
      generatedAvailable = false;
      policy = backendPolicy;
    })
    true);
  # Regression: the Gruvbox provider and its native adapters are untouched.
  gruvboxSelected = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "gruvbox";
      variant = "dark-hard";
      accent = null;
    };
  };
  gruvboxNative = themeLib.resolveBackend {
    providerId = "gruvbox";
    variantId = "dark-hard";
    selection = {
      backend = "native";
      accent = null;
      overrides = {};
    };
    targetId = "neovim";
    platform = "homeManager";
    trustedAdapters = adapters;
    policy = backendPolicy;
  };
  catppuccinSelected = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "catppuccin";
      variant = "mocha";
      accent = "mauve";
    };
  };
  # The additional magenta accents stay in the named inventory even though
  # the ANSI/Base16 projections use the conventional purple/cyan slots.
  projectedValues =
    (lib.flatten (lib.mapAttrsToList (_: group: map (color: color.withHashtag) (lib.attrValues group)) selected.ansi))
    ++ (map (color: color.withHashtag) (lib.attrValues selected.base16))
    ++ (lib.flatten (lib.mapAttrsToList (_: group: map (color: color.withHashtag) (lib.attrValues group)) colorRoles));
in
  assert raw.schema == "theme-broker.provider/v1";
  assert raw.id == "blackbox";
  assert raw.name == "Blackbox";
  assert raw.description != "";
  assert raw.defaults
  == {
    variant = "dark";
    accent = "orange";
  };
  assert lib.attrNames raw.variants == ["dark" "honey" "light" "pink" "pink-light"];
  assert (themeLib.mkProvider raw).id == "blackbox";
  assert raw.variants.dark.metadata.appearance == "dark";
  assert raw.variants.dark.metadata.contrast == "hard";
  assert raw.variants.dark.base24 == null;
  assert selected.base24 == null;
  assert builtins.isString raw.provenance.repository;
  assert raw.provenance.revision == "local";
  assert raw.provenance.kind == "local-derivative";
  assert raw.provenance.derivedFrom.name == "Gruvbox";
  assert raw.provenance.license == "MIT";
  assert selected.provider == "blackbox";
  assert selected.variant == "dark";
  assert selected.accent == "orange";
  assert defaulted.variant == "dark";
  assert defaulted.accent == "orange";
  assert builtins.all (value: value) rawHexFormatChecks;
  assert builtins.length (builtins.attrNames (lib.filterAttrs (name: _: expectedNamed ? ${name}) raw.variants.dark.named)) == 24;
  assert builtins.all (value: value) namedChecks;
  assert builtins.all (value: value) requiredRoleChecks;
  assert formattedRoles == expectedRoles;
  assert formattedAnsi == expectedAnsi;
  assert formattedBase16 == expectedBase16;
  # True-black primary canvas in both the semantic role and Base16.
  assert selected.roles.ui.background.withHashtag == "#000000";
  assert selected.base16.base00.withHashtag == "#000000";
  # Comments and ANSI bright black use `subtle`, never a near-black surface.
  assert selected.roles.syntax.comment.withHashtag == "#928374";
  assert selected.ansi.bright.black.withHashtag == "#928374";
  assert selected.ansi.bright.black.withHashtag != selected.named.surface_0.withHashtag;
  # Blue/aqua/purple mappings.
  assert selected.roles.ui.link.withHashtag == "#83a598";
  assert selected.ansi.normal.blue.withHashtag == "#458588";
  assert selected.ansi.bright.blue.withHashtag == "#83a598";
  assert selected.ansi.normal.cyan.withHashtag == "#689d6a";
  assert selected.ansi.bright.cyan.withHashtag == "#8ec07c";
  assert selected.ansi.normal.magenta.withHashtag == "#b16286";
  assert selected.ansi.bright.magenta.withHashtag == "#d3869b";
  assert selected.named.magenta.withHashtag == "#d3869b";
  assert selected.named.bright_magenta.withHashtag == "#eb6f92";
  assert !(builtins.elem "#eb6f92" projectedValues);
  assert builtins.all (value: value) propagationChecks;
  # Light variant: near-white canvas, Gruvbox-light's darker hues for accents.
  assert raw.variants.light.metadata.appearance == "light";
  assert light.variant == "light";
  assert light.base24 == null;
  assert builtins.all (value: value) (map (path: lib.hasAttrByPath path light.roles) themeLib.types.requiredRoles);
  assert lightRoles.ui.background == "#ffffff";
  assert lightRoles.ui.backgroundAlt == "#f7f7f5";
  assert lightRoles.ui.surface == "#f2f2f0";
  assert lightRoles.ui.surfaceAlt == "#e8e8e5";
  assert lightRoles.ui.border == "#d9d9d6";
  assert lightRoles.ui.foreground == "#1d2021";
  assert lightRoles.ui.foregroundMuted == "#5a5550";
  assert lightRoles.ui.accent == "#af3a03";
  assert lightRoles.ui.focus == lightRoles.ui.accent;
  assert accentChecks;
  assert lightRoles.ui.link == "#076678";
  assert lightRoles.status
  == {
    error = "#9d0006";
    warning = "#af3a03";
    success = "#79740e";
    info = "#076678";
    hint = "#427b58";
  };
  assert lightRoles.syntax.attribute == "#b57614";
  assert lightRoles.syntax.boolean == "#8f3f71";
  assert light.base16.base00.withHashtag == "#ffffff";
  assert light.ansi.normal.black.withHashtag == "#ffffff";
  assert light.ansi.normal.red.withHashtag == "#cc241d";
  assert light.ansi.bright.red.withHashtag == "#9d0006";
  # Honey variant: warm ramp over the true-black canvas; figures reuse dark.
  assert raw.variants.honey.metadata.appearance == "dark";
  assert raw.variants.honey.accents == {};
  assert honey.variant == "honey";
  assert honey.accent == null;
  assert honey.base24 == null;
  assert honey.roles ? figure;
  assert builtins.all (value: value) (map (path: lib.hasAttrByPath path honey.roles) themeLib.types.requiredRoles);
  assert builtins.all (value: value) honeyNamedChecks;
  assert honeyRoles.ui
  == {
    background = "#000000";
    backgroundAlt = "#181714";
    surface = "#24221d";
    surfaceAlt = "#353128";
    overlay = "#353128";
    foreground = "#ebdbb2";
    foregroundMuted = "#bdae93";
    foregroundSubtle = "#928374";
    foregroundBright = "#fff1c4";
    border = "#353128";
    borderSubtle = "#24221d";
    accent = "#e5a72b";
    accentHover = "#f3c04f";
    accentActive = "#c88a22";
    accentMuted = "#8f6317";
    onAccent = "#000000";
    focus = "#f3c04f";
    link = "#f3c04f";
    selectionBackground = "#353128";
    selectionForeground = "#ebdbb2";
  };
  assert honeyRoles.status
  == {
    error = "#fb4934";
    warning = "#e5a72b";
    success = "#b8bb26";
    info = "#83a598";
    hint = "#8ec07c";
  };
  assert honeyRoles.syntax.type == "#f3c04f";
  assert honeyRoles.syntax.comment == "#928374";
  assert honey.ansi.bright.yellow.withHashtag == "#f3c04f";
  assert honey.base16.base00.withHashtag == "#000000";
  # Pink variants: rose ramp, no accent axis, only the required UI roles.
  assert raw.variants.pink.metadata.appearance == "dark";
  assert raw.variants.pink.accents == {};
  assert pink.variant == "pink";
  assert pink.accent == null;
  assert pink.roles ? figure;
  assert pinkRoles.ui.accent == "#da5b8d";
  assert !(pinkRoles.ui ? onAccent);
  assert pinkRoles.ui.focus == "#e97aa5";
  assert pinkRoles.ui.link == "#e97aa5";
  assert pink.roles.status.warning.withHashtag == "#fe8019";
  assert raw.variants.pink-light.metadata.appearance == "light";
  assert raw.variants.pink-light.accents == {};
  assert pinkLight.variant == "pink-light";
  assert pinkLight.accent == null;
  assert pinkLight.roles ? figure;
  assert pinkLightRoles.ui.accent == "#b8436c";
  assert !(pinkLightRoles.ui ? accentHover);
  assert pinkLightRoles.ui.focus == "#a8345f";
  assert pinkLightRoles.ui.link == "#a8345f";
  assert pinkLightRoles.ui.border == "#d9d9d6";
  # Figure roles: verbatim themekit snapshot, independent of the UI chrome.
  assert darkFigure.colors.background == "#0f1318";
  assert darkFigure.colors.on_status == "#0f1318";
  assert figureHex honey == darkFigure;
  assert builtins.length darkFigure.categorical == 10;
  assert builtins.elemAt darkFigure.categorical 0 == "#4c9bff";
  assert darkFigure.density_cmap == "magma";
  assert darkFigure.time_range == [0.25 1.0];
  assert lightFigure.colors.surface == "#f6f7f9";
  assert builtins.elemAt lightFigure.categorical 9 == "#17becf";
  assert lightFigure.density_cmap == "hot";
  assert lightFigure.time_range == [0.0 0.85];
  assert gruvboxNoFigure;
  assert !badFigure.success;
  # Generated-backend resolution for blackbox/dark.
  assert autoKitty.backend == "generated";
  assert autoKitty.adapter == null;
  assert forcedVscode.backend == "generated";
  assert forcedVscode.adapter == null;
  # Incompatible native adapters are rejected, not silently substituted.
  assert !explicitNativeNeovim.success;
  assert !autoNeovim.success;
  assert !explicitNativeCursors.success;
  # Existing providers and their native adapters are unchanged.
  assert gruvboxSelected.roles.ui.background.withHashtag == "#1d2021";
  assert gruvboxSelected.base16.base00.withHashtag == "#1d2021";
  assert gruvboxNative.backend == "native";
  assert gruvboxNative.adapter == "gruvbox-neovim";
  assert catppuccinSelected.roles.ui.background.withHashtag == "#1e1e2e"; true
