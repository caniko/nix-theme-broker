# Web renderer: one `theme.css` (custom properties for both colour schemes) and
# one `theme.json` (every role of both modes) from a `{light, dark}` pair of
# selections, each resolved through the shared `resolveSelection` projection.
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

  # `args` = `{providers, light, dark}`, the last two being selections.
  resolve = args: name:
    resolveSelection {
      inherit (args) providers;
      selection = args.${name};
    };

  rule = selector: scheme: tree:
    ["${selector} {" "  color-scheme: ${scheme};"] ++ variables tree ++ ["}"];

  css = args: let
    light = roles (resolve args "light");
    dark = roles (resolve args "dark");
  in
    lib.concatStringsSep "\n" (
      rule ":root" "light" light
      ++ ["@media (prefers-color-scheme: dark) {"]
      ++ map (line: "  ${line}") (rule ":root:not([data-theme=light])" "dark" dark)
      ++ ["}"]
      ++ rule "[data-theme=dark]" "dark" dark
      ++ rule "[data-theme=light]" "light" light
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
