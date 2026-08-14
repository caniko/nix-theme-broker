{
  enabled ? true,
  lib,
  profile ? "default",
  ...
}: {
  programs.firefox.profiles = lib.mkIf enabled {${profile} = {};};
  catppuccin.firefox.profiles = lib.mkIf enabled {${profile}.enable = true;};
}
