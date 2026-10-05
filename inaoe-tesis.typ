// ============================================================
//  inaoe-tesis.typ  –  Plantilla no oficial de INAOE (Typst)
//
//  Autor: Diego Aguilar  ·  https://github.com/CRAG666
//  Licencia: GNU General Public License v3.0 (GPLv3)
//
//  Port a Typst de inaoe-tesis.sty. Configura portada, estilo de
//  capítulos, diseño de página y soporte español/inglés.
//
//  Uso:
//    #import "inaoe-tesis.typ": inaoe-thesis, appendix
//    #show: inaoe-thesis.with(lang: "en", title: ..., author: ..., ...)
// ============================================================

// Color institucional
#let DBlue = rgb(40, 31, 109) // 0.156, 0.121, 0.427

// Cadenas por idioma
#let strings(lang) = if lang == "es" {
  (
    chapter: "Capítulo", contents: "Índice",
    lof: "Lista de figuras", lot: "Lista de tablas",
    dedication: "Dedicatoria",
    acknowledgements: "Agradecimientos",
    abstract: "Resumen", references: "Referencias",
    by: "Por:", by-lower: "por", advisors: "Asesores:",
    place: "Santa María de Tonantzintla, Puebla, CP 72840",
    req: "Tesis sometida como requisito parcial para obtener el grado de:",
    at: "en el", supervised: "Asesor:",
    rights: "Derechos reservados",
    grant: [El autor otorga al INAOE el permiso de reproducir este
            documento total o parcialmente, citando la fuente.],
  )
} else {
  (
    chapter: "Chapter", contents: "Contents",
    lof: "List of Figures", lot: "List of Tables",
    dedication: "Dedication",
    acknowledgements: "Acknowledgements",
    abstract: "Abstract", references: "References",
    by: "By:", by-lower: "by", advisors: "Doctoral Advisors:",
    place: "Santa María de Tonantzintla, Puebla, CP 72840",
    req: "Thesis submitted as a requirement for obtaining the degree of:",
    at: "at the", supervised: "Supervised by:",
    rights: "All rights reserved",
    grant: [The author hereby grants the permission for full or partial
            reproduction and distribution of this document to INAOE while
            mentioning the source],
  )
}

// ---- Portada -------------------------------------------------
// Marco azul y logotipos comunes a ambas portadas (coordenadas en cm desde la
// esquina superior izquierda).
#let cover-frame() = {
  let bstroke = 0.8mm + DBlue
  place(top + left, dx: 6.2cm, dy: 2.40cm, line(length: 13.3cm, stroke: bstroke))
  place(top + left, dx: 6.2cm, dy: 25.59cm, line(length: 10.6cm, stroke: bstroke))
  place(top + left, dx: 6.24cm, dy: 2.43cm, line(length: 23.2cm, angle: 90deg, stroke: bstroke))
  place(top + left, dx: 19.46cm, dy: 2.36cm, line(length: 20.5cm, angle: 90deg, stroke: bstroke))

  place(top + left, dx: 2.7cm, dy: 2.40cm,
    image("cover/Inaoe.pdf", width: 3.097cm,
      alt: "Instituto Nacional de Astrofísica, Óptica y Electrónica (INAOE)"))
  place(top + left, dx: 16.85cm, dy: 22.57cm,
    image("cover/cmyk-original.jpg", width: 3.124cm,
      alt: "INAOE"))
}

// Portada de tesis (formato oficial)
#let cover-thesis(s, title, author, advisor, degree, month, year, requirement) = {
  set page(paper: "us-letter", margin: 0cm, numbering: none, header: none, footer: none)
  set text(font: ("TeX Gyre Termes", "New Computer Modern"))
  cover-frame()

  // Bloque de texto centrado dentro del marco
  place(top + left, dx: 6.85cm, box(width: 12cm, height: 27.94cm, inset: (top: 1.5cm, bottom: 2.7cm),
    align(center)[
      #v(1.2fr)
      #text(size: 14pt, weight: "bold")[#title]
      #v(0.8fr)
      #s.by
      #v(0.2fr)
      #text(weight: "bold")[#author]
      #v(0.5fr)
      #if requirement == auto [#s.req] else if requirement != none [#requirement]
      #v(0.2fr)
      #text(weight: "bold")[#upper(degree)]
      #v(0.2fr)

      #s.at

      #text(weight: "bold")[Instituto Nacional de Astrofísica,]

      #text(weight: "bold")[Óptica y Electrónica]

      #if month != none and month != "" [#month, ]#year

      Tonantzintla, Puebla
      #v(0.8fr)
      #s.supervised
      #text(weight: "bold")[#advisor]
      #v(0.7fr)

      © INAOE #year \
      #s.rights
      // Alineado al borde izquierdo del texto, con sangría de primera
      // línea; margen derecho para acercarse al logo sin tocarlo.
      #align(left, pad(right: 2.3cm, [#h(10mm)#s.grant]))
    ]))
}

