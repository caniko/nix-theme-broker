{lib}: let
  manifest = import ../../native/catppuccin/manifest.nix;
  adapters = import ../../native/catppuccin/default.nix {inherit manifest;};
  classes = lib.unique (map (target: target.class or "simple") (builtins.attrValues manifest.targets));
  targets = builtins.attrValues manifest.targets;
  rendererKinds = ["simple" "vscode-profile" "firefox-profile"];
  profileRendererKinds = ["vscode-profile" "firefox-profile"];
  vscodeTargets = ["vscode" "cursor" "vscodium" "windsurf" "kiro" "antigravity"];
  vscodeRenderer = target:
    import ../../native/catppuccin/home-manager/vscode.nix {
      inherit target;
      profile = "work";
    };
  firefoxRenderer = import ../../native/catppuccin/home-manager/firefox.nix {profile = "work";};
  representative = {
    simple = "alacritty";
    complex = "firefox";
  };
in
  assert builtins.length (builtins.attrNames manifest.targets) >= 80;
  assert builtins.all (name: builtins.hasAttr name manifest.targets) (builtins.attrValues representative);
  assert builtins.all (target: target.optionPath != [] && target.platforms != []) targets;
  assert builtins.all (target: builtins.elem target.rendererKind rendererKinds) targets;
  assert builtins.all (adapter: builtins.elem adapter.rendererKind rendererKinds) adapters;
  assert builtins.all (name: manifest.targets.${name}.rendererKind == "vscode-profile") vscodeTargets;
  assert manifest.targets.firefox.rendererKind == "firefox-profile";
  assert builtins.all (target: target.profiles == builtins.elem target.rendererKind profileRendererKinds) targets;
  assert builtins.all (name: lib.hasAttrByPath ["catppuccin" name "profiles" "work" "enable"] (vscodeRenderer name)) vscodeTargets;
  assert builtins.all (name: !((vscodeRenderer name) ? programs)) vscodeTargets;
  assert firefoxRenderer.catppuccin.firefox.profiles.work.enable;
  assert firefoxRenderer.programs.firefox.profiles ? work;
  assert builtins.elem "simple" classes && builtins.elem "complex" classes; true
