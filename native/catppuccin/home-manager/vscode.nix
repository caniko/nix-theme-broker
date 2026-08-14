{
  target ? "vscode",
  profile ? "default",
  ...
}: {
  catppuccin.${target}.profiles.${profile} = {
    enable = true;
    icons.enable = true;
  };
}
