{lib}: let
  themeLib = import ../../lib {inherit lib;};
  adapterLib = import ../../lib/adapter.nix {inherit lib;};
  base = {
    schema = "theme-broker.adapter/v1";
    id = "fixture";
    provider = "synthetic";
    target = "nvim";
    platforms = ["homeManager"];
    priority = 10;
    autoSafe = true;
    provenance = {
      tier = "local";
      repository = "https://example.invalid/fixture";
      revision = "fixture";
      license = "MIT";
    };
    capabilities = {
      variants = ["dark"];
      accent = "none";
      namedOverrides = false;
      roleOverrides = false;
      transparency = true;
    };
  };
  valid = themeLib.mkAdapter (base
    // {
      class = "simple";
      optionPath = ["programs" "fixture"];
      optionValues = {enable = true;};
      module = "fixture";
    });
  descriptor = themeLib.mkAdapter base;
  complex = themeLib.mkAdapter (base // {class = "complex";});
  builtinRenderer = adapterLib.mkBuiltinAdapter (base
    // {
      id = "gruvbox-neovim";
      provider = "gruvbox";
      target = "neovim";
      class = "complex";
      rendererKind = "gruvbox-neovim";
    });
  rejects = adapter: !(builtins.tryEval (builtins.deepSeq (themeLib.mkAdapter adapter) true)).success;
in
  assert valid.target == "neovim";
  assert descriptor.id == "fixture";
  assert complex.class == "complex";
  assert builtinRenderer.rendererKind == "gruvbox-neovim";
  assert rejects (base
    // {
      id = "gruvbox-neovim";
      provider = "gruvbox";
      target = "neovim";
      class = "complex";
      rendererKind = "gruvbox-neovim";
    });
  assert rejects (base
    // {
      id = "gruvbox-neovim";
      provider = "gruvbox";
      target = "neovim";
      class = "complex";
      rendererKind = "gruvbox-neovim";
      _themeBrokerBuiltin = true;
    });
  assert rejects (base // {capabilities = base.capabilities // {accent = "partial";};});
  assert rejects (base // {capabilities = base.capabilities // {variants = [""];};});
  assert rejects (base // {capabilities = base.capabilities // {exact = "yes";};});
  assert rejects (base // {class = "other";});
  assert rejects (base // {class = null;});
  assert rejects (base // {class = "simple";});
  assert rejects (base // {optionPath = ["programs" "fixture"];});
  assert rejects (base
    // {
      class = "simple";
      optionPath = ["programs" ""];
    });
  assert rejects (base // {optionValues = {};});
  assert rejects (base // {module = null;});
  assert rejects (base
    // {
      class = "complex";
      rendererKind = "gruvbox-neovim";
    });
  assert rejects (base // {capabilities = base.capabilities // {nativeOptions = [""];};});
  assert rejects (base
    // {
      class = "simple";
      optionPath = ["programs" "fixture"];
      optionValues = [];
    });
  assert rejects (base // {module = {};}); true
