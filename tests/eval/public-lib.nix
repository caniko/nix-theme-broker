{
  lib,
  providers,
  adapters,
  publicLib,
}: let
  themeLib = publicLib;
  selected = themeLib.resolveSelection {
    inherit providers;
    selection = {
      provider = "gruvbox";
      variant = "dark-hard";
      accent = null;
    };
  };
  builtinResolution = themeLib.resolveBackend {
    providerId = "gruvbox";
    variantId = "dark-hard";
    selection = {
      backend = "native";
      accent = null;
      overrides = {};
    };
    targetId = "neovim";
    platform = "homeManager";
    inherit adapters;
    policy = {
      allowedNativeTiers = ["maintained"];
      requireAccentFidelity = false;
      requireOverrideFidelity = true;
      preferNative = true;
    };
  };
  builtin = lib.findFirst (adapter: adapter.id == "gruvbox-neovim") {} adapters;
  forgedBuiltin = builtin // {priority = (builtin.priority or 0) + 1;};
  forgedResolution = builtins.tryEval (builtins.deepSeq (themeLib.resolveBackend {
      providerId = "gruvbox";
      variantId = "dark-hard";
      selection = {
        backend = "native";
        accent = null;
        overrides = {};
      };
      targetId = "neovim";
      platform = "homeManager";
      adapters = [forgedBuiltin];
      policy = {
        allowedNativeTiers = ["maintained"];
        requireAccentFidelity = false;
        requireOverrideFidelity = true;
        preferNative = true;
      };
    })
    true);
  legacyTrustedResolution = themeLib.resolveBackend {
    providerId = "gruvbox";
    variantId = "dark-hard";
    selection = {
      backend = "native";
      accent = null;
      overrides = {};
    };
    targetId = "neovim";
    platform = "homeManager";
    trustedAdapters = adapters;
    policy = {
      allowedNativeTiers = ["maintained"];
      requireAccentFidelity = false;
      requireOverrideFidelity = true;
      preferNative = true;
    };
  };
  duplicateIdResolution = builtins.tryEval (builtins.deepSeq (themeLib.resolveBackend {
      providerId = "gruvbox";
      variantId = "dark-hard";
      selection = {
        backend = "native";
        accent = null;
        overrides = {};
      };
      targetId = "neovim";
      platform = "homeManager";
      adapters = [builtin forgedBuiltin];
      policy = {
        allowedNativeTiers = ["maintained"];
        requireAccentFidelity = false;
        requireOverrideFidelity = true;
        preferNative = true;
      };
    })
    true);
  # A custom descriptor that reuses a built-in ID without the built-in itself,
  # and without the reserved renderer kind, must still be rejected.
  forgedIdAdapter = lib.removeAttrs (builtin // {capabilities = builtin.capabilities // {namedOverrides = true;};}) ["rendererKind"];
  reservedIdResolution = builtins.tryEval (builtins.deepSeq (themeLib.resolveBackend {
      providerId = "gruvbox";
      variantId = "dark-hard";
      selection = {
        backend = "native";
        accent = null;
        overrides = {};
      };
      targetId = "neovim";
      platform = "homeManager";
      adapters = [forgedIdAdapter];
      policy = {
        allowedNativeTiers = ["maintained"];
        requireAccentFidelity = false;
        requireOverrideFidelity = true;
        preferNative = true;
      };
    })
    true);
  # A modified built-in passed through the legacy trustedAdapters argument must
  # not bypass custom validation.
  forgedTrustedResolution = builtins.tryEval (builtins.deepSeq (themeLib.resolveBackend {
      providerId = "gruvbox";
      variantId = "dark-hard";
      selection = {
        backend = "native";
        accent = null;
        overrides = {};
      };
      targetId = "neovim";
      platform = "homeManager";
      trustedAdapters = [forgedBuiltin];
      policy = {
        allowedNativeTiers = ["maintained"];
        requireAccentFidelity = false;
        requireOverrideFidelity = true;
        preferNative = true;
      };
    })
    true);
  # A valid custom adapter with a distinct ID still composes with built-ins.
  customAdapter =
    (lib.removeAttrs builtin ["rendererKind"])
    // {
      id = "custom-neovim";
      priority = 99;
      capabilities = builtin.capabilities // {namedOverrides = true;};
    };
  mixedResolution = builtins.tryEval (builtins.deepSeq (themeLib.resolveBackend {
      providerId = "gruvbox";
      variantId = "dark-hard";
      selection = {
        backend = "native";
        accent = null;
        overrides = {};
      };
      targetId = "neovim";
      platform = "homeManager";
      adapters = adapters ++ [customAdapter];
      policy = {
        allowedNativeTiers = ["maintained"];
        requireAccentFidelity = false;
        requireOverrideFidelity = true;
        preferNative = true;
      };
    })
    true);
in
  assert builtins.isAttrs selected;
  assert builtins.isAttrs selected.formatted.base16Scheme;
  assert builtins.isAttrs themeLib.types;
  assert builtins.isAttrs themeLib.projection;
  assert builtinResolution.backend == "native";
  assert builtinResolution.adapter == "gruvbox-neovim";
  assert !forgedResolution.success;
  assert legacyTrustedResolution.backend == "native";
  assert legacyTrustedResolution.adapter == "gruvbox-neovim";
  assert !duplicateIdResolution.success;
  assert !reservedIdResolution.success;
  assert !forgedTrustedResolution.success;
  assert mixedResolution.success;
    builtins.toJSON selected != ""
