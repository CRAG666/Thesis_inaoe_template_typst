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
    abstract: "Resumen",
    by: "Por:",
    req: "Tesis sometida como requisito parcial para obtener el grado de:",
    at: "en el", supervised: "Asesor:",
    rights: "Derechos reservados",
    grant: [El autor otorga al INAOE el permiso de reproducir este
            documento total o parcialmente, citando la fuente.],
  )
} else {
  (
    chapter: "Chapter", contents: "Index",
    lof: "Figure list", lot: "Table list",
    dedication: "Dedication",
    acknowledgements: "Acknowledgements",
    abstract: "Abstract",
    by: "By:",
    req: "Thesis submitted as a requirement for obtaining the degree of:",
    at: "at the", supervised: "Supervised by:",
    rights: "All rights reserved",
    grant: [The author hereby grants the permission for full or partial
            reproduction and distribution of this document to INAOE while
            mentioning the source],
  )
}

// ---- Portada -------------------------------------------------
#let cover(s, title, author, advisor, degree, month, year) = {
  set page(paper: "us-letter", margin: 0cm, numbering: none, header: none, footer: none)
  set text(font: ("TeX Gyre Termes", "New Computer Modern"))

  // Marco azul (coordenadas en cm desde la esquina superior izquierda)
  let bstroke = 0.8mm + DBlue
  place(top + left, dx: 6.2cm, dy: 2.40cm, line(length: 13.3cm, stroke: bstroke))
  place(top + left, dx: 6.2cm, dy: 25.59cm, line(length: 10.6cm, stroke: bstroke))
  place(top + left, dx: 6.24cm, dy: 2.43cm, line(length: 23.2cm, angle: 90deg, stroke: bstroke))
  place(top + left, dx: 19.46cm, dy: 2.36cm, line(length: 20.5cm, angle: 90deg, stroke: bstroke))

  // Logotipos
  place(top + left, dx: 2.7cm, dy: 2.40cm,
    image("cover/Inaoe.pdf", width: 3.097cm,
      alt: "Instituto Nacional de Astrofísica, Óptica y Electrónica (INAOE)"))
  place(top + left, dx: 16.85cm, dy: 22.57cm,
    image("cover/cmyk-original.jpg", width: 3.124cm,
      alt: "INAOE"))

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
      #s.req
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
  v(60pt)
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

  dedication: none,
  acknowledgements: none,
  abstract: none,
  body,
) = {
  let s = strings(lang)

  set document(title: title, author: if type(author) == str { author } else { "" })
  set text(lang: lang, size: 12pt,
    font: ("TeX Gyre Termes", "New Computer Modern"))
  set par(leading: 1em, spacing: 0.75em, first-line-indent: 10mm, justify: true)
  set heading(numbering: "1.1")
  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): chapter-head.with(s)

  // Portada
  cover(s, title, author, advisor, degree, month, year)

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
}

// Apéndices: capítulos numerados con letras (A, B, ...)
#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1")
  body
}

// ---- Alias de citas estilo LaTeX -----------------------------
// textcite/parencite/citeauthor/citeyear/fullcite con recuento de nombres
// separado citas vs. Referencias. Implementado en el paquete local
// biblatex-cites (ver biblatex-cites/lib.typ). read() se llama AQUÍ para
// que la ruta del .bib resuelva relativa a esta plantilla.
#import "biblatex-cites/lib.typ": biblatex-cites
#let _bib-path = "references.bib" // cámbialo si tu .bib se llama distinto
#let (textcite, parencite, citeauthor, citeyear, fullcite) = biblatex-cites(read(_bib-path))
