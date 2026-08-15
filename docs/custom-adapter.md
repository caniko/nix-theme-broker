# Custom adapters

Declare a local adapter only when its source and capabilities are pinned:

```nix
myAdapter = {
  schema = "theme-broker.adapter/v1";
  id = "my-editor-theme";
  provider = "my-theme";
  target = "my-editor";
  platforms = ["homeManager"];
  provenance = {
    tier = "local";
    repository = "https://example.invalid/my-editor-theme";
    revision = "full-revision";
    license = "MIT";
  };
  capabilities = {variants = "all"; accent = "none"; nativeOptions = [];};
  autoSafe = true;
  class = "simple";
  optionPath = ["programs" "my-editor" "theme"];
};
```

The normal resolver performs validation, target aliasing, trust filtering, and
stable tie-breaking. Pass simple adapters through the platform module's
`themeBrokerAdapters` argument so their option paths are part of the module's
fixed shape; they then become the default active registry. Registry-only
adapters without a declared renderer are never selected. Do not add
activation-time network fetches.

Declare every key consumed by a complex adapter in
`capabilities.nativeOptions`; the resolver rejects a native candidate that
cannot consume a requested key. Simple adapters must leave `nativeOptions`
empty. Adapter IDs must be unique across built-in, module, and registry inputs.
Built-in `rendererKind` values are reserved for the corresponding built-in
adapters. The exported registry can be passed through the public resolver as
`flake.lib.resolveBackend { adapters = flake.lib.adapters; ... }`; only exact
exported built-in descriptors enter the trusted channel.
