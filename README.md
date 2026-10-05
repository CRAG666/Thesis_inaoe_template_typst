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
| `install.sh`, `install.ps1` | Install the local Typst package on Unix and Windows, respectively. |
| `typst.toml` | Package metadata and `typst init` configuration. |
| `inaoe-tesis.typ` | Thesis style, importable as `@local/inaoe-tesis:0.1.0`. |
| `template/` | Files copied into each thesis by `typst init`: example, bibliography, and fonts. |
| `example.typ`, `references.bib`, `fonts/` | Standalone example for working directly from this repository. |
| `cover/` | Institutional logos bundled with the package. |
| `biblatex-cites/` | `textcite`/`citeauthor`/… commands; also a standalone package (see its README). |

## Requirements

- [Typst](https://github.com/typst/typst) (CLI or [web app](https://typst.app))
- Fonts: the repo ships **TeX Gyre Termes** in `fonts/`. On
  [typst.app](https://typst.app) it's already available, so nothing to do there.
  The Typst CLI only bundles New Computer Modern, so point it at `fonts/` (below).

## Local installation

Review [install.sh](install.sh) or [install.ps1](install.ps1) before running it:
both download and execute code from the `main` branch. You need the Typst CLI.
Both replace the existing `@local/inaoe-tesis:0.1.0` installation and respect
`TYPST_PACKAGE_PATH`.

### Linux and macOS

You need `curl`, `tar`, and Bash. On Linux, the default location is
`~/.local/share/typst/packages/local/inaoe-tesis/0.1.0/` (`XDG_DATA_HOME`
changes this path). On macOS, it is under `~/Library/Application Support`.

```bash
curl -fsSL https://raw.githubusercontent.com/CRAG666/Thesis_inaoe_template_typst/main/install.sh | bash
typst init @local/inaoe-tesis:0.1.0 my-thesis
cd my-thesis
```

### Windows (PowerShell)

The default location is `%APPDATA%\typst\packages\local\inaoe-tesis\0.1.0`.
Bash and `tar` are not needed.

```powershell
irm https://raw.githubusercontent.com/CRAG666/Thesis_inaoe_template_typst/main/install.ps1 | iex
typst init @local/inaoe-tesis:0.1.0 my-thesis
cd my-thesis
```

`typst init` copies `example.typ`, `references.bib`, and `fonts/` into your
project. The style and logos remain in the local package. To share a thesis
without requiring a package installation, use a full copy of this repository
and its `example.typ`, which imports the style through a relative path.

## Usage

```bash
typst watch --ignore-system-fonts --font-path fonts example.typ   # while editing
typst compile --ignore-system-fonts --font-path fonts example.typ # produces example.pdf
```

Use `watch` while writing: it retains the cache between edits and recompiles
only what is needed. `--ignore-system-fonts` skips system-wide font discovery;
this template uses the fonts in `fonts/` and those embedded in Typst.
If you add other fonts, include their directory with another `--font-path`.

Configure the template by editing the `inaoe-thesis.with(...)` call:

```typst
#import "@local/inaoe-tesis:0.1.0": inaoe-thesis

#show: inaoe-thesis.with(
  lang: "en",                    // "es" for Spanish
  title: "Your thesis title",
  author: "Your Name",
  advisor: [Dr. Advisor One \ Dra. Advisor Two],
  degree: "M.S. in Computer Science",
  month: "October",
  // year: 2025,                 // optional; defaults to current year
  // requirement: none,          // optional; none omits the "Thesis submitted as a requirement..." line, or pass your own text
  // cover: "proposal",          // optional; CCC dissertation-proposal cover instead of the thesis cover
  // department: "Coordinación de Ciencias Computacionales", // optional; "proposal" cover only
  dedication: [...],
  acknowledgements: [...],
  abstract: [...],
  bib-source: read("references.bib"),
)

= Introduction
...
```

### Citations

Use `@key` for IEEE-style numeric citations. If you need LaTeX-style commands
such as `textcite`, add them to your document:

```typst
#import "@local/inaoe-tesis:0.1.0": thesis-cites
#let (textcite, parencite, citeauthor, citeyear, fullcite) = thesis-cites(read("references.bib"))

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
(reusable in any project). The template reads the `.bib` from *your thesis*
and generates the reference list at the end, with an English or Spanish title
based on `lang`. Change the path in `read(...)` if needed; for advanced citations
you can also pass `et-al-min:` to `thesis-cites`. Omit `bib-source:` if you do
not use a bibliography.

### Appendices

Switch to letter-numbered chapters (A, B, …) before the bibliography:

```typst
#show: appendix
= Published Articles
```

## License

GNU General Public License v3.0 (GPLv3). Author: Diego Aguilar -
<https://github.com/CRAG666>.
