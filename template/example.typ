#import "@local/inaoe-tesis:0.1.0": inaoe-thesis, thesis-cites
#let bib-source = read("references.bib")
#let (textcite, parencite, citeauthor, citeyear, fullcite) = thesis-cites(bib-source)

#show: inaoe-thesis.with(
  lang: "es",
  title: "Título de la tesis",
  author: "Tu nombre",
  advisor: [Nombre del asesor],
  degree: "Grado académico",
  month: "Mes",
  abstract: [Escribe aquí el resumen de tu tesis.],
  bib-source: bib-source,
)

= Introducción

Escribe aquí tu tesis. Puedes citar una referencia con @exampleRef.

= Metodología

Describe tu metodología.

= Conclusiones

Presenta tus conclusiones.
