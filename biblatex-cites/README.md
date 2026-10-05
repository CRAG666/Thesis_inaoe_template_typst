# biblatex-cites

`biblatex`-style citation commands for [Typst](https://typst.app):
`textcite`, `parencite`, `citeauthor`, `citeyear`, `citetitle`, `fullcite`,
`footcite`, `footfullcite`, `supercite`, `autocite`, `nocite`, `cites`,
`parencites`, `textcites` — with
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
#let (textcite, parencite, citeauthor, citeyear, citetitle, fullcite,
      footcite, footfullcite, supercite, autocite, nocite,
      cites, parencites, textcites) =
  biblatex-cites(read("references.bib"))                // et-al-min: 3 by default

#textcite(<smith2024>) and #textcite("doe2025")         // labels or string keys
#bibliography("references.bib", style: "ieee")
```

`read()` must be called in **your** file (it resolves the path relative to the
caller, not the package).

## Commands

With `smith2024` (four authors) and `doe2025` (two authors) in the `.bib`:

| Command | biblatex | Renders as |
|---|---|---|
| `#textcite("smith2024")` | `\textcite` | Smith et al. [1] |
| `#textcite("doe2025")` | `\textcite` | Doe and Roe [2] |
| `#textcites("smith2024", "doe2025")` | `\textcites` | Smith et al. [1], Doe and Roe [2] |
| `#parencite("doe2025")` | `\parencite`, `\cite` | [2] |
| `#parencite("doe2025", supplement: [p. 10])` | `\parencite[p. 10]` | [2, p. 10] |
| `#parencites("smith2024", "doe2025")` / `#cites(...)` | `\parencites`, `\cites` | [1], [2] (Typst groups adjacent cites; runs become [1]-[3]) |
| `#autocite("doe2025")` | `\autocite` | [2] (alias of `parencite`, as in numeric styles) |
| `#citeauthor("smith2024")` | `\citeauthor` | Smith et al. |
| `#citeyear("smith2024")` | `\citeyear` | 2024 |
| `#citetitle("smith2024")` | `\citetitle` | the `title` field, braces removed and whitespace collapsed |
| `#fullcite("smith2024")` | `\fullcite` | the full reference-list entry, inline |
| `#footcite("smith2024")` | `\footcite` | [1] inside a footnote |
| `#footfullcite("smith2024")` | `\footfullcite` | the full entry inside a footnote |
| `#supercite("smith2024")` | `\supercite` | [1] as superscript (keeps the CSL brackets; the bare number is not exposed to Typst code) |
| `#nocite("smith2024", "doe2025")` | `\nocite` | nothing; the entries appear in the bibliography |

`@smith2024` (Typst's own syntax) is equivalent to `#parencite("smith2024")`.

## Options

- `et-al-min: N` (default 3): number of authors from which in-text citations
  collapse to "First et al.".
- `initials: true`: prefix given-name initials, "J. Smith et al." instead of
  "Smith et al.".
- `multi-delim: ", "`: separator used by `textcites`.
- Entries without `author` (edited books) fall back to their `editor` field.

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
