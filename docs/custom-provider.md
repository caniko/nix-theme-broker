# Custom providers

Export a provider-shaped attrset from your flake and register it through the
mergeable module option:

```nix
themeBroker.registry.providers.my-theme = inputs.my-theme.themeBrokerProviders.my-theme;
```

Use `lib.themeBroker.mkProvider` in an evaluation check. Every variant needs
metadata, named colors, required semantic roles, exact ANSI and Base16 keys,
and provenance. `@name` references are resolved before projections are
exposed.
