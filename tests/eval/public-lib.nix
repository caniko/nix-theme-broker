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
    builtins.toJSON selected != ""
