{
  themeBrokerAdapters,
  themeBrokerProviders,
  ...
}: {
  imports = [
    ({
      config,
      cosmicLib ? null,
      lib,
      options,
      pkgs,
      ...
    }:
      import ./common.nix {
        inherit config cosmicLib lib options pkgs themeBrokerAdapters themeBrokerProviders;
        themeBrokerPlatform = "homeManager";
      })
    ./internal/options.nix
  ];
  themeBroker.platform = "homeManager";
}
