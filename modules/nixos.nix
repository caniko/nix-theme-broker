{
  themeBrokerAdapters ? [],
  themeBrokerBuiltinAdapters ? [],
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
        inherit config cosmicLib lib options pkgs themeBrokerAdapters themeBrokerBuiltinAdapters themeBrokerProviders;
        themeBrokerPlatform = "nixos";
      })
    ./internal/options.nix
  ];
  themeBroker.platform = "nixos";
}
