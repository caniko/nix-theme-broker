{
  lib,
  provider,
}: {
  providers,
  selection,
}: let
  providerId = selection.provider;
  selectedProvider =
    if builtins.hasAttr providerId providers
    then providers.${providerId}
    else throw "themeBroker: unknown provider `${providerId}`";
  variantId =
    if selection.variant or null == null
    then selectedProvider.defaults.variant
    else selection.variant;
  variant =
    if builtins.hasAttr variantId selectedProvider.variants
    then selectedProvider.variants.${variantId}
    else throw "themeBroker: provider `${providerId}` has no variant `${variantId}`";
  raw = variant._raw or {};
  overrides = selection.overrides or {};
  requestedAccent =
    if builtins.hasAttr "accent" selection && selection.accent != null
    then selection.accent
    else selectedProvider.defaults.accent;
  accent = requestedAccent;
  _accentCheck =
    if accent == null && variant.accents != {}
    then throw "themeBroker: provider `${providerId}` variant `${variantId}` requires an accent"
    else if accent == null
    then true
    else if builtins.hasAttr accent variant.accents
    then true
    else throw "themeBroker: provider `${providerId}` variant `${variantId}` does not support accent `${accent}`";

  asPath = value:
    if builtins.isList value
    then value
    else lib.splitString "." value;
  setPath = path: value:
    if path == []
    then value
    else {${builtins.head path} = setPath (builtins.tail path) value;};
  setBindings = current: paths: value:
    lib.foldl' (acc: path: lib.recursiveUpdate acc (setPath (asPath path) value)) current paths;

  rawNamed = lib.recursiveUpdate (raw.named or {}) (overrides.named or {});
  named = provider.resolveTree rawNamed rawNamed;
  accentValue =
    if accent == null
    then null
    else named.${accent};
  rolesWithAccent =
    if accentValue == null
    then raw.roles or {}
    else setBindings (raw.roles or {}) (variant.accentBindings or []) accentValue;
  rolesWithOverrides = lib.recursiveUpdate rolesWithAccent (overrides.roles or {});
  roles = provider.resolveTree named rolesWithOverrides;
  ansi = provider.resolveTree named (lib.recursiveUpdate (raw.ansi or {}) (overrides.ansi or {}));
  base16 = provider.resolveTree named (lib.recursiveUpdate (raw.base16 or {}) (overrides.base16 or {}));
  rawBase24 = raw.base24 or null;
  base24 =
    if rawBase24 == null && (overrides.base24 or {}) == {}
    then null
    else
      provider.resolveTree named (lib.recursiveUpdate (
        if rawBase24 == null
        then {}
        else rawBase24
      ) (overrides.base24 or {}));
  formatted = {
    base16Scheme = lib.mapAttrs (_: value: value.withHashtag) base16;
    ansi = lib.mapAttrs (_: group: lib.mapAttrs (_: value: value.withHashtag) group) ansi;
  };
in
  builtins.seq _accentCheck {
    provider = providerId;
    variant = variantId;
    inherit accent roles ansi base16 base24 formatted;
    metadata = variant.metadata;
    inherit named;
  }
