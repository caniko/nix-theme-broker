# ADR 0002: normalized provider schema

Status: accepted

Providers are data with semantic roles, ANSI, Base16, optional Base24, named
colors, metadata, and provenance.  Variant IDs are opaque.  The core validates
the data and resolves `@name` references before exposing a serializable theme.
