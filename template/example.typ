// ============================================================
//  Tesis INAOE  –  ejemplo (Typst)
// ============================================================

#import "@local/inaoe-tesis:0.1.0": appendix, inaoe-thesis, thesis-cites
#let bib-source = read("references.bib")
#let (textcite, parencite, citeauthor, citeyear, fullcite) = thesis-cites(bib-source)

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
  bib-source: bib-source,
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
Con más de tres autores: #textcite(<manyAuthors>).

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
// Los alias (textcite/citeauthor/citeyear) leen los nombres del .bib desde
// este documento; el formato de [n] y de Referencias lo da Typst.

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
