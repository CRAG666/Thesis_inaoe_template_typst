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

// Rendimiento: Typst no cachea regex(...) (compilar cuesta ~1 ms) y cada
// búsqueda arranca con el autómata vacío, más caro con clases Unicode
// (\s, \d, \b). Por eso las regex se compilan una vez aquí, usan clases
// ASCII (?-u:...) y el .bib se recorre con una sola llamada a matches().
#let _accent-marks = ("'": "\u{0301}", "~": "\u{0303}", c: "\u{0327}")
#let _accent-pattern = regex("\\{?\\\\(['~c])(?:\\{(\\\\i|[A-Za-z])\\}|(\\\\i|[A-Za-z]))\\}?")
#let _stroke-pattern = regex("\\{?\\\\l(?:\\{\\})?\\}?")
#let _year-pattern = regex("^(?-u:\\s)*([0-9]{4})")
#let _author-separator = regex("(?-u:\\s)+(?i:and)(?-u:\\s)+")
// En orden de aparición: cabecera `@tipo{clave,` (sin clave en @string,
// @comment...) o campo `nombre = {...}` / `"..."` / valor suelto (un nivel
// de llaves anidadas). Capturas: clave, nombre, {valor}, "valor", valor.
#let _bib-pattern = regex(
  "@(?-u:\\w)+(?-u:\\s)*[{(](?:(?-u:\\s)*([^\\x00-\\x20,={}()]+)(?-u:\\s)*,)?"
    + "|(?-u:\\b)((?-u:\\w)+)(?-u:\\s)*=(?-u:\\s)*"
    + "(?:\\{((?:[^{}]|\\{[^{}]*\\})*)\\}|\"([^\"]*)\"|((?-u:\\w)+))",
)
// Solo las cabeceras `@tipo{clave,`: refs-as-cites no necesita los campos.
#let _key-pattern = regex("@(?-u:\\w)+(?-u:\\s)*[{(](?-u:\\s)*([^\\x00-\\x20,={}()]+)(?-u:\\s)*,")

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
  _decode-name(raw).replace("{", "").replace("}", "").split().join(" ")
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

// Campos crudos de una entrada -> (authors, year, title) ya formateados.
#let _make-entry(fields, initials) = {
  // author; si la entrada no lo tiene (libro editado), editor
  let names = fields.at("author", default: fields.at("editor", default: none))
  let year-match = fields.at("year", default: "").match(_year-pattern)
  let title = fields.at("title", default: none)
  (
    authors: if names == none { () } else {
      names.split(_author-separator).map(name => _fmt-name(name, initials: initials))
    },
    year: if year-match == none { "" } else { year-match.captures.first() },
    title: if title == none { "" } else { _fmt-title(title) },
  )
}

#let _parse-bib(raw, initials: false) = {
  let entries = (:)
  let key = none
  let fields = (:)
  for m in raw.matches(_bib-pattern) {
    let (entry-key, name, braced, quoted, bare) = m.captures
    if name == none { // cabecera: cierra la entrada anterior
      if key != none { entries.insert(key, _make-entry(fields, initials)) }
      key = entry-key
      fields = (:)
      continue
    }
    let name = lower(name)
    // author/editor/title solo entre llaves o comillas; year también suelto.
    let value = if braced != none { braced } else if quoted != none { quoted } else if name == "year" { bare }
    if key != none and value != none and name in ("author", "editor", "title", "year") and name not in fields {
      fields.insert(name, value)
    }
  }
  if key != none { entries.insert(key, _make-entry(fields, initials)) }
  entries
}

// `@clave` crea un ref, que Typst resuelve por introspección y le cuesta una
// iteración de layout completa extra (~25-30 % del tiempo en una tesis). Esta
// regla convierte en cite los ref a claves del .bib antes de resolverlos; el
// resultado es idéntico. Uso: #show ref: refs-as-cites(read("references.bib"))
#let refs-as-cites(bib-source) = {
  let keys = bib-source.matches(_key-pattern).map(m => (m.captures.first(), none)).to-dict()
  it => {
    if it.form != "normal" or str(it.target) not in keys or type(it.supplement) == function {
      it
    } else if it.supplement == auto {
      cite(it.target)
    } else {
      cite(it.target, supplement: it.supplement) // @clave[p. 10]
    }
  }
}

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
