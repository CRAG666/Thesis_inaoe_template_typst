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

#let _k(key) = if type(key) == label { key } else { label(key) }
#let _key-str(key) = if type(key) == label { repr(key).slice(1, -1) } else { key }

// "Apellido, Nombre M." / "Nombre M. Apellido" -> "N. M. Apellido"
#let _fmt-name(raw) = {
  let s = raw.trim()
  let surname = ""
  let given = ""
  if s.contains(",") {
    let p = s.split(",")
    surname = p.at(0).trim()
    given = p.at(1, default: "").trim()
  } else {
    let p = s.split(" ").filter(w => w != "")
    surname = p.at(-1, default: "")
    given = p.slice(0, -1).join(" ")
  }
  let initials = given.split(" ").filter(w => w != "")
    .map(w => upper(w.clusters().first()) + ".").join(" ")
  if initials == "" { surname } else { initials + " " + surname }
}

// Lista de autores ya formateados -> "A", "A and B", "A et al." (et al.
// con et-al-min o más autores; "et al." en cursiva, estilo IEEE).
#let _authors-display(names, et-al-min) = {
  let n = names.len()
  if n == 0 { "" }
  else if n == 1 { names.at(0) }
  else if n >= et-al-min [#names.at(0) #emph[et al.]]
  else { names.slice(0, -1).join(", ") + " and " + names.at(-1) }
}

#let _parse-bib(raw) = {
  let entries = (:)
  for chunk in raw.split("@").slice(1) {
    let key = chunk.split("{").at(1, default: "").split(",").at(0).trim()
    if key == "" { continue }
    let authors = ()
    let am = chunk.match(regex("(?i)author\\s*=\\s*[{\"]([^}\"]*)[}\"]"))
    if am != none {
      authors = am.captures.at(0).split(regex("(?i)\\s+and\\s+")).map(_fmt-name)
    }
    let year = ""
    let ym = chunk.match(regex("(?i)year\\s*=\\s*[{\"]?\\s*(\\d{4})"))
    if ym != none { year = ym.captures.at(0) }
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
  let lookup(key) = entries.at(_key-str(key), default: none)
  (
    parencite: (key, ..a) => cite(_k(key), ..a),               // \parencite / \cite -> [n]
    fullcite: (key, ..a) => cite(_k(key), form: "full", ..a),  // \fullcite
    textcite: (key, ..a) => {                                  // \textcite -> "Autor et al. [n]"
      let e = lookup(key)
      if e != none and e.authors.len() > 0 [#_authors-display(e.authors, et-al-min) #cite(_k(key), ..a)]
      else { cite(_k(key), form: "prose", ..a) }
    },
    citeauthor: (key, ..a) => {                                // \citeauthor -> "Autor et al."
      let e = lookup(key)
      if e != none and e.authors.len() > 0 { _authors-display(e.authors, et-al-min) }
      else { cite(_k(key), form: "author", ..a) }
    },
    citeyear: (key, ..a) => {                                  // \citeyear -> "2024"
      let e = lookup(key)
      if e != none and e.year != "" { e.year } else { cite(_k(key), form: "year", ..a) }
    },
  )
}
