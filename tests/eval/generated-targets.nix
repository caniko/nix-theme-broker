{lib}: let
  themeLib = import ../../lib {inherit lib;};
  registry = themeLib.generatedTargets;
  validPlatforms = ["homeManager" "nixos" "darwin"];
  expected = ["alacritty" "bat" "btop" "chromium" "console" "cosmic" "foot" "ghostty" "helix" "kitty" "mpv" "nushell" "obsidian" "opencode" "starship" "tmux" "vscode" "waybar" "zed" "zellij"];
in
  assert builtins.all (name: builtins.hasAttr name registry) expected;
  assert builtins.all (
    target:
      target.platforms
      != []
      && builtins.all (platform: builtins.elem platform validPlatforms) target.platforms
      && builtins.isBool target.autoSafe
      && builtins.elem (target.engine or "stylix") ["stylix" "cosmic-manager"]
  ) (builtins.attrValues registry); true
