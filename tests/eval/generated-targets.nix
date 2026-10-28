{lib}: let
  themeLib = import ../../lib {inherit lib;};
  registry = themeLib.generatedTargets;
  validPlatforms = ["homeManager" "nixos" "darwin"];
  expected = ["alacritty" "bat" "blender" "btop" "chromium" "console" "cosmic" "floorp" "font-packages" "fontconfig" "foot" "ghostty" "helix" "k9s" "kitty" "mpv" "nushell" "obsidian" "opencode" "qt" "rio" "starship" "tmux" "vscode" "waybar" "zed" "zellij"];
in
  assert builtins.all (name: builtins.hasAttr name registry) expected;
  assert !registry.vscode.autoSafe;
  assert !registry.qt.autoSafe && !registry.fontconfig.autoSafe;
  assert registry.qt.platforms == ["homeManager" "nixos"];
  assert registry.opencode.engine == "opencode-v2";
  assert builtins.all (
    target:
      target.platforms
      != []
      && builtins.all (platform: builtins.elem platform validPlatforms) target.platforms
      && builtins.isBool target.autoSafe
      && builtins.elem (target.engine or "stylix") ["stylix" "cosmic-manager" "opencode-v2"]
  ) (builtins.attrValues registry); true
