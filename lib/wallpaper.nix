{lib}: let
  validPath = path: let
    parts = lib.splitString "/" path;
  in
    builtins.isString path
    && path != ""
    && !lib.hasPrefix "/" path
    && !(builtins.any (part: builtins.elem part ["" "." ".."]) parts);

  validateEntry = provider: entry: let
    variants = entry.variants or null;
    default = entry.default or null;
    paths = entry.paths or null;
    valid =
      builtins.isAttrs entry
      && builtins.isList variants
      && variants != []
      && builtins.all builtins.isString variants
      && builtins.length variants == builtins.length (lib.unique variants)
      && builtins.isString default
      && builtins.isList paths
      && paths != []
      && builtins.all validPath paths
      && builtins.length paths == builtins.length (lib.unique paths)
      && builtins.elem default paths;
  in
    if valid
    then entry
    else throw "themeBroker: invalid wallpaper registry entry `${provider}`";

  validateRegistry = registry:
    if builtins.isAttrs registry
    then let
      validated = lib.mapAttrs validateEntry registry;
    in
      builtins.deepSeq validated validated
    else throw "themeBroker: wallpaper registry must be an attribute set";

  resolve = {
    provider,
    registry,
    variant,
  }: let
    validated = validateRegistry registry;
    entry = validated.${provider} or null;
  in
    if entry == null || !builtins.elem variant entry.variants
    then null
    else removeAttrs entry ["variants"];
in {
  inherit resolve validateRegistry;
}
