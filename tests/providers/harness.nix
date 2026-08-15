{lib}: provider: let
  themeLib = import ../../lib {inherit lib;};
  normalized = themeLib.mkProvider provider;
  variants =
    lib.mapAttrsToList (id: _: let
      selected = themeLib.resolveSelection {
        providers = {${normalized.id} = provider;};
        selection = {
          provider = normalized.id;
          variant = id;
          accent = null;
        };
      };
      accentChecks = lib.mapAttrsToList (
        accent: _: let
          withAccent = themeLib.resolveSelection {
            providers = {${normalized.id} = provider;};
            selection = {
              provider = normalized.id;
              variant = id;
              inherit accent;
            };
          };
        in
          withAccent.roles.ui.accent.hex == withAccent.named.${accent}.hex
      ) (normalized.variants.${id}.accents or {});
      requiredRoleChecks = map (path: lib.hasAttrByPath path selected.roles) (import ../../lib/types.nix {inherit lib;}).requiredRoles;
    in {
      inherit id selected;
      valid =
        selected.base16
        != null
        && selected.ansi.normal != null
        && selected.ansi.bright != null
        && builtins.all (value: value) requiredRoleChecks
        && builtins.all (value: value) accentChecks
        && builtins.toJSON selected != "";
    })
    normalized.variants;
  invalidAccent = builtins.tryEval (themeLib.resolveSelection {
    providers = {${normalized.id} = provider;};
    selection = {
      provider = normalized.id;
      variant = normalized.defaults.variant;
      accent = "__invalid__";
    };
  });
in {
  inherit normalized variants;
  valid = builtins.all (theme: theme.valid) variants && !invalidAccent.success;
}
