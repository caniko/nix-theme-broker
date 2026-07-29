{lib}: let
  themeLib = import ../../lib {inherit lib;};
  mk = {
    id,
    target ? "editor",
    platforms ? ["homeManager"],
    tier ? "local",
    priority ? 0,
    variants ? "all",
    accent ? "none",
    namedOverrides ? false,
  }:
    themeLib.mkAdapter {
      schema = "theme-broker.adapter/v1";
      inherit id target platforms priority;
      provider = "synthetic";
      autoSafe = true;
      provenance = {
        inherit tier;
        repository = "https://example.invalid/${id}";
        revision = "fixture";
        license = "MIT";
      };
      capabilities = {
        inherit variants accent namedOverrides;
        roleOverrides = false;
        transparency = false;
      };
    };
  exact = mk {id = "exact";};
  partial = mk {
    id = "partial";
    accent = "none";
  };
  generatedSelection = {
    backend = "generated";
    accent = null;
    overrides = {};
  };
  nativeSelection = {
    backend = "native";
    accent = null;
    overrides = {};
  };
  autoSelection = {
    backend = "auto";
    accent = null;
    overrides = {};
  };
  resolve = {
    selection ? autoSelection,
    generatedAvailable ? true,
    adapters ? [],
    requireAccentFidelity ? false,
    allowedNativeTiers ? ["local" "maintained"],
  }: let
    value = themeLib.resolveBackend {
      providerId = "synthetic";
      variantId = "dark";
      targetId = "editor";
      platform = "homeManager";
      inherit generatedAvailable adapters selection;
      policy = {
        inherit allowedNativeTiers;
        inherit requireAccentFidelity;
        requireOverrideFidelity = true;
        preferNative = true;
      };
    };
  in
    builtins.tryEval (builtins.seq value.backend value);
  r001 = resolve {selection = generatedSelection;};
  r002 = resolve {
    selection = generatedSelection;
    generatedAvailable = false;
  };
  r003 = resolve {
    selection = nativeSelection;
    adapters = [exact];
  };
  r004 = resolve {
    selection = nativeSelection;
    adapters = [];
  };
  r005 = resolve {adapters = [exact];};
  r006 = resolve {
    adapters = [partial];
    selection = autoSelection // {overrides = {named.background = "#000000";};};
  };
  r007 = resolve {
    adapters = [partial];
    selection = autoSelection // {accent = "blue";};
  };
  r008 = resolve {
    adapters = [partial];
    selection = autoSelection // {accent = "blue";};
    requireAccentFidelity = true;
  };
  r009 = resolve {
    adapters = [exact];
    selection = autoSelection // {overrides = {named.background = "#000000";};};
  };
  r010 = resolve {
    adapters = [
      (mk {
        id = "community";
        tier = "community";
      })
    ];
    allowedNativeTiers = ["local"];
    generatedAvailable = false;
  };
  r011 = resolve {
    adapters = [
      (mk {
        id = "darwin-only";
        platforms = ["darwin"];
      })
    ];
    generatedAvailable = false;
  };
  r012 = resolve {
    adapters = [
      (mk {
        id = "other-variant";
        variants = ["light"];
      })
    ];
    generatedAvailable = false;
  };
  r013 = resolve {
    adapters = [
      (mk {
        id = "zeta";
        priority = 10;
      })
      (mk {
        id = "alpha";
        priority = 10;
      })
    ];
  };
  # R-014: a coordinator that has no generated target and no native candidate
  # must activate nothing rather than inventing a backend.
  r014 = resolve {
    generatedAvailable = false;
    adapters = [];
  };
  # R-015: a successful resolution has exactly one selected backend.
  r015 = resolve {adapters = [exact];};
in
  assert r001.success && r001.value.backend == "generated";
  assert !r002.success;
  assert r003.success && r003.value.backend == "native";
  assert !r004.success;
  assert r005.success && r005.value.adapter == "exact";
  assert r006.success && r006.value.backend == "generated";
  assert r007.success && r007.value.backend == "native" && r007.value.fidelity == "partial";
  assert r008.success && r008.value.backend == "generated";
  assert r009.success && r009.value.backend == "generated";
  assert !r010.success && !r011.success && !r012.success;
  assert r013.success && r013.value.adapter == "alpha";
  assert !r014.success;
  assert r015.success && (builtins.length (lib.filter (value: value == "native") [r015.value.backend])) == 1; true
