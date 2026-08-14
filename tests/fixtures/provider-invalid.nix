{lib}: let
  themeLib = import ../../lib {inherit lib;};
  valid = import ./provider-valid.nix {inherit lib;};
  rejects = provider: !(builtins.tryEval (builtins.deepSeq (themeLib.mkProvider provider) true)).success;
in
  assert rejects (removeAttrs valid ["name"]);
  assert rejects (removeAttrs valid ["description"]);
    valid // {variants.dark.roles.ui.background = "@missing";}