// Portada de propuesta de tesis (formato usado por la Coordinación de Ciencias
// Computacionales): título y grado en negritas, "by", autor, asesores, INAOE,
// coordinación, fecha y lugar; sin derechos ni permiso de reproducción.
// Proporciones calibradas sobre propuestas aprobadas (2025).
#let cover-proposal(s, title, author, advisor, degree, month, year, department) = {
  set page(paper: "us-letter", margin: 0cm, numbering: none, header: none, footer: none)
  set text(font: ("TeX Gyre Termes", "New Computer Modern"), size: 12pt)
  cover-frame()

  // Bloque centrado vertical y horizontalmente entre el marco superior y el logotipo inferior
  place(top + left, dx: 6.85cm, dy: 2.40cm, box(width: 12cm, height: 20.17cm,
    align(center + horizon)[
      #set par(spacing: 0pt, leading: 0.775em, justify: false)
      #block(text(size: 17.28pt, weight: "bold", par(leading: 0.85em)[#title \ #degree]))
      #v(1.8cm)
      #s.by-lower
      #v(0.75cm)
      #text(weight: "bold")[#author]
      #v(1.3cm)
      #s.advisors
      #v(1.3cm)
      #text(weight: "bold")[#advisor]
      #v(2.2cm)
      Instituto Nacional de Astrofísica, Óptica y Electrónica \
      © #department
      #v(1.25cm)
      #if month != none and month != "" [#month, ]#year \
      #s.place
    ]))
}

// ---- Métrica vertical ----------------------------------------
// Medida en el formato de propuesta de la CCC (Propuesta_MLHJ.pdf, LaTeX
// article 12pt): 17.33pt entre líneas base, parskip de 9pt y sangría de 10mm.
// Typst mide el interlineado desde la altura de mayúsculas (top-edge) hasta
// la línea base, así que leading = paso entre líneas base − altura de mayúsculas.
#let pitch = 17.33pt     // paso entre líneas base del cuerpo
#let parskip = 9pt       // espacio extra entre párrafos (0.75em)
#let topsep = 9pt        // espacio extra antes y después de una lista
#let body-cap = 7.94pt   // altura de mayúsculas de TeX Gyre Termes a 12pt
#let leading = pitch - body-cap
#let par-spacing = leading + parskip

// Títulos de nivel 2+ (\subsection y \subsubsection del mismo formato):
// distancias entre líneas base texto→título y título→texto, paso de línea
// del propio título y altura de mayúsculas de su fuente (negrita 14.4pt / 12pt).
#let section-levels = (
  (before: 47pt, after: 34pt, pitch: 21.5pt, cap: 9.73pt),  // ==
  (before: 43pt, after: 34pt, pitch: 17.33pt, cap: 8.11pt), // === y siguientes
)

// Listas (enumerate/itemize de LaTeX 12pt): topsep + parskip antes y después,
// itemsep + parsep (= parskip) entre elementos; las anidadas son más compactas.
#let list-depth = counter("inaoe-list-depth")
#let list-block(it) = {
  list-depth.step()
  context {
    let nested = list-depth.get().first() > 1
    let gap = if nested { leading + 4.5pt } else { leading + topsep + parskip }
    // Un set dentro del show no afecta a esta lista, solo a las anidadas en ella.
    set enum(spacing: leading + 4pt)
    set list(spacing: leading + 4pt)
    block(above: gap, below: gap, it)
  }
  list-depth.update(n => n - 1)
}

