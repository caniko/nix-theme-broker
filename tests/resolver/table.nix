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
    roleOverrides ? false,
    nativeOptions ? [],
    class ? null,
    autoSafe ? true,
  }:
    themeLib.mkAdapter ({
        schema = "theme-broker.adapter/v1";
        inherit id target platforms priority;
        provider = "synthetic";
        inherit autoSafe;
        provenance = {
          inherit tier;
          repository = "https://example.invalid/${id}";
          revision = "fixture";
          license = "MIT";
        };
        capabilities = {
          inherit variants accent namedOverrides roleOverrides;
          transparency = false;
          inherit nativeOptions;
        };
      }
      // lib.optionalAttrs (class != null) {inherit class;});
  exact = mk {id = "exact";};
  partial = mk {
    id = "partial";
    accent = "none";
  };
  namedExact = mk {
    id = "named-exact";
    namedOverrides = true;
  };
  nativeExact = mk {
    id = "native-exact";
    class = "complex";
    nativeOptions = ["profile"];
  };
  rawRenderer = {
    schema = "theme-broker.adapter/v1";
    id = "raw-renderer";
    provider = "synthetic";
    target = "editor";
    platforms = ["homeManager"];
    priority = 100;
    autoSafe = true;
    provenance = {
      tier = "local";
      repository = "https://example.invalid/raw-renderer";
      revision = "fixture";
      license = "MIT";
    };
    capabilities = {
      variants = "all";
      accent = "none";
      namedOverrides = false;
      roleOverrides = false;
      transparency = false;
    };
    class = "complex";
    rendererKind = "gruvbox-neovim";
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
    generatedAutoSafe ? true,
    preferNative ? true,
    onUnsupported ? "fallback",
  }: let
    value = themeLib.resolveBackend {
      providerId = "synthetic";
      variantId = "dark";
      targetId = "editor";
      platform = "homeManager";
      inherit generatedAvailable generatedAutoSafe adapters selection;
      policy = {
        inherit allowedNativeTiers;
        inherit requireAccentFidelity;
        requireOverrideFidelity = true;
        inherit preferNative onUnsupported;
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
    adapters = [
      (mk {
        id = "accent-exact";
        accent = "exact";
      })
    ];
    selection = autoSelection // {accent = "blue";};
  };
  r008 = resolve {
    adapters = [partial];
    selection = autoSelection // {accent = "blue";};
    requireAccentFidelity = true;
  };
  r009 = resolve {
    adapters = [namedExact];
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
  r016 = resolve {
    adapters = [
      (mk {
        id = "unsafe";
        autoSafe = false;
      })
    ];
  };
  r017 = resolve {
    adapters = [namedExact];
    selection = autoSelection // {overrides.ansi.normal.black = "#000000";};
  };
  r018 = resolve {
    adapters = [
      (mk {
        id = "rejected";
        tier = "maintained";
      })
      namedExact
    ];
    selection = nativeSelection // {overrides.named.background = "#000000";};
  };
  r019 = resolve {
    adapters = [exact];
    preferNative = false;
  };
  r020 = resolve {
    adapters = [partial];
    selection = autoSelection // {overrides.named.background = "#000000";};
    onUnsupported = "warn";
  };
  r021 = resolve {
    adapters = [partial];
    selection = autoSelection // {overrides.named.background = "#000000";};
    onUnsupported = "error";
  };
  r022 = resolve {generatedAutoSafe = false;};
  r023 = resolve {
    selection = generatedSelection;
    generatedAutoSafe = false;
  };
  r024 = resolve {
    adapters = [exact];
    selection = autoSelection // {nativeOptions.profile = "work";};
  };
  r025 = resolve {
    adapters = [nativeExact];
    selection = autoSelection // {nativeOptions.profile = "work";};
  };
  r026 = resolve {
    adapters = [exact];
    selection = nativeSelection // {nativeOptions.profile = "work";};
  };
  r027 = resolve {adapters = [rawRenderer];};
in
  assert r001.success && r001.value.backend == "generated";
  assert !r002.success;
  assert r003.success && r003.value.backend == "native";
  assert !r004.success;
  assert r005.success && r005.value.adapter == "exact";
  assert r006.success && r006.value.backend == "generated";
  assert r007.success && r007.value.backend == "native" && r007.value.fidelity == "exact";
  assert r008.success && r008.value.backend == "generated" && lib.hasInfix "rejected" (builtins.head (lib.filter (reason: lib.hasPrefix "candidate `partial`" reason) r008.value.reasons));
  assert r009.success && r009.value.backend == "native";
  assert !r010.success && !r011.success && !r012.success;
  assert r013.success && r013.value.adapter == "alpha";
  assert !r014.success;
  assert r015.success && (builtins.length (lib.filter (value: value == "native") [r015.value.backend])) == 1;
  assert r016.success && r016.value.backend == "generated";
  assert r017.success && r017.value.backend == "generated";
  assert r018.success && r018.value.adapter == "named-exact";
  assert r019.success && r019.value.backend == "generated";
  assert r020.success && r020.value.backend == "generated";
  assert !r021.success;
  assert !r022.success;
  assert r023.success && r023.value.backend == "generated";
  assert !r024.success && r025.success && r025.value.adapter == "native-exact" && !r026.success && !r027.success; true
