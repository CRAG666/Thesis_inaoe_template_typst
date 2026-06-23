# biblatex-cites

`biblatex`-style citation commands for [Typst](https://typst.app):
`textcite`, `parencite`, `citeauthor`, `citeyear`, `fullcite` — with
**separate author counts** for in-text citations vs. the reference list
(like `biblatex`'s `maxcitenames` / `maxbibnames`).

## Why

Typst ties `#cite(form: "prose")` to the bibliography's author rendering, so
you can't truncate in-text authors ("Smith et al.") while keeping the full list
in the references using CSL alone. This package reads author names from the
`.bib` and renders them itself, leaving the numeric `[n]` and the reference-list
format to `#bibliography`.

## Usage

```typst
#import "@local/biblatex-cites:0.1.0": biblatex-cites   // or a relative path
#let (textcite, parencite, citeauthor, citeyear, fullcite) =
  biblatex-cites(read("references.bib"))                // et-al-min: 3 by default

#textcite(<smith2024>)                      // J. Smith et al. [1]
#textcite(<doe2025>)                        // J. Doe and J. Roe [2]
#citeauthor(<smith2024>)                    // J. Smith et al.
#citeyear(<smith2024>)                      // 2024
#parencite(<doe2025>, supplement: [p. 10])  // [2, p. 10]

#bibliography("references.bib", style: "ieee")
```

`read()` must be called in **your** file (it resolves the path relative to the
caller, not the package). Pass `et-al-min: N` to change when in-text citations
collapse to "First et al." (default 3).

## Install as a local package

Copy this folder to
`{data-dir}/typst/packages/local/biblatex-cites/0.1.0/`, then import with
`@local/biblatex-cites:0.1.0`. Or just drop the folder in your project and use a
relative import (`#import "biblatex-cites/lib.typ": biblatex-cites`).

## Limitation

The `.bib` parser is minimal: author keys without nested braces
(e.g. `Surname, Given` or `Given Surname`). Names like `{von der Berg}` aren't
handled.

## See also

This package deliberately stays tiny and keeps Typst's native `#bibliography`.
If you need full BibLaTeX-like power (bibliography styles defined in Typst code,
multiple/filtered reference sections, etc.) and don't mind a larger, evolving
dependency that replaces the built-in bibliography, look at
[`pergamon`](https://typst.app/universe/package/pergamon/). For author-year
prose sugar over native `cite()`,
[`citesugar`](https://typst.app/universe/package/citesugar/). Neither, as of
writing, gives you separate in-text vs. reference-list author counts for a
numeric (IEEE) style — which is the one thing this package exists for.

## License

GPL-3.0-or-later.
