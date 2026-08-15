{lib}: let
  target = import ./target.nix {inherit lib;};
  tierRank = {
    official = 0;
    canonical = 1;
    maintained = 2;
    local = 3;
    community = 4;
  };
  aliases = {
    code = "vscode";
    nvim = "neovim";
    tty = "console";
    zed-editor = "zed";
  };

  canonicalTarget = target: aliases.${target} or target;
  variantsMatch = supported: variant:
    supported == "all" || builtins.elem variant supported;
  capabilityMatch = {
    selection,
    adapter,
    policy,
  }: let
    caps = adapter.capabilities or {};
    accentExact = selection.accent == null || (caps.accent or "none") == "all" || (caps.accent or "none") == "exact";
    overrides = selection.overrides or {};
    nativeOptions = selection.nativeOptions or {};
    nativeOptionsExact = builtins.all (key: builtins.elem key (caps.nativeOptions or [])) (builtins.attrNames nativeOptions);
    overrideExact =
      ((overrides.named or {}) == {} || (caps.namedOverrides or false))
      && ((overrides.roles or {}) == {} || (caps.roleOverrides or false))
      && (overrides.ansi or {}) == {}
      && (overrides.base16 or {}) == {}
      && (overrides.base24 or {}) == {};
    fidelity =
      if accentExact && overrideExact && nativeOptionsExact
      then "exact"
      else "partial";
    accepted =
      (selection.accent == null || !policy.requireAccentFidelity || accentExact)
      && (!policy.requireOverrideFidelity || overrideExact)
      && nativeOptionsExact;
  in {
    inherit fidelity accepted;
  };

  adapterMatches = {
    adapter,
    providerId,
    targetId,
    variantId,
    platform,
    allowedTiers,
  }:
    adapter.provider
    == providerId
    && canonicalTarget adapter.target == targetId
    && builtins.elem platform (adapter.platforms or [])
    && variantsMatch ((adapter.capabilities or {}).variants or "all") variantId
    && builtins.elem (adapter.provenance.tier or "community") allowedTiers;

  rank = candidate: [
    (
      if candidate.accepted
      then 0
      else 1
    )
    (
      if candidate.fidelity == "exact"
      then 0
      else 1
    )
    (tierRank.${candidate.provenance.tier or "community"} or 99)
    (-(candidate.priority or 0))
    candidate.id
  ];

  candidateReason = adapter: grade: "candidate `${adapter.id}`: ${
    if grade.accepted
    then "accepted (${grade.fidelity} fidelity)"
    else "rejected (${grade.fidelity} fidelity)"
  }, trust tier `${adapter.provenance.tier or "community"}`, variants `${toString ((adapter.capabilities or {}).variants or "all")}`";
in {
  inherit aliases canonicalTarget;

  mkAdapter = adapter:
    (target.validate {inherit adapter;})
    // {
      target = canonicalTarget adapter.target;
    };
  mkBuiltinAdapter = adapter:
    (target.validate {
      inherit adapter;
      allowBuiltinRenderer = true;
    })
    // {
      target = canonicalTarget adapter.target;
    };

  resolve = {
    providerId,
    variantId,
    selection,
    targetId,
    platform,
    generatedAvailable ? true,
    generatedAutoSafe ? true,
    adapters ? [],
    policy,
  }: let
    canonicalId = canonicalTarget targetId;
    matching =
      builtins.filter (
        adapter:
          adapterMatches {
            inherit adapter providerId variantId platform;
            targetId = canonicalId;
            allowedTiers = policy.allowedNativeTiers;
          }
      )
      adapters;
    graded = lib.sortOn rank (map (adapter: let grade = capabilityMatch {inherit selection adapter policy;}; in adapter // grade // {reason = candidateReason adapter grade;}) matching);
    candidate = builtins.head (graded ++ [null]);
    native = lib.findFirst (candidate: candidate.accepted or false) null graded;
    automaticNative =
      lib.findFirst (
        candidate:
          (candidate.accepted or false)
          && candidate.fidelity == "exact"
          && (candidate.autoSafe or false)
      )
      null
      graded;
    requested = selection.backend or "auto";
    nativeOptionsRequested = (selection.nativeOptions or {}) != {};
    backend =
      if requested == "generated"
      then
        if generatedAvailable
        then "generated"
        else throw "themeBroker: target `${canonicalId}` requested generated backend for provider `${providerId}`, variant `${variantId}`, but Stylix has no generated target. Native candidates: ${lib.concatStringsSep "; " (map (candidate: candidate.reason) graded)}"
      else if requested == "native"
      then
        if candidate == null
        then throw "themeBroker: target `${canonicalId}` requested native backend for provider `${providerId}`, variant `${variantId}`, but no allowed adapter matches. Use backend = \"generated\" or register an allowed adapter."
        else if native == null
        then throw "themeBroker: target `${canonicalId}` requested native backend for provider `${providerId}`, variant `${variantId}`, but adapter `${candidate.id}` is ${candidate.fidelity} fidelity and cannot preserve the requested accent or overrides. Use backend = \"generated\" or relax fidelity policy."
        else "native"
      else if automaticNative != null && policy.preferNative
      then "native"
      else if generatedAvailable && generatedAutoSafe
      then
        if native == null && candidate != null && (policy.onUnsupported or "fallback") == "error"
        then throw "themeBroker: target `${canonicalId}` has an unsupported native candidate; set backend = \"generated\" or allow partial fidelity"
        else if native == null && candidate != null && (policy.onUnsupported or "fallback") == "warn"
        then lib.warn "themeBroker: target `${canonicalId}` is falling back to Stylix because native fidelity is unsupported" "generated"
        else "generated"
      else if automaticNative != null
      then "native"
      else throw "themeBroker: target `${canonicalId}` has neither an automatically safe generated Stylix target nor an allowed native adapter for provider `${providerId}` variant `${variantId}`. Candidates: ${lib.concatStringsSep "; " (map (candidate: candidate.reason) graded)}";
    _nativeOptionsCheck =
      if nativeOptionsRequested && backend != "native"
      then throw "themeBroker: target `${canonicalId}` requested nativeOptions that no selected native adapter can consume. Set backend = \"native\" and register an adapter declaring those options, or remove nativeOptions. Candidates: ${lib.concatStringsSep "; " (map (candidate: candidate.reason) graded)}"
      else true;
    rejectionReasons = map (candidate: candidate.reason) graded;
  in
    builtins.seq _nativeOptionsCheck {
      target = canonicalId;
      requestedBackend = requested;
      inherit backend;
      adapter =
        if backend == "native"
        then
          if requested == "auto"
          then automaticNative.id
          else native.id
        else null;
      fidelity =
        if backend == "native"
        then
          if requested == "auto"
          then automaticNative.fidelity
          else native.fidelity
        else "exact";
      provider = providerId;
      variant = variantId;
      accent = selection.accent;
      candidates = rejectionReasons;
      reasons =
        if backend == "native"
        then [
          "native adapter supports the selected variant"
          "trust tier `${(
            if requested == "auto"
            then automaticNative
            else native
          ).provenance.tier or "community"}` is allowed"
          "native backend policy selected `${
            if requested == "auto"
            then automaticNative.id
            else native.id
          }`"
        ]
        else if native == null
        then
          ["Stylix generated target selected"]
          ++ (
            if rejectionReasons == []
            then ["no matching native adapter was registered"]
            else ["native candidates did not meet selection policy"] ++ rejectionReasons
          )
        else ["Stylix generated target selected" "native candidate `${native.id}` did not meet automatic-selection policy"] ++ rejectionReasons;
    };
}
