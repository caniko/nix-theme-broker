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
    overrideRequested = (selection.overrides or {}) != {};
    overrideExact = !overrideRequested || (caps.namedOverrides or false) || (caps.roleOverrides or false);
    fidelity =
      if accentExact && overrideExact
      then "exact"
      else "partial";
    accepted =
      (selection.accent == null || !policy.requireAccentFidelity || accentExact)
      && (!policy.requireOverrideFidelity || overrideExact);
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

  rank = adapter: [
    (
      if (adapter.capabilities or {}).exact or false
      then 0
      else 1
    )
    (tierRank.${adapter.provenance.tier or "community"} or 99)
    (-(adapter.priority or 0))
    adapter.id
  ];

  candidateReason = adapter: grade: "candidate `${adapter.id}`: ${
    if grade.accepted
    then "accepted (${grade.fidelity} fidelity)"
    else "rejected (${grade.fidelity} fidelity)"
  }, trust tier `${adapter.provenance.tier or "community"}`, variants `${toString ((adapter.capabilities or {}).variants or "all")}`";
in {
  inherit aliases canonicalTarget;

  mkAdapter = adapter:
    (target.validate adapter)
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
    graded = lib.sortOn (adapter: rank adapter) (map (adapter: let grade = capabilityMatch {inherit selection adapter policy;}; in adapter // grade // {reason = candidateReason adapter grade;}) matching);
    native = builtins.head (graded ++ [null]);
    requested = selection.backend or "auto";
    backend =
      if requested == "generated"
      then
        if generatedAvailable
        then "generated"
        else throw "themeBroker: target `${canonicalId}` requested generated backend for provider `${providerId}`, variant `${variantId}`, but Stylix has no generated target. Native candidates: ${lib.concatStringsSep "; " (map (candidate: candidate.reason) graded)}"
      else if requested == "native"
      then
        if native == null
        then throw "themeBroker: target `${canonicalId}` requested native backend for provider `${providerId}`, variant `${variantId}`, but no allowed adapter matches. Use backend = \"generated\" or register an allowed adapter."
        else if !(native.accepted or false)
        then throw "themeBroker: target `${canonicalId}` requested native backend for provider `${providerId}`, variant `${variantId}`, but adapter `${native.id}` is ${native.fidelity} fidelity and cannot preserve the requested accent or overrides. Use backend = \"generated\" or relax fidelity policy."
        else "native"
      else if native != null && (native.accepted or false) && policy.preferNative
      then "native"
      else if generatedAvailable
      then
        if native != null && !(native.accepted or false) && (policy.onUnsupported or "fallback") == "error"
        then throw "themeBroker: target `${canonicalId}` has an unsupported native candidate; set backend = \"generated\" or allow partial fidelity"
        else if native != null && !(native.accepted or false) && (policy.onUnsupported or "fallback") == "warn"
        then lib.warn "themeBroker: target `${canonicalId}` is falling back to Stylix because native fidelity is unsupported" "generated"
        else "generated"
      else if native != null && (native.accepted or false)
      then "native"
      else throw "themeBroker: target `${canonicalId}` has neither a generated Stylix target nor an allowed native adapter for provider `${providerId}` variant `${variantId}`. Candidates: ${lib.concatStringsSep "; " (map (candidate: candidate.reason) graded)}";
    rejectionReasons = map (candidate: candidate.reason) graded;
  in {
    target = canonicalId;
    requestedBackend = requested;
    inherit backend;
    adapter =
      if backend == "native"
      then native.id
      else null;
    fidelity =
      if backend == "native"
      then native.fidelity
      else "exact";
    provider = providerId;
    variant = variantId;
    accent = selection.accent;
    candidates = rejectionReasons;
    reasons =
      if backend == "native"
      then [
        "native adapter supports the selected variant"
        "trust tier `${native.provenance.tier or "community"}` is allowed"
        "native backend policy selected `${native.id}`"
      ]
      else if native == null
      then ["Stylix generated target selected" "no matching native adapter was registered"]
      else ["Stylix generated target selected" "native candidate `${native.id}` did not meet fidelity policy"] ++ rejectionReasons;
  };
}
