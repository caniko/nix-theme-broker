{lib}: let
  manifest = import ../../native/catppuccin/manifest.nix;
  classes = lib.unique (map (target: target.class or "simple") (builtins.attrValues manifest.targets));
  representative = {
    simple = "alacritty";
    complex = "firefox";
  };
in
  assert builtins.length (builtins.attrNames manifest.targets) >= 80;
  assert builtins.all (name: builtins.hasAttr name manifest.targets) (builtins.attrValues representative);
  assert builtins.all (target: target.optionPath != [] && target.platforms != []) (builtins.attrValues manifest.targets);
  assert builtins.elem "simple" classes && builtins.elem "complex" classes; true
