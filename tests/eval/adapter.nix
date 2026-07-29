{lib}: let
  themeLib = import ../../lib {inherit lib;};
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
  valid = themeLib.mkAdapter base;
  invalid = builtins.tryEval (themeLib.mkAdapter (base // {capabilities = base.capabilities // {accent = "partial";};}));
in
  assert valid.target == "neovim";
  assert !invalid.success; true
