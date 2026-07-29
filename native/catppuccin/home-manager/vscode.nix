{
  lib,
  pkgs,
  selected,
}: let
  themeNames = {
    latte = "Catppuccin Latte";
    frappe = "Catppuccin Frappé";
    macchiato = "Catppuccin Macchiato";
    mocha = "Catppuccin Mocha";
  };
in {
  catppuccin.vscode.profiles.default = {
    enable = lib.mkForce false;
    icons.enable = lib.mkForce false;
  };

  programs.vscode.profiles.default = {
    extensions = lib.mkAfter (with pkgs.vscode-extensions; [
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
    ]);
    userSettings = {
      "workbench.colorTheme" = lib.mkForce themeNames.${selected.variant};
      "workbench.iconTheme" = lib.mkForce "catppuccin-${selected.variant}";
    } // lib.optionalAttrs (selected.accent != null) {
      "catppuccin.accentColor" = lib.mkForce selected.accent;
    };
  };

  stylix.targets.vscode.enable = lib.mkForce false;
}
