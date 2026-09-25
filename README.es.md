# Plantilla de Tesis INAOE (Typst)

[English](README.md)

Port no oficial a [Typst](https://typst.app) de la plantilla LaTeX
`inaoe-tesis.sty` para tesis del **Instituto Nacional de Astrofísica, Óptica y
Electrónica (INAOE)**. Configura la portada oficial, el estilo de capítulos, el
diseño de página, las páginas preliminares y el soporte español/inglés.

<p align="center">
  <img src="https://github.com/user-attachments/assets/fcaf09bc-6603-416f-9052-57fcd8cf576f" alt="Vista previa de la portada" width="350">
</p>

## Archivos

| Archivo | Propósito |
|---------|-----------|
| `inaoe-tesis.typ` | La plantilla (portada, estilos, diseño, alias de citas). No la edites salvo para personalizar. |
| `example.typ` | Ejemplo funcional — cópialo como punto de partida para tu tesis. |
| `references.bib` | Bibliografía de ejemplo en BibTeX. |
| `cover/` | Logotipos institucionales de la portada. |
| `biblatex-cites/` | Paquete Typst independiente con los comandos `textcite`/`citeauthor`/… Reutilizable en cualquier proyecto — ver su propio README. |
| `fonts/` | TeX Gyre Termes (`.otf`), incluidas para que el CLI iguale a la web. |

## Requisitos

- [Typst](https://github.com/typst/typst) (CLI o [app web](https://typst.app))
- Fuentes: el repo incluye **TeX Gyre Termes** en `fonts/`. En
  [typst.app](https://typst.app) ya están disponibles, así que ahí no hay que
  hacer nada. El CLI de Typst solo trae New Computer Modern, por eso hay que
  apuntarlo a `fonts/` (abajo).

## Uso

```bash
typst watch --ignore-system-fonts --font-path fonts example.typ   # mientras editas
typst compile --ignore-system-fonts --font-path fonts example.typ # genera example.pdf
```

Usa `watch` durante la escritura: conserva la caché entre cambios y recompila
solo lo necesario. `--ignore-system-fonts` evita buscar fuentes en todo el
sistema; esta plantilla utiliza las de `fonts/` y las integradas en Typst.
Si añades otras fuentes, incluye su directorio con otro `--font-path`.

Configura la plantilla editando la llamada `inaoe-thesis.with(...)`:

```typst
#import "inaoe-tesis.typ": inaoe-thesis, appendix, textcite, parencite

#show: inaoe-thesis.with(
  lang: "es",                    // "en" para inglés
  title: "Título de tu tesis",
  author: "Tu Nombre",
  advisor: [Dr. Asesor Uno \ Dra. Asesora Dos],
  degree: "Maestría en Ciencias Computacionales",
  month: "Octubre",
  // year: 2025,                 // opcional; por defecto el año actual
  dedication: [...],
  acknowledgements: [...],
  abstract: [...],
)

= Introducción
...
```

### Citas

Usa el `@clave` nativo (→ `[1]`) o los alias estilo LaTeX de la plantilla, que
replican los comandos de `biblatex` con estilo IEEE numérico:

```typst
@exampleRef                                // [1]
#textcite(<exampleRef>)                     // J. Doe and J. Roe [1]
#textcite(<manyAuthors>)                    // J. Smith et al. [2]
#citeauthor(<exampleRef>)                   // J. Doe and J. Roe
#citeyear(<exampleRef>)                     // 2025
#parencite(<exampleRef>, supplement: [p. 10])  // [1, p. 10]
```

**Recuentos de nombres separados (como `maxcitenames`/`maxbibnames` de
`biblatex`).** `textcite`/`citeauthor` recortan a "Primero et al." con 3+
autores, mientras que la **lista de Referencias muestra todos los autores**.
Typst no puede hacer esto solo con CSL (su forma *prose* queda atada al
renderizado de autores de la bibliografía), así que los alias leen los nombres
directamente del `.bib` y añaden el `[n]` numérico de `#cite`. El formato de la
lista de Referencias lo da el estilo `ieee` integrado de Typst. Esto vive en el
paquete independiente [`biblatex-cites/`](biblatex-cites/) (reutilizable en
cualquier proyecto); la plantilla solo lo conecta en `inaoe-tesis.typ` (cambia
`_bib-path` ahí, o pasa `et-al-min:` a `biblatex-cites`).

### Apéndices

Cambia a capítulos numerados con letras (A, B, …) antes de la bibliografía:

```typst
#show: appendix
= Artículos publicados
```

## Licencia

Licencia Pública General de GNU v3.0 (GPLv3). Autor: Diego Aguilar —
<https://github.com/CRAG666>.
