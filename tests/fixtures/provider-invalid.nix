{lib}: let
  valid = import ./provider-valid.nix {inherit lib;};
in
  valid // {variants.dark.roles.ui.background = "@missing";}
