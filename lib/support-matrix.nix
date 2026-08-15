{lib}: let
  target = import ./target.nix {inherit lib;};
in
  {
    providers,
    adapters,
  }: let
    providerRows =
      lib.mapAttrsToList (id: provider: {
        inherit id;
        name = provider.name or id;
        provenance = provider.provenance or {};
        variants = lib.mapAttrsToList (variantId: variant: {
          id = variantId;
          metadata = variant.metadata or {};
          accents = lib.attrNames (variant.accents or {});
          base24 = variant.base24 or null != null;
        }) (provider.variants or {});
      })
      providers;
    adapterRows =
      map (adapter: {
        id = adapter.id;
        provider = adapter.provider;
        target = adapter.target;
        platforms = adapter.platforms or [];
        priority = adapter.priority or 0;
        autoSafe = adapter.autoSafe or false;
        provenance = adapter.provenance or {};
        capabilities = adapter.capabilities or {};
        renderer = adapter.rendererKind or null;
        status =
          if target.rendererSupported adapter
          then "supported"
          else "inventory-only";
      })
      adapters;
    matrix = {
      schema = "theme-broker.support-matrix/v1";
      providers = providerRows;
      adapters = adapterRows;
    };
    variantRows = lib.concatMap (provider:
      map (variant: {
        provider = provider.id;
        variant = variant.id;
        appearance = variant.metadata.appearance or "unknown";
        contrast = variant.metadata.contrast or "unknown";
        accents = lib.concatStringsSep ", " variant.accents;
      })
      provider.variants)
    providerRows;
    markdown =
      "# Theme Broker support matrix\n\n"
      + "Generated from the provider and native-adapter registries.\n\n"
      + "## Providers and variants\n\n"
      + "| Provider | Variant | Appearance | Contrast | Accents |\n| --- | --- | --- | --- | --- |\n"
      + lib.concatMapStrings (row: "| ${row.provider} | ${row.variant} | ${row.appearance} | ${row.contrast} | ${
        if row.accents == ""
        then "none"
        else row.accents
      } |\n")
      variantRows
      + "\n## Native adapters\n\n"
      + "Every listed adapter has an implemented renderer; machine-readable renderer and status fields are included in the JSON package.\n\n"
      + "| Adapter | Provider | Target | Platforms | Trust | Revision |\n| --- | --- | --- | --- | --- | --- |\n"
      + lib.concatMapStrings (row: "| ${row.id} | ${row.provider} | ${row.target} | ${lib.concatStringsSep ", " row.platforms} | ${(row.provenance.tier or "unknown")} | ${(row.provenance.revision or "unknown")} |\n") adapterRows;
  in {
    inherit matrix markdown;
    json = builtins.toJSON matrix;
  }
