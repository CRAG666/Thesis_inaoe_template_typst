// ============================================================
//  biblatex-cites  –  comandos de cita estilo biblatex para Typst
//
//  textcite / parencite / citeauthor / citeyear / fullcite, con recuento
//  de nombres SEPARADO entre las citas del texto y la lista de
//  Referencias (como maxcitenames/maxbibnames de biblatex+biber).
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
//    ... #textcite(<key>) ...  #citeyear(<key>) ...
//    #bibliography("references.bib", style: "ieee")
//
//  Nota: read() debe llamarse en TU archivo (resuelve la ruta relativa a
//  él), no dentro del paquete.
//  Limitación del parser: claves de autor sin llaves anidadas (p. ej.
//  "Apellido, Nombre" o "Nombre Apellido").
// ============================================================

#let _as-label(key) = label(str(key))

// "Apellido, Nombre M." / "Nombre M. Apellido" -> "N. M. Apellido"
#let _fmt-name(raw) = {
  let name = raw.trim()
  let surname = ""
  let given = ""
  if name.contains(",") {
    let parts = name.split(",")
    surname = parts.at(0).trim()
    given = parts.at(1, default: "").trim()
  } else {
    let parts = name.split()
    surname = parts.at(-1, default: "")
    given = parts.slice(0, -1).join(" ")
  }
  let initials = given.split().map(word => upper(word.first()) + ".").join(" ")
  if initials == "" { surname } else { initials + " " + surname }
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

#let _parse-bib(raw) = {
  let entries = (:)
  for chunk in raw.split("@").slice(1) {
    let key = chunk.split("{").at(1, default: "").split(",").at(0).trim()
    if key == "" { continue }
    let author-match = chunk.match(regex("(?i)author\\s*=\\s*[{\"]([^}\"]*)[}\"]"))
    let authors = if author-match == none { () } else {
      author-match.captures.first().split(regex("(?i)\\s+and\\s+")).map(_fmt-name)
    }
    let year-match = chunk.match(regex("(?i)year\\s*=\\s*[{\"]?\\s*(\\d{4})"))
    let year = if year-match == none { "" } else { year-match.captures.first() }
    entries.insert(key, (authors: authors, year: year))
  }
  entries
}

// Self-check del parser de nombres (falla la compilación si se rompe).
#assert.eq(_fmt-name("Smith, John"), "J. Smith")
#assert.eq(_fmt-name("John Smith"), "J. Smith")
#assert.eq(_fmt-name("Doe, Jane Q."), "J. Q. Doe")

// Construye los comandos a partir del contenido del .bib.
// et-al-min: nº de autores a partir del cual se recorta a "Primero et al."
#let biblatex-cites(bib-source, et-al-min: 3) = {
  let entries = _parse-bib(bib-source)
  let lookup(key) = entries.at(str(key), default: none)
  (
    parencite: (key, ..args) => cite(_as-label(key), ..args), // \parencite / \cite -> [n]
    fullcite: (key, ..args) => cite(_as-label(key), form: "full", ..args), // \fullcite
    textcite: (key, ..args) => { // \textcite -> "Autor et al. [n]"
      let entry = lookup(key)
      if entry != none and entry.authors.len() > 0 {
        [#_authors-display(entry.authors, et-al-min) #cite(_as-label(key), ..args)]
      } else {
        cite(_as-label(key), form: "prose", ..args)
      }
    },
    citeauthor: (key, ..args) => { // \citeauthor -> "Autor et al."
      let entry = lookup(key)
      if entry != none and entry.authors.len() > 0 {
        _authors-display(entry.authors, et-al-min)
      } else {
        cite(_as-label(key), form: "author", ..args)
      }
    },
    citeyear: (key, ..args) => { // \citeyear -> "2024"
      let entry = lookup(key)
      if entry != none and entry.year != "" {
        entry.year
      } else {
        cite(_as-label(key), form: "year", ..args)
      }
    },
  )
}
