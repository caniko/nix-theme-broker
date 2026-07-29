# Custom adapters

Register a local adapter only when its source and capabilities are pinned:

```nix
themeBroker.registry.adapters = [{
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
  capabilities = {variants = "all"; accent = "none";};
}];
```

The normal resolver performs validation, target aliasing, trust filtering, and
stable tie-breaking. Do not add activation-time network fetches.
