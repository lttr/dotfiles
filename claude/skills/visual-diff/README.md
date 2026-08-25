# visual-diff

Turns a code change into one self-contained HTML page: before/after module diagrams, seams,
and the patches that carry the point. Invoke with `/visual-diff [target]`.

| File | Role |
|---|---|
| `SKILL.md` | The procedure. Resolve the target, reconstruct both architectures, pick diagrams, colour the deltas, write the body. Read first, on every run. |
| `HTML-REPORT.md` | The format. Build command, block markup, section menu, diagram patterns, style rules. Read before writing any HTML. |
| `scaffold.html` | Head, palette, layout, and the loader that renders diagrams and diffs in the browser. Single source of truth, never copied by hand. |
| `build.mjs` | Splices a body into the scaffold. Node 24+, no dependencies. |
| `example-body.html` | A finished report body. The target to imitate. |
| `example.html` | The built example, committed so it opens without a build. Generated, so edit `example-body.html` instead. |

Build with `node build.mjs body.html --title "Visual diff: subject" --open`, where the body
is everything from `<main>` to `</main>`. After changing the scaffold or the example body,
rebuild the example with
`node build.mjs example-body.html --title "Visual diff: order intake" --out example.html`.

The page pulls its renderers from a CDN, so it needs network on first open, and a failed
import falls back to the raw source rather than a blank space.
