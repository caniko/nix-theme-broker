{lib, ...}: {
  options.themeBroker = {
    # The public options live in common.nix; this module is an explicit
    # import boundary for consumers that need to inspect the option surface.
    _schemaVersion = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = "theme-broker/v1";
      description = "Theme broker option schema version.";
    };
  };
}
