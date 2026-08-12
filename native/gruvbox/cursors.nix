{
  lib,
  name ? null,
  pkgs,
  platform,
  selected,
  size ? 24,
}: let
  defaultName =
    if selected.metadata.appearance == "dark"
    then "Bibata-Original-Amber"
    else "Bibata-Original-Classic";
in
  {
    stylix.cursor = {
      package = pkgs.bibata-cursors;
      name =
        if name == null
        then defaultName
        else name;
      inherit size;
    };
  }
  // lib.optionalAttrs (platform == "nixos") {
    environment.systemPackages = [pkgs.bibata-cursors];
  }
