// ============================================================
//  biblatex-cites  –  comandos de cita estilo biblatex para Typst
//
//  textcite / parencite / citeauthor / citeyear / citetitle / fullcite,
//  footcite / footfullcite / supercite / autocite / nocite y las formas
//  múltiples cites / parencites / textcites, con recuento de nombres
//  SEPARADO entre las citas del texto y la lista de Referencias (como
//  maxcitenames/maxbibnames de biblatex+biber).
//
//  Por qué existe: Typst ata #cite(form:"prose") al renderizado de
//  autores de la bibliografía, así que no se pueden separar los dos
//  recuentos solo con CSL. Este módulo lee los nombres del .bib y los
//  renderiza él mismo, dejando el número [n] y el formato de Referencias
//  al estilo de #bibliography.
//
//  Uso:
//    #import "@local/biblatex-cites:0.1.0": biblatex-cites  // o ruta relativa
//    #let (textcite, parencite, citeauthor, citeyear, fullcite) =
//      biblatex-cites(read("references.bib"))               // o et-al-min: N
//    ... #textcite("key") ...  #citeyear(<key>) ...          // cadena o label
//    #bibliography("references.bib", style: "ieee")
//
//  Los nombres se muestran solo con el apellido ("Siam et al."); con
//  initials: true se antepone la inicial ("A. I. Siam et al."). Si una
//  entrada no tiene author (p. ej. un libro editado) se usan los editores.
//
//  Nota: read() debe llamarse en TU archivo (resuelve la ruta relativa a
//  él), no dentro del paquete.
//  Limitación del parser: solo admite un nivel de llaves anidadas en
//  author/editor/title; de los escapes LaTeX se convierten \', \~, \c y \l.
// ============================================================

#let _as-label(key) = label(str(key))

#let _accent-marks = ("'": "\u{0301}", "~": "\u{0303}", c: "\u{0327}")
#let _accent-pattern = regex("\\{?\\\\(['~c])(?:\\{(\\\\i|[A-Za-z])\\}|(\\\\i|[A-Za-z]))\\}?")
#let _stroke-pattern = regex("\\{?\\\\l(?:\\{\\})?\\}?")

#let _decode-name(raw) = {
  if not raw.contains("\\") { raw } else {
    raw.replace(_accent-pattern, match => {
      let letter = match.captures.at(1)
      if letter == none { letter = match.captures.at(2) }
      if letter == "\\i" { letter = "i" }
      letter + _accent-marks.at(match.captures.first())
    }).replace(_stroke-pattern, "ł").normalize()
  }
}

// "Apellido, Nombre M." / "Nombre M. Apellido" -> "Apellido"
// (o "N. M. Apellido" con initials: true)
#let _fmt-name(raw, initials: false) = {
  let name = _decode-name(raw).trim()
  let surname = ""
  let given = ""
  if name.contains(",") {
    let parts = name.split(",")
    surname = parts.at(0).trim()
    given = parts.at(1, default: "").trim()
  } else {
    let parts = name.split()
    surname = parts.at(-1, default: "")
    given = if parts.len() < 2 { "" } else { parts.slice(0, -1).join(" ") }
  }
  if not initials or given == "" { surname } else {
    given.split().map(word => upper(word.first()) + ".").join(" ") + " " + surname
  }
}

// Título del .bib -> texto: sin llaves de protección y con espacios colapsados.
#let _fmt-title(raw) = {
  _decode-name(raw).replace("{", "").replace("}", "").replace(regex("\\s+"), " ").trim()
}

// Lista de autores ya formateados -> "A", "A and B", "A et al." (et al.
// con et-al-min o más autores; "et al." en cursiva, estilo IEEE).
#let _authors-display(names, et-al-min) = {
  let count = names.len()
  if count == 0 { "" }
  else if count == 1 { names.first() }
  else if count >= et-al-min [#names.first() #emph[et al.]]
  else { names.slice(0, -1).join(", ") + " and " + names.at(-1) }
}

// Campo `name = {...}` o `name = "..."` (un nivel de llaves anidadas).
#let _field-pattern(name) = regex("(?i)\\b" + name + "\\s*=\\s*(?:\\{((?:[^{}]|\\{[^{}]*\\})*)\\}|\"([^\"]*)\")")
#let _field(chunk, name) = {
  let m = chunk.match(_field-pattern(name))
  if m == none { none } else { m.captures.filter(value => value != none).first() }
}

