# ADR 0006: keep provider selection global

## Status

Accepted for v1.0.0.

## Decision

Provider and variant selection remain global under `themeBroker.selection`.
Targets may choose generated or native backends, but they do not choose a
different provider or palette.

Per-target provider selection would make one normalized theme insufficient for
the shared Stylix Base16 bridge, complicate conflict detection, and make
native/generated comparisons ambiguous. Consumers that need target-specific
color changes can use the target implementation's existing override mechanism,
including Stylix target color overrides, without adding a broker API.

## Consequences

- The broker owns one coherent palette per module evaluation.
- Target backend decisions remain independently testable.
- A future per-target palette feature requires an explicit schema and conflict
  model rather than an implicit option added to `targets`.
