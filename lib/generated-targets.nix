{
  alacritty = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  bat = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  blender = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  btop = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  # Stylix owns the NixOS policy; the broker renders the Home Manager theme
  # extension itself, so the engine is chosen per platform.
  chromium = {
    platforms = ["homeManager" "nixos"];
    autoSafe = true;
    engines.homeManager = "chrome-theme";
  };
  brave = {
    platforms = ["homeManager"];
    autoSafe = true;
    engine = "chrome-theme";
  };
  console = {
    platforms = ["nixos"];
    autoSafe = true;
  };
  floorp = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  font-packages = {
    platforms = ["homeManager" "nixos"];
    autoSafe = true;
  };
  fontconfig = {
    platforms = ["homeManager" "nixos"];
    autoSafe = false;
  };
  foot = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  ghostty = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  helix = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  k9s = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  kitty = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  mpv = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  nushell = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  obsidian = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  opencode = {
    platforms = ["homeManager"];
    autoSafe = true;
    engine = "opencode-v2";
  };
  qt = {
    platforms = ["homeManager" "nixos"];
    autoSafe = false;
  };
  rio = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  starship = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  tmux = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  waybar = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  vscode = {
    platforms = ["homeManager"];
    autoSafe = false;
  };
  zed = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  zellij = {
    platforms = ["homeManager"];
    autoSafe = true;
  };
  cosmic = {
    platforms = ["homeManager"];
    autoSafe = true;
    engine = "cosmic-manager";
  };
}