#let _parse-bib(raw, initials: false) = {
  let entries = (:)
  let key-pattern = regex("\\{([^,]*)")
  let year-pattern = regex("(?i)year\\s*=\\s*[{\"]?\\s*(\\d{4})")
  let author-separator = regex("(?i)\\s+and\\s+")
  for chunk in raw.split("@").slice(1) {
    let key-match = chunk.match(key-pattern)
    let key = if key-match == none { "" } else { key-match.captures.first().trim() }
    if key == "" { continue }
    // author; si la entrada no lo tiene (libro editado), editor
    let names = _field(chunk, "author")
    if names == none { names = _field(chunk, "editor") }
    let authors = if names == none { () } else {
      names.split(author-separator).map(name => _fmt-name(name, initials: initials))
    }
    let year-match = chunk.match(year-pattern)
    let year = if year-match == none { "" } else { year-match.captures.first() }
    let title = _field(chunk, "title")
    let title = if title == none { "" } else { _fmt-title(title) }
    entries.insert(key, (authors: authors, year: year, title: title))
  }
  entries
}

// Self-check del parser (falla la compilación si se rompe).
#assert.eq(_fmt-name("Smith, John"), "Smith")
#assert.eq(_fmt-name("John Smith"), "Smith")
#assert.eq(_fmt-name("Doe, Jane Q."), "Doe")
#assert.eq(_fmt-name("Smith, John", initials: true), "J. Smith")
#assert.eq(_fmt-name("John Smith", initials: true), "J. Smith")
#assert.eq(_fmt-name("Doe, Jane Q.", initials: true), "J. Q. Doe")
#assert.eq(_fmt-name("Smith"), "Smith")
#assert.eq(_fmt-name("Smith,"), "Smith")
#assert.eq(_fmt-name("Smith,", initials: true), "Smith")
#assert.eq(_decode-name("Jo\\~{a}o"), "João")
#assert.eq(_decode-name("Pawe\\l{} P{\\l}awiak"), "Paweł Pławiak")
#assert.eq(_decode-name("Garc\\'{\\i}a"), "García")
#assert.eq(_fmt-title("\n    {PPG}-based authentication: A\n    review\n  "), "PPG-based authentication: A review")
#assert.eq(_field("booktitle = {Proc. X},\n  title = {Real title},", "title"), "Real title")

// Construye los comandos a partir del contenido del .bib.
// et-al-min: nº de autores a partir del cual se recorta a "Primero et al."
// initials: true antepone las iniciales del nombre al apellido.
// multi-delim: separador de las formas múltiples (textcites).
#let biblatex-cites(bib-source, et-al-min: 3, initials: false, multi-delim: ", ") = {
  let entries = _parse-bib(bib-source, initials: initials)
  let lookup(key) = entries.at(str(key), default: none)
  let author-of(key, ..args) = { // "Autor et al." o, sin entrada, el formato del CSL
    let entry = lookup(key)
    if entry != none and entry.authors.len() > 0 {
      _authors-display(entry.authors, et-al-min)
    } else {
      cite(_as-label(key), form: "author", ..args)
    }
  }
  let textcite(key, ..args) = { // \textcite -> "Autor et al. [n]"
    let entry = lookup(key)
    if entry != none and entry.authors.len() > 0 {
      [#_authors-display(entry.authors, et-al-min) #cite(_as-label(key), ..args)]
    } else {
      cite(_as-label(key), form: "prose", ..args)
    }
  }
  let parencite(key, ..args) = cite(_as-label(key), ..args) // \parencite / \cite -> [n]
  // Varias claves: las citas adyacentes las agrupa Typst ("[1], [2]" o "[1]-[3]").
  let parencites(..keys) = keys.pos().map(key => cite(_as-label(key))).join([ ])
  (
    parencite: parencite,
    autocite: parencite, // \autocite: en estilos numéricos equivale a \parencite
    cites: parencites, // \cites
    parencites: parencites, // \parencites
    fullcite: (key, ..args) => cite(_as-label(key), form: "full", ..args), // \fullcite
    footcite: (key, ..args) => footnote(cite(_as-label(key), ..args)), // \footcite
    footfullcite: (key, ..args) => footnote(cite(_as-label(key), form: "full", ..args)), // \footfullcite
    supercite: (key, ..args) => super(cite(_as-label(key), ..args)), // \supercite: [n] en superíndice
    nocite: (..keys) => place(hide(keys.pos().map(key => cite(_as-label(key))).join())), // \nocite
    textcite: textcite,
    textcites: (..keys) => keys.pos().map(key => textcite(key)).join(multi-delim), // \textcites
    citeauthor: author-of, // \citeauthor -> "Autor et al."
    citeyear: (key, ..args) => { // \citeyear -> "2024"
      let entry = lookup(key)
      if entry != none and entry.year != "" {
        entry.year
      } else {
        cite(_as-label(key), form: "year", ..args)
      }
    },
    citetitle: key => { // \citetitle -> título de la entrada
      let entry = lookup(key)
      if entry == none { panic("citetitle: key not found in the .bib: " + str(key)) }
      if entry.title == "" { panic("citetitle: entry has no title: " + str(key)) }
      entry.title
    },
  )
}
