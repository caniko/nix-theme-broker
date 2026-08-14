{
  lib,
  color,
}: let
  types = import ./types.nix {inherit lib;};
  validation = import ./validation.nix {inherit lib;};
  inherit (types) base16Keys ansiKeys requiredRoles;

  providerError = providerId: variantId: path: message:
    validation.error providerId variantId path message;

  require = providerId: variantId: path: condition: message:
    if condition
    then true
    else providerError providerId variantId path message;

  resolveWith = seen: named: value:
    if builtins.isString value && lib.hasPrefix "@" value
    then let
      name = lib.removePrefix "@" value;
    in
      if !builtins.hasAttr name named
      then throw "themeBroker: unknown color reference @${name}"
      else if builtins.elem name seen
      then throw "themeBroker: cyclic color reference @${name}"
      else resolveWith (seen ++ [name]) named named.${name}
    else color.parse value;

  resolveNamed = named: value: resolveWith [] named value;

  resolveTree = named: value:
    if builtins.isAttrs value && value ? hex
    then color.parse value
    else if builtins.isAttrs value
    then lib.mapAttrs (_: child: resolveTree named child) value
    else if builtins.isList value
    then map (resolveTree named) value
    else resolveNamed named value;

  validateValue = providerId: variantId: named: path: value:
    if builtins.isAttrs value && value ? hex
    then let
      parsed = builtins.tryEval (color.parse value);
    in [
      (
        if parsed.success
        then true
        else providerError providerId variantId path "expected a six-digit hexadecimal color"
      )
    ]
    else if builtins.isAttrs value
    then lib.flatten (lib.mapAttrsToList (name: child: validateValue providerId variantId named (path ++ [name]) child) value)
    else if builtins.isList value
    then lib.flatten (lib.imap0 (index: child: validateValue providerId variantId named (path ++ [toString index]) child) value)
    else if builtins.isString value && lib.hasPrefix "@" value
    then [(require providerId variantId path (builtins.hasAttr (lib.removePrefix "@" value) named) "unknown named color reference")]
    else let
      parsed = builtins.tryEval (color.parse value);
    in [
      (
        if parsed.success
        then true
        else providerError providerId variantId path "expected a six-digit hexadecimal color"
      )
    ];

  validateNamedReferences = providerId: variantId: named:
    lib.flatten (lib.mapAttrsToList (name: value:
      if builtins.isString value && lib.hasPrefix "@" value
      then [
        (require providerId variantId ["named" name]
          (!(builtins.isString (named.${lib.removePrefix "@" value} or null))
            || !(lib.hasPrefix "@" (named.${lib.removePrefix "@" value} or "")))
          "references must point to a literal color, not another reference")
      ]
      else [])
    named);

  validateProjection = providerId: variantId: projectionName: projection: keys: let
    actual =
      if builtins.isAttrs projection
      then lib.attrNames projection
      else [];
    missing = lib.subtractLists keys actual;
    extra = lib.subtractLists actual keys;
  in [
    (require providerId variantId [projectionName] (builtins.isAttrs projection && missing == []) "missing keys: ${lib.concatStringsSep ", " missing}")
    (require providerId variantId [projectionName] (extra == []) "unexpected keys: ${lib.concatStringsSep ", " extra}")
  ];

  validateVariant = providerId: variantId: variant: let
    metadata = variant.metadata or {};
    named = variant.named or {};
    roles = variant.roles or {};
    ansi = variant.ansi or {};
    base16 = variant.base16 or {};
    base24 = variant.base24 or null;
    accents = variant.accents or {};
    checks =
      [
        (require providerId variantId ["metadata" "appearance"] (builtins.elem (metadata.appearance or null) ["dark" "light"]) "expected `dark` or `light`")
        (require providerId variantId ["metadata" "contrast"] (builtins.elem (metadata.contrast or null) ["hard" "medium" "soft"]) "expected `hard`, `medium`, or `soft`")
        (require providerId variantId ["named"] (builtins.isAttrs named && named != {}) "must contain named colors")
      ]
      ++ (map (path: require providerId variantId path (lib.hasAttrByPath path roles) "missing required semantic role") requiredRoles)
      ++ validateProjection providerId variantId "ansi.normal" (ansi.normal or {}) ansiKeys
      ++ validateProjection providerId variantId "ansi.bright" (ansi.bright or {}) ansiKeys
      ++ validateProjection providerId variantId "base16" base16 base16Keys
      ++ validateValue providerId variantId named ["named"] named
      ++ validateNamedReferences providerId variantId named
      ++ validateValue providerId variantId named ["roles"] roles
      ++ validateValue providerId variantId named ["ansi"] ansi
      ++ validateValue providerId variantId named ["base16"] base16
      ++ (
        if base24 == null
        then []
        else validateValue providerId variantId named ["base24"] base24
      )
      ++ validateValue providerId variantId named ["accents"] accents;
  in
    if builtins.all (value: value) checks
    then true
    else false;

  normalizeVariant = providerId: variantId: variant: let
    named = lib.mapAttrs (_: value: resolveNamed variant.named value) (variant.named or {});
  in {
    provider = providerId;
    variant = variantId;
    metadata = variant.metadata;
    _raw = variant;
    inherit named;
    roles = resolveTree named (variant.roles or {});
    ansi = resolveTree named (variant.ansi or {});
    base16 = resolveTree named variant.base16;
    base24 =
      if (variant.base24 or null) == null
      then null
      else resolveTree named variant.base24;
    accents = resolveTree named (variant.accents or {});
    accentBindings = variant.accentBindings or [];
  };

  validateProvider = provider: let
    providerId = provider.id or "<missing>";
    variants = provider.variants or {};
    defaults = provider.defaults or {};
    variantIds = lib.attrNames variants;
    defaultVariant = defaults.variant or null;
    defaultAccent = defaults.accent or null;
    defaultVariantValid =
      builtins.isString defaultVariant
      && builtins.hasAttr defaultVariant variants;
    defaultVariantData =
      if defaultVariantValid
      then variants.${defaultVariant}
      else {};
    checks =
      [
        (
          if provider.schema or null == "theme-broker.provider/v1"
          then true
          else throw "themeBroker: provider `${providerId}`: unsupported schema"
        )
        (require providerId "<provider>" ["id"] (builtins.match "[a-z0-9][a-z0-9-]*" providerId != null) "invalid provider ID")
        (require providerId "<provider>" ["name"] (builtins.isString (provider.name or null) && provider.name != "") "name is required")
        (require providerId "<provider>" ["description"] (builtins.isString (provider.description or null) && provider.description != "") "description is required")
        (require providerId "<provider>" ["variants"] (variantIds != []) "must define at least one variant")
        (require providerId "<provider>" ["defaults" "variant"] defaultVariantValid "default variant is not registered")
        (require providerId "<provider>" ["provenance"] (builtins.isAttrs (provider.provenance or null)) "provenance is required")
        (require providerId "<provider>" ["provenance" "repository"] (builtins.isString ((provider.provenance or {}).repository or null)) "repository is required")
        (require providerId "<provider>" ["provenance" "revision"] (builtins.isString ((provider.provenance or {}).revision or null)) "revision is required")
        (require providerId "<provider>" ["provenance" "license"] (builtins.isString ((provider.provenance or {}).license or null)) "license is required")
      ]
      ++ (map (variantId: builtins.seq (validateVariant providerId variantId variants.${variantId}) true) variantIds)
      ++ (
        if defaultAccent == null
        then []
        else [
          (require providerId "<provider>" ["defaults" "accent"] (defaultVariantValid && builtins.hasAttr defaultAccent (defaultVariantData.accents or {})) "default accent is not registered")
        ]
      );
  in
    if builtins.all (value: value) checks
    then provider
    else throw "themeBroker: provider `${providerId}` failed validation";

  normalizeProvider = provider: let
    validated = validateProvider provider;
  in
    validated
    // {
      variants = lib.mapAttrs (normalizeVariant validated.id) validated.variants;
    };
in {
  inherit resolveTree validateProvider normalizeProvider;
  mkProvider = provider: normalizeProvider provider;
}
