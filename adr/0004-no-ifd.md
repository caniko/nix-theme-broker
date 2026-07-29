# ADR 0004: no import-from-derivation

Status: accepted

Evaluation-time palette data comes from locked source inputs or reviewed files
in the repository.  Nix evaluation never invokes Python, parses a built theme,
or accesses the network.  Update scripts run only in a maintainer workflow.
