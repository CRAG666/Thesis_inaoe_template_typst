#import "../biblatex-cites/lib.typ": _decode-name, _fmt-name, _fmt-title, _parse-bib, biblatex-cites, refs-as-cites

// parser internals
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
#assert.eq(_parse-bib("@misc{k, booktitle = {Proc. X},\n  title = {Real title},}").k.title, "Real title")
// field names are case-insensitive; years may be bare, braced or quoted
#assert.eq(
  _parse-bib("@Article{a, AUTHOR = \"Doe, J.\", Year = 2019}\n@book(b, editor = {Roe, R. and Poe, E.}, year = { 2021 })"),
  (a: (authors: ("Doe",), year: "2019", title: ""), b: (authors: ("Roe", "Poe"), year: "2021", title: "")),
)
// `@` inside a field, @string/@comment blocks and `origyear` don't confuse the parser
#assert.eq(
  _parse-bib("@string{author = {Nobody}}\n@online{c, url = {https://x.org/@me{1}}, origyear = {1900}, author = {Ann Lee}, year = {2020}}\n@comment{year = 1999}"),
  (c: (authors: ("Lee",), year: "2020", title: "")),
)

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

// @key of a .bib entry becomes a cite; refs to document labels stay refs
#show ref: refs-as-cites(read("fixtures/cancelable.bib"))
#set heading(numbering: "1.")
= Section <sec>
See @sec, @Patel2015 and @Hammad2019[p. 10].
#bibliography("fixtures/cancelable.bib", style: "ieee")
