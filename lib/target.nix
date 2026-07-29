{lib}: let
  tiers = ["official" "canonical" "maintained" "community" "local"];
  platforms = ["homeManager" "nixos" "darwin"];
  require = id: path: condition: message:
    if condition
    then true
    else throw "themeBroker: adapter `${id}` at `${lib.concatStringsSep "." path}`: ${message}";
in {
  validate = adapter: let
    id = adapter.id or "<missing>";
    provenance = adapter.provenance or {};
    capabilities = adapter.capabilities or {};
    variants = capabilities.variants or "all";
    checks = [
      (require id ["schema"] ((adapter.schema or null) == "theme-broker.adapter/v1") "unsupported schema")
      (require id ["id"] (builtins.match "[a-z0-9][a-z0-9-]*" id != null) "invalid adapter ID")
      (require id ["provider"] (builtins.isString (adapter.provider or null)) "provider is required")
      (require id ["target"] (builtins.isString (adapter.target or null)) "target is required")
      (require id ["platforms"] (builtins.isList (adapter.platforms or []) && (adapter.platforms or []) != []) "at least one platform is required")
      (require id ["platforms"] (builtins.all (platform: builtins.elem platform platforms) (adapter.platforms or [])) "unknown platform")
      (require id ["provenance" "tier"] (builtins.elem (provenance.tier or null) tiers) "unknown trust tier")
      (require id ["provenance" "repository"] (builtins.isString (provenance.repository or null)) "repository is required")
      (require id ["provenance" "revision"] (builtins.isString (provenance.revision or null)) "revision is required")
      (require id ["provenance" "license"] (builtins.isString (provenance.license or null)) "license is required")
      (require id ["capabilities"] (builtins.isAttrs (adapter.capabilities or null)) "capabilities are required")
      (require id ["capabilities" "variants"] (variants == "all" || (builtins.isList variants && variants != [] && builtins.all builtins.isString variants)) "must be `all` or a non-empty variant list")
      (require id ["capabilities" "accent"] (builtins.elem (capabilities.accent or "none") ["none" "exact" "all"]) "must be `none`, `exact`, or `all`")
      (require id ["capabilities" "namedOverrides"] (builtins.isBool (capabilities.namedOverrides or false)) "must be boolean")
      (require id ["capabilities" "roleOverrides"] (builtins.isBool (capabilities.roleOverrides or false)) "must be boolean")
      (require id ["capabilities" "transparency"] (builtins.isBool (capabilities.transparency or false)) "must be boolean")
      (require id ["priority"] (builtins.isInt (adapter.priority or 0)) "must be an integer")
      (require id ["autoSafe"] (builtins.isBool (adapter.autoSafe or false)) "must be boolean")
    ];
  in
    if builtins.all (value: value) checks
    then adapter
    else throw "themeBroker: adapter `${id}` failed validation";
}
