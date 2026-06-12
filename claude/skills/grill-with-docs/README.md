# grill-with-docs

Adapted from Matt Pocock's [`skills`](https://github.com/mattpocock/skills) collection.

## Local changes from upstream

- **`GLOSSARY.md` instead of `BOUNDED-CONTEXT.md`.** The term file holds canonical
  language only (Boundary/Integration sections dropped). "Glossary" fits both the
  DDD ubiquitous-language case and plain general-purpose use, so the skill reads
  naturally in non-DDD repos too. The multi-glossary index keeps the DDD name
  `CONTEXT-MAP.md`, since "context map" is the established DDD term.
- **Greps `docs/` for context during grilling.** Beyond `GLOSSARY.md` and ADRs,
  the skill `rg`s other markdown (design notes, architecture, runbooks) for the
  terms a question touches and reads only the hits — no wholesale reads. Those
  docs are context to challenge against, not authoritative; only `GLOSSARY.md`
  and ADRs are law.
