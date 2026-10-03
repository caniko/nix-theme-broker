{
  lib,
  providers,
}: let
  themeLib = import ../../lib {inherit lib;};
  render = import ../../lib/renderers/opencode-v2.nix {inherit lib;};
  select = selection: themeLib.resolveSelection {inherit providers selection;};
  variants = lib.concatMap (provider:
    map (variant: select {inherit provider variant;})
    (builtins.attrNames providers.${provider}.variants))
  (builtins.attrNames providers);
  syntaxKeys = ["comment" "keyword" "function" "variable" "string" "number" "type" "operator" "punctuation"];
  markdownKeys = ["text" "heading" "link" "linkText" "code" "blockQuote" "emphasis" "strong" "horizontalRule" "listItem" "listEnumeration" "image" "imageText" "codeBlock"];
  hues = ["gray" "red" "orange" "yellow" "green" "cyan" "blue" "purple" "accent" "interactive" "neutral"];
  steps = map toString (lib.range 1 9);
  hueSteps = map (step: "${step}00") steps;
  leaves = value:
    if builtins.isAttrs value
    then lib.concatMap leaves (builtins.attrValues value)
    else if builtins.isList value
    then lib.concatMap leaves value
    else [value];
  referencesValid = theme: mode: let
    resolved = lib.recursiveUpdate theme.base theme.${mode};
    resolve = seen: value:
      if !lib.hasPrefix "$" value
      then builtins.match "#[0-9a-f]{6}|transparent" value != null
      else let
        path = lib.splitString "." (lib.removePrefix "$" value);
      in
        !builtins.elem value seen
        && lib.hasAttrByPath path resolved
        && resolve (seen ++ [value]) (lib.getAttrFromPath path resolved);
    tokens = builtins.removeAttrs resolved ["hue" "categorical"];
  in
    builtins.all (resolve []) (leaves tokens);
  valid = selected: let
    theme = render selected;
    mode = selected.metadata.appearance;
  in
    builtins.attrNames theme
    == ["$schema" "base" mode]
    && theme.base.background.base == selected.roles.ui.background.withHashtag
    && theme.base.text.base == selected.roles.ui.foreground.withHashtag
    && builtins.attrNames theme.base.syntax == lib.sort builtins.lessThan syntaxKeys
    && builtins.attrNames theme.base.markdown == lib.sort builtins.lessThan markdownKeys
    && builtins.all (key: theme.base.syntax.${key} == selected.roles.syntax.${key}.withHashtag) syntaxKeys
    && builtins.all (hue:
      builtins.attrNames theme.${mode}.hue.${hue}
      == hueSteps
      && builtins.all (color: builtins.match "#[0-9a-f]{6}" color != null) (builtins.attrValues theme.${mode}.hue.${hue}))
    hues
    && theme.${mode}.hue.accent."200" == selected.roles.ui.accent.withHashtag
    && builtins.all (hue: builtins.elem hue hues) theme.base.categorical
    && referencesValid theme mode;
  overrides = select {
    provider = "gruvbox";
    variant = "dark-hard";
    overrides = {
      named.bright_green = "#12ab34";
      roles.ui.accent = "#123456";
      roles.ui.background = "#010203";
      roles.syntax.keyword = "#abcdef";
    };
  };
  overridden = render overrides;
  accents = map (accent: let
    selected = select {
      provider = "catppuccin";
      variant = "mocha";
      inherit accent;
    };
  in
    (render selected).dark.hue.accent."200" == selected.roles.ui.accent.withHashtag)
  (builtins.attrNames providers.catppuccin.variants.mocha.accents);
  black = render (select {
    provider = "blackbox";
    variant = "dark";
  });
in
  assert builtins.all valid variants;
  assert builtins.all (value: value) accents;
  assert overridden.base.background.base == "#010203";
  assert overridden.base.syntax.string == "#12ab34";
  assert overridden.base.syntax.keyword == "#abcdef";
  assert overridden.dark.hue.accent."200" == "#123456";
  assert black.base.background.base == "#000000";
  assert black.base."@dialog".background.base == "$background.raised.base";
  assert black.base.text.action.primary."$selected" == "$text.base";
  assert black.base.background.action.primary."$selected" == "$hue.interactive.700"; true
