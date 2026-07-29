{lib}: let
  themeLib = import ../../lib {inherit lib;};
  registry = themeLib.generatedTargets;
  validPlatforms = ["homeManager" "nixos" "darwin"];
  expected = ["alacritty" "bat" "console" "foot" "ghostty" "helix" "kitty" "vscode" "waybar"];
in
  assert builtins.all (name: builtins.hasAttr name registry) expected;
  assert builtins.all (
    target:
      target.platforms
      != []
      && builtins.all (platform: builtins.elem platform validPlatforms) target.platforms
      && builtins.isBool target.autoSafe
  ) (builtins.attrValues registry); true
