#import "../biblatex-cites/lib.typ": biblatex-cites
#let (textcite, parencite, citeauthor, citeyear, fullcite, citetitle, textcites, parencites, cites, autocite, footcite, footfullcite, supercite, nocite) = biblatex-cites(
  read("fixtures/cancelable.bib"),
  et-al-min: 99,
)
#let (citeauthor: citeauthor-ini,) = biblatex-cites(read("fixtures/cancelable.bib"), et-al-min: 99, initials: true)
#let (citeauthor: citeauthor-etal,) = biblatex-cites(read("fixtures/cancelable.bib"))

#assert.eq(citeyear(<Patel2015>), "2015")
#assert.eq(citeyear(<KrivokucaHahn2026>), "2026")
// surname-only (default)
#assert.eq(citeauthor(<Rathgeb2011>), "Rathgeb and Uhl")
#assert.eq(citeauthor(<Farago2019>), "Faragó, Groza, Ivanciu and Hintea")
#assert.eq(citeauthor(<Sakr2022>), "Sakr, Pławiak, Tadeusiewicz and Hammad")
#assert.eq(citeauthor(<Hammad2026>), "Hammad, Meshoul, Bacanin, Pławiak and Fadl")
#assert.eq(citeauthor(<Aguilar2025>), "Aguilar, Martínez-Cruz, Ramírez-Gutiérrez and Morales-Sandoval")
#assert.eq(citeauthor(<Sancho2018>), "Sancho, Alesanco and García")
#assert.eq(citeauthor(<Pinto2017>), "Pinto, Cardoso, Lourenço and Carreiras")
// editor-only entry falls back to the editors
#assert.eq(citeauthor(<KrivokucaHahn2026>), "Krivokuća Hahn, Gomez-Barrero, Ross and Marcel")
// initials: true keeps the old rendering
#assert.eq(citeauthor-ini(<Rathgeb2011>), "C. Rathgeb and A. Uhl")
#assert.eq(citeauthor-ini(<Aguilar2025>), "D. Aguilar, A. Martínez-Cruz, K. A. Ramírez-Gutiérrez and M. Morales-Sandoval")
// default et-al-min: 3 -> "First et al."
#assert(repr(citeauthor-etal(<Aguilar2025>)).contains("Aguilar"))
#assert(repr(citeauthor-etal(<Aguilar2025>)).contains("et al."))

#assert(repr(textcite(<Farago2019>)).contains("Faragó"))
// string keys work like labels
#assert.eq(citeauthor("Rathgeb2011"), "Rathgeb and Uhl")
// titles: braces removed, whitespace collapsed, booktitle not confused with title
#assert.eq(citetitle(<Rathgeb2011>), "A survey on biometric cryptosystems and cancelable biometrics")
#assert.eq(citetitle("Aguilar2025"), "PPG-based biometric authentication: A review on architectures, datasets, attacks and security challenges")
#assert.eq(citetitle(<KrivokucaHahn2026>), "Handbook of Biometric Template Protection: Motivation, Methods and Metrics")
// multiple and other forms (rendered below; must compile)
#assert(repr(textcites(<Rathgeb2011>, "Sakr2022")).contains("Rathgeb"))
#assert(repr(textcites(<Rathgeb2011>, "Sakr2022")).contains("Sakr"))

#textcite(<Aguilar2025>). Several: #textcites("Rathgeb2011", "Sakr2022"). Grouped: #parencites("Rathgeb2011", "Sakr2022", "Hammad2026"); #cites("Farago2019", "Pinto2017"); auto #autocite("Sancho2018"). Super#supercite("Patel2015") and foot#footcite("Rathgeb2011") and full#footfullcite("Sakr2022").
#nocite("Pinto2017", "Sancho2018")
#bibliography("fixtures/cancelable.bib", style: "ieee")
