{
  enabled ? true,
  lib,
  target ? "vscode",
  profile ? "default",
  ...
}: {
  catppuccin.${target}.profiles = lib.mkIf enabled {
    ${profile} = {
      enable = true;
      icons.enable = true;
    };
  };
}
