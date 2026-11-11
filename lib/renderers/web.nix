# Web renderer: one `theme.css` (custom properties for both colour schemes) and
# one `theme.json` (every role of both modes) from a `{light, dark}` pair of
# selections, each resolved through the shared `resolveSelection` projection.
# `css` also takes an optional `palette` id (matching `^[a-z0-9-]+$`): the rules
# are then scoped to `:root[data-palette=<id>]` so one stylesheet can hold
# several palettes switched by the `data-palette` attribute.
{
  lib,
  resolveSelection,
}: let
  # Resolved colors become "#rrggbb"; colormap names, `time_range` and other
  # plain data pass through, so the result is JSON-ready.
  toHex = value:
    if builtins.isAttrs value && value ? withHashtag
    then value.withHashtag
    else if builtins.isAttrs value
    then lib.mapAttrs (_: toHex) value
    else if builtins.isList value
    then map toHex value
    else value;
  # Every role group as hex strings, e.g. `(roles selected).ui.background`.
  roles = selected: toHex selected.roles;
  # `roles.ui` alone, the mapping web surfaces without the module consume.
  uiPalette = selected: (roles selected).ui;

  groups = ["ui" "status" "syntax" "figure"];
  # backgroundAlt -> background-alt, surface_alt -> surface-alt
  kebab = name:
    lib.replaceStrings (lib.upperChars ++ ["_"]) ((map (c: "-${c}") lib.lowerChars) ++ ["-"]) name;
  isColor = value: builtins.isString value && lib.hasPrefix "#" value;

  # `--tb-<group>-<role>` for every scalar colour; lists and colormap names
  # (figure `categorical`, `*_cmap`, `time_range`) live in theme.json only.
  variables = tree:
    lib.concatMap (
      group:
        lib.optionals (tree ? ${group}) (
          lib.concatLists (lib.mapAttrsToList (
              role: value:
                lib.optional (isColor value) "  --tb-${group}-${kebab role}: ${value};"
            )
            tree.${group})
        )
    )
    groups;

  # `args` = `{providers, light, dark}`, the last two being selections, plus an
  # optional `palette` id that scopes every rule to `:root[data-palette=<id>]`.
  resolve = args: name:
    resolveSelection {
      inherit (args) providers;
      selection = args.${name};
    };

  rule = selector: scheme: tree:
    ["${selector} {" "  color-scheme: ${scheme};"] ++ variables tree ++ ["}"];

  # Without `palette` the selectors stay `:root` / `[data-theme=*]`,
  # byte-identical to before. The id lands in a selector, so only a
  # conservative character set is allowed.
  paletteScope = args:
    if args ? palette
    then let
      id = args.palette;
    in
      if builtins.isString id && builtins.match "[a-z0-9-]+" id != null
      then ":root[data-palette=${id}]"
      else throw "themeBroker: web.css palette `${toString id}` must match ^[a-z0-9-]+$"
    else "";

  css = args: let
    light = roles (resolve args "light");
    dark = roles (resolve args "dark");
    scope = paletteScope args;
    root =
      if scope == ""
      then ":root"
      else scope;
  in
    lib.concatStringsSep "\n" (
      rule root "light" light
      ++ ["@media (prefers-color-scheme: dark) {"]
      ++ map (line: "  ${line}") (rule "${root}:not([data-theme=light])" "dark" dark)
      ++ ["}"]
      ++ rule "${scope}[data-theme=dark]" "dark" dark
      ++ rule "${scope}[data-theme=light]" "light" light
    )
    + "\n";

  json = args:
    builtins.toJSON (lib.genAttrs ["light" "dark"] (name: let
      selected = resolve args name;
    in {
      inherit (selected) provider variant;
      appearance = selected.metadata.appearance;
      roles = roles selected;
    }));
in {
  inherit css json roles uiPalette;
}
