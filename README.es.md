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
| `install.sh`, `install.ps1` | Instalan el paquete local de Typst en Unix y Windows, respectivamente. |
| `typst.toml` | Metadatos del paquete y configuración de `typst init`. |
| `inaoe-tesis.typ` | Estilo de la tesis, importable como `@local/inaoe-tesis:0.1.0`. |
| `template/` | Archivos que `typst init` copia a cada tesis: ejemplo, bibliografía y fuentes. |
| `example.typ`, `references.bib`, `fonts/` | Ejemplo autocontenido para trabajar directamente desde este repositorio. |
| `cover/` | Logotipos institucionales incluidos en el paquete. |
| `biblatex-cites/` | Comandos `textcite`/`citeauthor`/…; también es un paquete independiente (ver su README). |

## Requisitos

- [Typst](https://github.com/typst/typst) (CLI o [app web](https://typst.app))
- Fuentes: el repo incluye **TeX Gyre Termes** en `fonts/`. En
  [typst.app](https://typst.app) ya están disponibles, así que ahí no hay que
  hacer nada. El CLI de Typst solo trae New Computer Modern, por eso hay que
  apuntarlo a `fonts/` (abajo).

## Instalación local

Revisa [install.sh](install.sh) o [install.ps1](install.ps1) antes de ejecutarlo:
ambos descargan y ejecutan código de la rama `main`. Necesitas el CLI de Typst.
Reemplazan la instalación existente de `@local/inaoe-tesis:0.1.0` y respetan
`TYPST_PACKAGE_PATH`.

### Linux y macOS

Necesitas `curl`, `tar` y Bash. En Linux se instala en
`~/.local/share/typst/packages/local/inaoe-tesis/0.1.0/` por defecto
(`XDG_DATA_HOME` cambia la ubicación); en macOS se usa `~/Library/Application Support`.

```bash
curl -fsSL https://raw.githubusercontent.com/CRAG666/Thesis_inaoe_template_typst/main/install.sh | bash
typst init @local/inaoe-tesis:0.1.0 mi-tesis
cd mi-tesis
```

### Windows (PowerShell)

Se instala en `%APPDATA%\typst\packages\local\inaoe-tesis\0.1.0` por defecto.
No necesitas Bash ni `tar`.

```powershell
irm https://raw.githubusercontent.com/CRAG666/Thesis_inaoe_template_typst/main/install.ps1 | iex
typst init @local/inaoe-tesis:0.1.0 mi-tesis
cd mi-tesis
```

`typst init` copia `example.typ`, `references.bib` y `fonts/` al proyecto.
El estilo y los logotipos permanecen en el paquete local. Para compartir una
tesis sin exigir su instalación, usa una copia completa de este repositorio y
su `example.typ`, que importa la plantilla por ruta relativa.

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
#import "@local/inaoe-tesis:0.1.0": inaoe-thesis

#show: inaoe-thesis.with(
  lang: "es",                    // "en" para inglés
  title: "Título de tu tesis",
  author: "Tu Nombre",
  advisor: [Dr. Asesor Uno \ Dra. Asesora Dos],
  degree: "Maestría en Ciencias Computacionales",
  month: "Octubre",
  // year: 2025,                 // opcional; por defecto el año actual
  // requirement: none,          // opcional; none omite la línea "Tesis sometida como requisito...", o pasa tu propio texto
  // cover: "proposal",          // opcional; portada de propuesta de tesis de la CCC en lugar de la portada de tesis
  // department: "Coordinación de Ciencias Computacionales", // opcional; solo para la portada "proposal"
  dedication: [...],
  acknowledgements: [...],
  abstract: [...],
  bib-source: read("references.bib"),
)

= Introducción
...
```

### Citas

Usa `@clave` para citar con el estilo IEEE numérico. Si necesitas comandos
estilo LaTeX como `textcite`, añádelos a tu documento:

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

**Recuentos de nombres separados (como `maxcitenames`/`maxbibnames` de
`biblatex`).** `textcite`/`citeauthor` recortan a "Primero et al." con 3+
autores, mientras que la **lista de Referencias muestra todos los autores**.
Typst no puede hacer esto solo con CSL (su forma *prose* queda atada al
renderizado de autores de la bibliografía), así que los alias leen los nombres
directamente del `.bib` y añaden el `[n]` numérico de `#cite`. El formato de la
lista de Referencias lo da el estilo `ieee` integrado de Typst. Esto vive en el
paquete independiente [`biblatex-cites/`](biblatex-cites/) (reutilizable en
cualquier proyecto). La plantilla lee el `.bib` desde *tu tesis* y genera
la lista de Referencias al final, con título español o inglés según `lang`.
Cambia la ruta en `read(...)` si usas otro nombre; para las citas avanzadas
puedes pasar `et-al-min:` a `thesis-cites`. Si no usas bibliografía, omite
`bib-source:`.

**Rendimiento.** Con `bib-source:`, la plantilla convierte cada `@clave` del
`.bib` directamente en `cite`: el resultado es idéntico, pero Typst se ahorra
una pasada de layout completa (en una tesis de ~120 páginas, ~25 % menos
tiempo de compilación). Los alias `citeauthor`/`citeyear` producen texto
plano y son más rápidos que `#cite(form: "author")`/`#cite(form: "year")`.

### Apéndices

Cambia a capítulos numerados con letras (A, B, …) antes de la bibliografía:

```typst
#show: appendix
= Artículos publicados
```

## Licencia

Licencia Pública General de GNU v3.0 (GPLv3). Autor: Diego Aguilar —
<https://github.com/CRAG666>.
