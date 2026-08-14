{profile ? "default", ...}: {
  programs.firefox.profiles.${profile} = {};
  catppuccin.firefox.profiles.${profile}.enable = true;
}
