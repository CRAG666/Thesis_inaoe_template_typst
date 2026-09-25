// ============================================================
//  Tesis INAOE  –  ejemplo (Typst)
// ============================================================

#import "inaoe-tesis.typ": inaoe-thesis, appendix, textcite, parencite, citeauthor, citeyear, fullcite

#show: inaoe-thesis.with(
  lang: "en", // "es" para español
  title: "A Continuous User Authentication Scheme Using PPG Signals from Wearable Devices",
  author: "Diego Cruz Aguilar",
  advisor: [Dr. Alfonso Martínez Cruz \ Dra. Kelsey A. Ramírez Gutiérrez],
  degree: "M.S. in Computer Science",
  month: "October",
  // year: 2025,  // opcional; si se omite usa el año actual

  dedication: [Dedicado a...],
  acknowledgements: [I wish to express my sincere gratitude to...],
  abstract: [This thesis presents...],
)

= Introduction

== Background

Text...

== Problem Statement

Text...

= Related Work

Text...

= Methodology

Text @exampleRef.
Text #textcite(<exampleRef>).

// \textcite recorta a "Primero et al." con 3+ autores, pero la lista de
// Referencias muestra todos (recuentos separados, como biblatex):
Con más de cuatro autores: #textcite(<manyAuthors>).

Con sufijo: #parencite(<exampleRef>, supplement: [p. 10]) y solo año #citeyear(<exampleRef>).

// ---- Formas de citar en Typst -------------------------------
// Equivalencias con LaTeX (estilo IEEE numérico integrado):
//
//   LaTeX                Alias de la plantilla            Resultado
//   \cite{key}           @key  o  #parencite(<key>)        [1]
//   \textcite{key}       #textcite(<key>)                  J. Smith et al. [1]
//   \citeauthor{key}     #citeauthor(<key>)                J. Smith et al.
//   \citeyear{key}       #citeyear(<key>)                  2024
//   \cite[p. 10]{key}    #parencite(<key>, supplement: [p. 10])   [1, p. 10]
//
// La forma corta `@key` -> [n]; admite sufijo: `@key[p. 10]`.
// Los alias (textcite/citeauthor/citeyear) leen los nombres del .bib en
// biblatex-cites/lib.typ; el formato de [n] y de Referencias lo da Typst.

= Results

Text...

= Conclusions and Future Work

== Conclusions

Text...

== Future Work

Text...

// ---- Apéndices ----------------------------------------------
#show: appendix

= Published Articles

- *Article title*, Journal Name, 2025.

// ---- Bibliografía -------------------------------------------
// Estilo IEEE integrado de Typst (numérico): Referencias con todos los
// autores y et al. en 7+. El recorte "et al." de #textcite NO depende de
// esto; se controla en biblatex-cites mediante et-al-min.
#context bibliography("references.bib", style: "ieee",
  title: if text.lang == "es" { "Referencias" } else { "References" })
