{
  lib,
  pkgs,
  selected,
}: let
  themeNames = {
    "dark-hard" = "Gruvbox Dark Hard";
    "dark-medium" = "Gruvbox Dark Medium";
    "dark-soft" = "Gruvbox Dark Soft";
    "light-hard" = "Gruvbox Light Hard";
    "light-medium" = "Gruvbox Light Medium";
    "light-soft" = "Gruvbox Light Soft";
  };
  iconTheme = import ./vscode-icons.nix {inherit lib pkgs;};
in {
  programs.vscode.profiles.default = {
    extensions = lib.mkAfter [
      pkgs.vscode-extensions.jdinhlife.gruvbox
      iconTheme
    ];
    userSettings = {
      "workbench.colorTheme" = lib.mkForce themeNames.${selected.variant};
      "workbench.iconTheme" = lib.mkForce "gruvbox-material-icons";
    };
  };

  stylix.targets.vscode.enable = lib.mkForce false;
}