// ---- Encabezado de capítulo (replica \@makechapterhead) ------
#let chapter-head(s, it) = {
  pagebreak(weak: true)
  let thick = line(length: 100%, stroke: 4pt)
  v(10pt)
  if it.numbering != none {
    grid(columns: (1fr, auto, 1fr), column-gutter: 1em, align: horizon,
      thick, smallcaps[#s.chapter #counter(heading).display(it.numbering)], thick)
    v(10pt)
  }
  line(length: 100%)
  v(10pt)
  block(width: 100%, above: 0pt, below: 0pt,
    text(size: 24.88pt, weight: "bold", it.body))
  v(10pt)
  line(length: 100%)
  // Débil para que absorba el salto previo de una sección que abra el capítulo
  // (como \addvspace en LaTeX); incluye el parskip de 9pt que un párrafo añadiría.
  v(60pt + parskip, weak: true)
}

// ---- Encabezados de sección (niveles 2+) ----------------------
#let section-head(it) = {
  let lv = section-levels.at(if it.level == 2 { 0 } else { 1 })
  block(sticky: true, above: lv.before - lv.cap, below: 0pt, context {
    let (prefix, indent) = if it.numbering == none { ([], 0pt) } else {
      let num = counter(heading).display(it.numbering)
      // \quad entre número y título (\@seccntformat) y sangría francesa
      (num + h(1em), measure(num).width + 1em.to-absolute())
    }
    par(justify: false, leading: lv.pitch - lv.cap, hanging-indent: indent, prefix + it.body)
  })
  // El salto posterior va como espacio débil: si sigue otro título se impone
  // a su "above", igual que LaTeX, que no añade salto previo tras un título.
  v(lv.after - body-cap, weak: true)
}

// ---- Plantilla principal -------------------------------------
#let inaoe-thesis(
  lang: "en",
  title: "Título de la tesis",
  author: "Nombre del autor",
  advisor: "Nombre del asesor",
  degree: "Grado",
  month: "",
  year: datetime.today().year(), // por defecto, el año actual
  requirement: auto, // línea sobre el grado en la portada: auto = texto del idioma, none = omitirla, o un texto propio
  cover: "thesis", // "thesis" (portada oficial de tesis) o "proposal" (formato de propuesta de la CCC)
  department: "Coordinación de Ciencias Computacionales", // solo portada "proposal": texto tras el ©

  dedication: none,
  acknowledgements: none,
  abstract: none,
  bib-source: none,
  body,
) = {
  let s = strings(lang)

  set document(title: title, author: if type(author) == str { author } else { "" })
  set text(lang: lang, size: 12pt,
    font: ("TeX Gyre Termes", "New Computer Modern"))
  set par(leading: leading, spacing: par-spacing, first-line-indent: 10mm, justify: true)
  set heading(numbering: "1.1")
  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): chapter-head.with(s)
  show heading: it => if it.level == 1 { it } else { section-head(it) }
  set enum(spacing: par-spacing)
  set list(spacing: par-spacing)
  show enum: list-block
  show list: list-block
  // Tablas: pie arriba, partibles entre páginas y sin texto justificado en celdas
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set block(breakable: true)
  show table: set par(justify: false)

  // Portada
  assert(cover in ("thesis", "proposal"), message: "cover must be \"thesis\" or \"proposal\"")
  if cover == "proposal" {
    cover-proposal(s, title, author, advisor, degree, month, year, department)
  } else {
    cover-thesis(s, title, author, advisor, degree, month, year, requirement)
  }

  // Páginas preliminares (numeración romana)
  set page(paper: "us-letter",
    margin: (left: 4.04cm, right: 2.5cm, top: 2.4cm, bottom: 2.6cm),
    numbering: "i")
  counter(page).update(1)

  outline(title: s.contents)
  outline(title: s.lof, target: figure.where(kind: image))
  outline(title: s.lot, target: figure.where(kind: table))

  for (title, content) in (
    (s.dedication, dedication),
    (s.acknowledgements, acknowledgements),
    (s.abstract, abstract),
  ) {
    if content != none {
      heading(level: 1, numbering: none, outlined: true, title)
      content
    }
  }

  // Cuerpo principal (numeración arábiga)
  set page(numbering: "1")
  counter(page).update(1)

  body

  if bib-source != none {
    bibliography(bytes(bib-source), style: "ieee", title: s.references)
  }
}

// Apéndices: capítulos numerados con letras (A, B, ...)
#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  body
}

// Las citas se configuran desde el documento para leer su propia bibliografía.
#import "biblatex-cites/lib.typ": biblatex-cites
#let thesis-cites = biblatex-cites
