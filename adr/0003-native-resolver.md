# ADR 0003: deterministic native resolver

Status: accepted

Native adapters are selected only after target canonicalization, platform and
variant matching, trust filtering, capability grading, and stable priority
sorting.  `auto`, `generated`, and `native` always return a serializable reason
record and never activate two backends for one managed target.
