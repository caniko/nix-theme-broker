{lib}: let
  tiers = ["official" "canonical" "maintained" "community" "local"];
  platforms = ["homeManager" "nixos" "darwin"];
  rendererOwners = {
    "vscode-profile" = {
      "catppuccin-antigravity" = {
        provider = "catppuccin";
        target = "antigravity";
      };
      "catppuccin-cursor" = {
        provider = "catppuccin";
        target = "cursor";
      };
      "catppuccin-kiro" = {
        provider = "catppuccin";
        target = "kiro";
      };
      "catppuccin-vscode" = {
        provider = "catppuccin";
        target = "vscode";
      };
      "catppuccin-vscodium" = {
        provider = "catppuccin";
        target = "vscodium";
      };
      "catppuccin-windsurf" = {
        provider = "catppuccin";
        target = "windsurf";
      };
    };
    "firefox-profile" = {
      "catppuccin-firefox" = {
        provider = "catppuccin";
        target = "firefox";
      };
    };
    "gruvbox-cursors" = {
      "gruvbox-cursors" = {
        provider = "gruvbox";
        target = "cursors";
      };
    };
    "gruvbox-neovim" = {
      "gruvbox-neovim" = {
        provider = "gruvbox";
        target = "neovim";
      };
    };
    "gruvbox-vim" = {
      "gruvbox-vim" = {
        provider = "gruvbox";
        target = "vim";
      };
    };
    "gruvbox-vscode" = {
      "gruvbox-vscode" = {
        provider = "gruvbox";
        target = "vscode";
      };
    };
  };
  require = id: path: condition: message:
    if condition
    then true
    else throw "themeBroker: adapter `${id}` at `${lib.concatStringsSep "." path}`: ${message}";
  validOptionPath = optionPath:
    builtins.isList optionPath
    && optionPath != []
    && builtins.all (part: builtins.isString part && part != "") optionPath;
  rendererOwner = adapter: let
    rendererKind = adapter.rendererKind or null;
    owner =
      if rendererKind == null
      then null
      else (rendererOwners.${rendererKind} or {}).${adapter.id} or null;
  in
    owner
    != null
    && owner.provider == (adapter.provider or null)
    && owner.target == (adapter.target or null);
  rendererSupported = adapter: let
    class = adapter.class or "simple";
    rendererKind = adapter.rendererKind or null;
  in
    (class == "simple" && validOptionPath (adapter.optionPath or null) && (rendererKind == null || rendererKind == "simple"))
    || (class == "complex" && rendererOwner adapter);
in {
  inherit rendererOwners rendererSupported;

  validate = {
    adapter,
    allowBuiltinRenderer ? false,
  }: let
    id = adapter.id or "<missing>";
    provenance = adapter.provenance or {};
    capabilities = adapter.capabilities or {};
    variants = capabilities.variants or "all";
    class = adapter.class or null;
    optionPath = adapter.optionPath or null;
    optionValues = adapter.optionValues or null;
    module = adapter.module or null;
    rendererKind = adapter.rendererKind or null;
    hasClass = adapter ? class;
    hasOptionPath = adapter ? optionPath;
    hasOptionValues = adapter ? optionValues;
    hasModule = adapter ? module;
    hasRendererKind = adapter ? rendererKind;
    checks = [
      (require id ["schema"] ((adapter.schema or null) == "theme-broker.adapter/v1") "unsupported schema")
      (require id ["id"] (builtins.match "[a-z0-9][a-z0-9-]*" id != null) "invalid adapter ID")
      (require id ["provider"] (builtins.isString (adapter.provider or null)) "provider is required")
      (require id ["target"] (builtins.isString (adapter.target or null)) "target is required")
      (require id ["platforms"] (builtins.isList (adapter.platforms or []) && (adapter.platforms or []) != []) "at least one platform is required")
      (require id ["platforms"] (builtins.all (platform: builtins.elem platform platforms) (adapter.platforms or [])) "unknown platform")
      (require id ["provenance" "tier"] (builtins.elem (provenance.tier or null) tiers) "unknown trust tier")
      (require id ["provenance" "repository"] (builtins.isString (provenance.repository or null) && (provenance.repository or "") != "") "a non-empty repository is required")
      (require id ["provenance" "revision"] (builtins.isString (provenance.revision or null)) "revision is required")
      (require id ["provenance" "license"] (builtins.isString (provenance.license or null)) "license is required")
      (require id ["capabilities"] (builtins.isAttrs (adapter.capabilities or null)) "capabilities are required")
      (require id ["capabilities" "variants"] (variants == "all" || (builtins.isList variants && variants != [] && builtins.all (variant: builtins.isString variant && variant != "") variants)) "must be `all` or a non-empty variant list")
      (require id ["capabilities" "accent"] (builtins.elem (capabilities.accent or "none") ["none" "exact" "all"]) "must be `none`, `exact`, or `all`")
      (require id ["capabilities" "namedOverrides"] (builtins.isBool (capabilities.namedOverrides or false)) "must be boolean")
      (require id ["capabilities" "roleOverrides"] (builtins.isBool (capabilities.roleOverrides or false)) "must be boolean")
      (require id ["capabilities" "transparency"] (builtins.isBool (capabilities.transparency or false)) "must be boolean")
      (require id ["capabilities" "exact"] (builtins.isBool (capabilities.exact or false)) "must be boolean")
      (require id ["capabilities" "nativeOptions"] (builtins.isList (capabilities.nativeOptions or []) && builtins.all (option: builtins.isString option && option != "") (capabilities.nativeOptions or []) && builtins.length (capabilities.nativeOptions or []) == builtins.length (lib.unique (capabilities.nativeOptions or []))) "must be a list of unique non-empty strings")
      (require id ["class"] (!hasClass || builtins.elem class ["simple" "complex"]) "must be `simple` or `complex`")
      (require id ["class"] (!hasClass || class != "simple" || validOptionPath optionPath) "simple renderers require optionPath")
      (require id ["optionPath"] (!hasOptionPath || (hasClass && validOptionPath optionPath)) "requires a renderer class and a non-empty string path")
      (require id ["optionValues"] (!hasOptionValues || (hasOptionPath && builtins.isAttrs optionValues)) "requires optionPath and an attribute set")
      (require id ["module"] (!hasModule || (builtins.isString module && module != "")) "must be a non-empty string")
      (require id ["rendererKind"] (!hasRendererKind || builtins.elem rendererKind ["simple" "vscode-profile" "firefox-profile" "gruvbox-vim" "gruvbox-neovim" "gruvbox-vscode" "gruvbox-cursors"]) "unknown renderer kind")
      (require id ["rendererKind"] (!hasRendererKind || rendererKind == "simple" || (allowBuiltinRenderer && rendererOwner adapter)) "renderer kind is reserved for its built-in adapter")
      (require id ["rendererKind"] (!hasRendererKind || rendererSupported adapter) "renderer kind does not have a compatible renderer")
      (require id ["rendererKind"] (!builtins.elem rendererKind ["vscode-profile" "firefox-profile"] || class == "complex") "profile renderers require class `complex`")
      (require id ["rendererKind"] (!builtins.elem rendererKind ["vscode-profile" "firefox-profile"] || (capabilities.profiles or false)) "profile renderers require profile capability")
      (require id ["priority"] (builtins.isInt (adapter.priority or 0)) "must be an integer")
      (require id ["autoSafe"] (builtins.isBool (adapter.autoSafe or false)) "must be boolean")
    ];
  in
    if builtins.all (value: value) checks
    then adapter
    else throw "themeBroker: adapter `${id}` failed validation";
}
