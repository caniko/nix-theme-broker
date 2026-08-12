{
  config,
  lib,
  selected,
  size ? 24,
}: let
  accent =
    if selected.accent == null
    then "mauve"
    else selected.accent;
in {
  catppuccin.cursors.enable = lib.mkForce false;
  stylix.cursor = {
    name = "catppuccin-${selected.variant}-${accent}-cursors";
    package =
      lib.attrByPath [
        "catppuccin"
        "sources"
        "cursors"
        "${selected.variant}${lib.toSentenceCase accent}"
      ]
      null
      config;
    inherit size;
  };
}
