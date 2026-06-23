# INAOE Thesis Template (Typst)

[Español](README.es.md)

Unofficial [Typst](https://typst.app) port of the LaTeX `inaoe-tesis.sty` thesis
template for the **Instituto Nacional de Astrofísica, Óptica y Electrónica (INAOE)**.
It sets up the official cover, chapter styling, page layout, front matter, and
Spanish/English support.

<p align="center">
  <img src="https://github.com/user-attachments/assets/fcaf09bc-6603-416f-9052-57fcd8cf576f" alt="Cover preview" width="350">
</p>

## Files

| File | Purpose |
|------|---------|
| `inaoe-tesis.typ` | The template (cover, styles, layout, cite aliases). Don't edit unless customizing. |
| `example.typ` | Working example — copy it as the starting point for your thesis. |
| `references.bib` | Sample BibTeX bibliography. |
| `cover/` | Institutional logos used on the cover. |
| `biblatex-cites/` | Standalone Typst package powering the `textcite`/`citeauthor`/… commands. Reusable in any project — see its own README. |
| `fonts/` | TeX Gyre Termes (`.otf`), bundled so the CLI matches the web app. |

## Requirements

- [Typst](https://github.com/typst/typst) (CLI or [web app](https://typst.app))
- Fonts: the repo ships **TeX Gyre Termes** in `fonts/`. On
  [typst.app](https://typst.app) it's already available, so nothing to do there.
  The Typst CLI only bundles New Computer Modern, so point it at `fonts/` (below).

## Usage

```bash
typst compile --font-path fonts example.typ   # produces example.pdf
typst watch   --font-path fonts example.typ   # live recompile while editing
```

Configure the template by editing the `inaoe-thesis.with(...)` call:

```typst
#import "inaoe-tesis.typ": inaoe-thesis, appendix, textcite, parencite

#show: inaoe-thesis.with(
  lang: "en",                    // "es" for Spanish
  title: "Your thesis title",
  author: "Your Name",
  advisor: [Dr. Advisor One \ Dra. Advisor Two],
  degree: "M.S. in Computer Science",
  month: "October",
  // year: 2025,                 // optional; defaults to current year
  dedication: [...],
  acknowledgements: [...],
  abstract: [...],
)

= Introduction
...
```

### Citations

Use Typst's native `@key` (→ `[1]`) or the LaTeX-style aliases provided by the
template, which mirror `biblatex`'s commands with IEEE numeric style:

```typst
@exampleRef                                // [1]
#textcite(<exampleRef>)                     // J. Doe and J. Roe [1]
#textcite(<manyAuthors>)                    // J. Smith et al. [2]
#citeauthor(<exampleRef>)                   // J. Doe and J. Roe
#citeyear(<exampleRef>)                     // 2025
#parencite(<exampleRef>, supplement: [p. 10])  // [1, p. 10]
```

**Separate name counts (like `biblatex`'s `maxcitenames`/`maxbibnames`).**
`textcite`/`citeauthor` truncate to "First et al." with 3+ authors, while the
**reference list still lists every author**. Typst can't do this through CSL
alone (its prose form is tied to the bibliography's author rendering), so the
aliases read the author names straight from the `.bib` and append the numeric
`[n]` from `#cite`. The reference-list format comes from Typst's built-in `ieee`
style. This lives in the standalone [`biblatex-cites/`](biblatex-cites/) package
(reusable in any project); the template just wires it up in `inaoe-tesis.typ`
(change `_bib-path` there, or pass `et-al-min:` to `biblatex-cites`).

### Appendices

Switch to letter-numbered chapters (A, B, …) before the bibliography:

```typst
#show: appendix
= Published Articles
```

## License

GNU General Public License v3.0 (GPLv3). Author: Diego Aguilar -
<https://github.com/CRAG666>.
