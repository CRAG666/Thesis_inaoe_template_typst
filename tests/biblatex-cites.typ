#import "../biblatex-cites/lib.typ": biblatex-cites
#let (textcite, parencite, citeauthor, citeyear, fullcite) = biblatex-cites(
  read("fixtures/cancelable.bib"),
  et-al-min: 99,
)

#assert.eq(citeyear(<Patel2015>), "2015")
#assert.eq(citeyear(<KrivokucaHahn2026>), "2026")
#assert.eq(citeauthor(<Rathgeb2011>), "C. Rathgeb and A. Uhl")
#assert.eq(citeauthor(<Farago2019>), "P. Faragó, R. Groza, L. Ivanciu and S. Hintea")
#assert.eq(citeauthor(<Sakr2022>), "A. S. Sakr, P. Pławiak, R. Tadeusiewicz and M. Hammad")
#assert.eq(citeauthor(<Hammad2026>), "M. Hammad, S. Meshoul, N. Bacanin, P. Pławiak and S. Fadl")
#assert.eq(citeauthor(<Aguilar2025>), "D. Aguilar, A. Martínez-Cruz, K. A. Ramírez-Gutiérrez and M. Morales-Sandoval")
#assert.eq(citeauthor(<Sancho2018>), "J. Sancho, Á. Alesanco and J. García")
#assert.eq(citeauthor(<Pinto2017>), "J. R. Pinto, J. S. Cardoso, A. Lourenço and C. Carreiras")

#assert(repr(textcite(<Farago2019>)).contains("Faragó"))
#textcite(<Aguilar2025>)
#bibliography("fixtures/cancelable.bib", style: "ieee")
