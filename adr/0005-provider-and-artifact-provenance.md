# ADR 0005: separate provenance fields

Status: accepted

Provider provenance identifies the palette source.  Native adapter provenance
identifies the application artifact and its trust tier (`official`,
`canonical`, `maintained`, `community`, or `local`).  The resolver's default
policy excludes `community` artifacts unless explicitly enabled.
