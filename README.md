# A LaTeX Cookbook

[![forthebadge](https://forthebadge.com/images/badges/gluten-free.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/compatibility-club-penguin.svg)](https://forthebadge.com)

---

> [Remember, a few hours of trial and error can save you several minutes of looking at the README.](https://twitter.com/iamdevloper/status/1060067235316809729)

---

This repo contains a [LaTeX](https://en.wikipedia.org/wiki/LaTeX) [document](cookbook.tex), usable as a cookbook (different "recipes" to achieve various things in LaTeX) and also as a template.
The resulting PDF covers LaTeX-specific topics and instructions on compiling the LaTeX source using Docker.
It is available for [**download**](https://collaborating.tuhh.de/alex/latex-git-cookbook/-/jobs/artifacts/master/raw/cookbook.pdf?job=tex).

This very README is also made available for [download as a PDF](https://collaborating.tuhh.de/alex/latex-git-cookbook/-/jobs/artifacts/master/raw/README.pdf?job=README.pdf), converted from Markdown using [pandoc](https://pandoc.org/) with the [*Eisvogel*](https://github.com/Wandmalfarbe/pandoc-latex-template) template.

## Appendix

### Hints for source files

These are valid not only for LaTeX files, but most text-based source files:

- For the love of God, use `UTF-8` (and *only* `UTF-8`, not [anything higher](https://news.ycombinator.com/item?id=26737049))
  for text encoding.
  Stop using `Windows 1252`, `Latin` etc.
  Existing files can be easily updated to UTF-8 without much danger for regression
  (*i.e.*, introducing errors).
- Put each sentence, or even part of a sentence, and each instruction onto its own line.
  This is very important to `diff` files properly, aka `git diff`.
  Generally, [keep lines short](https://tex.stackexchange.com/q/325505/120853).
- In a similar vein, use indentation appropriately. Indent using **4 spaces**.
  There are schools of thought that advocate two spaces, or also one tab.
  Ultimately, that does not really matter.
  'Four spaces' just seems to generally win the fight for a common coding style,
  bringing us to the next point.
- **Be consistent**. Even if you pull your own custom stuff, at least be consistent in doing so.
  This makes things predictable, the code will be easier to read, and also more easily
  changed programmatically.
  GNU/Linux and by extension Windows using
  [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)
  has a very wide range of tools that make search, and search-and-replace, and various other
  operations for plain text files easy.
  The same is true for similar tools in IDEs.
  However, if the text is scattered and the style was mangled and fragmented into various
  sub-styles, this becomes very hard.
  For example, one person might use `$<math>$` for inline-LaTeX math, another the
  ([preferred](https://tex.stackexchange.com/q/510/120853)) `\(<math>\)` style.
  Suddenly, you would have to search for both versions to find all inline-math.
  So stay consistent. If you work on pre-existing documents, use the established style.
  If you change it, change it fully, and not just for newly added work.

### Hints on Fonts

We use beautiful, capable fonts based on
[TeX Gyre](http://www.gust.org.pl/projects/e-foundry/tex-gyre/index_html)
for high-quality typesetting.
Particularly, [*TeX Gyre Pagella*](http://www.gust.org.pl/projects/e-foundry/tex-gyre/pagella)
as an open and free *Palatino* (by [Hermann Zapf](https://en.wikipedia.org/wiki/Hermann_Zapf))
clone.
It comes with [an accompanying math font](http://www.gust.org.pl/projects/e-foundry/tg-math),
*TeX Gyre Pagella Math*.
This is *extremely* important, since only with two matching (or even basically identical
fonts like in our case) fonts will a document like this one here look good.
If math and text fonts don't mix well, it will look terrible.
If the math font is not highly capable and provides all the glyphs we need,
it will also look terrible.

There aren't very many high-quality free fonts with a math companion available,
see [this compilation](https://tex.stackexchange.com/a/425099/120853).
A similar compilation of 'nice' fonts is [found here](https://tex.stackexchange.com/a/59706/120853),
however that is specifically for `pdflatex`, not `lualatex`.
Of all of the available ones, *Pagella* was chosen.
This can be changed with relative ease in the package options for the responsible package,
[`unicode-math`](https://ctan.org/pkg/unicode-math?lang=en).
If the new font does not come with at least the same amount of features,
parts of the document might break!
There is also a list of
[symbols defined by unicode-math](http://mirrors.ctan.org/macros/latex/contrib/unicode-math/unimath-symbols.pdf)
for reference.

`unicode-math` builds on top of and loads, then extends, `fontspec`.
`fontspec` is a package for `lualatex` and `xelatex` designed to allow usage of outside, system
fonts (as opposed to fonts that ship with latex distributions/packages).
These can be system-installed fonts, but **we bring our own fonts**, and they reside in this directory.
This is to ensure everyone can compile this repository/document,
as long as they have this subdirectory intact.
It is also OS-agnostic
(with system-installed fonts, calling them by their name can get really out of hand;
with plain filenames, we know exactly what to call them).
Some fonts ship with regular LaTeX distributions and are available *without* being explicitly installed by the user.
TeX Gyre fonts are an example.
These need to neither be included here nor installed, they are ship with the LaTeX installation (TeXLive).

The distinct advantage of `unicode-math` over its parent `fontspec` is the additional
feature of a **math font** (`\setmathfont`).

Note that `unicode-math` **requires** `lua(la)tex` or `xe(la)tex`.
You cannot compile this document with `pdf(la)tex`.
This also means that the packages `inputenc` and `fontenc` are *not needed*.
In fact, they are, as far as I know, incompatible and may break the document.
They used to be employed to allow advanced encoding for both the plain-text source as
well as the output PDF.
This allowed usage of Umlauts *etc.*, but that's a relic of a distant past.
In fact, if we wanted to, we could input Unicode characters *directly into the source code*,
*e.g.* `\(α = 2\)` over `\(\alpha = 2\)`
(we don't do this because we use an entirely different system in the form of [`glossaries-extra`](glossaries)).

Now, it remains to choose between `lualatex` and `xelatex`
(`luatex` and `xetex` exist too, but output to `DVI`, which we don't care for nowadays;
`lualatex` and `xelatex` output to `PDF`).
The choice falls to `lualatex` and is quite easy:

- we make use of the `contour` packages to print characters (of any color) with a thick
  contour aka background around them (in any color as well).
  Of course, the most obvious use is black text with a white contour.
  Text set like that will be legible on various colored or otherwise obstructed
  (for example by plot grids) page backgrounds.
  To this purpose, there is the command `\ctrw{<text>}`, which is used *a lot*.
  The `contour` capabilities don't care for math mode, font weight, size, shape...
  it all just works.

  Finally, the kicker here is that **it does not work in `xelatex`**.
  I tried [this](https://tex.stackexchange.com/questions/421970/contour-text-in-xelatex)
  and [this](https://tex.stackexchange.com/questions/354410/how-should-the-effects-of-manipulating-specials-be-switched-off)
  and [this](https://tex.stackexchange.com/questions/225637/how-to-add-outline-to-a-character-under-xelatex)
  and lastly [this](https://tex.stackexchange.com/questions/25221/outlined-characters)
  and eventually failed horribly.
- further, `pdflatex`, with its roots in probably the 80s,
  still to this day has strict and low memory limits.
  For more advanced computations, it will
  [complain and claim to be out of memory](https://tex.stackexchange.com/questions/7953/how-to-expand-texs-main-memory-size-pgfplots-memory-overload)
  (the good old `TeX capacity exceeded, sorry`),
  when in reality the host computer has Gigabytes and Gigabytes of RAM to spare.
  This lead to the package/library `tikz-externalize`,
  which puts Ti*k*z-pictures into their own compile jobs.
  That way, each job is much smaller and can succeed within memory limits.
  Another way to solve the limitation is to increase all the various memory limits manually,
  to arbitrarily high values.
  That this seems laborious, hacky and, well, arbitrary, is quickly apparent.

  Now, even if we used `tikz-externalize`, it truncates the features we can make use of.
  Since it exports the Ti*k*z environments to outside PDFs and then inputs those,
  **labels/references/links cannot really be supported**.
  I noticed this when I wanted equation references as a legend
  (if that is a good idea is another question ...).
  So `tikz-externalize` and its many caveats
  (despite it being a brilliant solution to a problem we shouldn't even be having anymore nowadays)
  is off the table.

  `lualatex` simply solves all these concerns: it allocates memory as required.
  I don't know to what degree it does this (if it can fill up modern machine memory),
  but I can compile our entire document with countless Ti*k*z environments and demanding
  plots (with high `sample=` values) with no memory issues.
  As far as I know, `xelatex` doesn't do this, so forget about it.

These two reasons are easily enough to choose `lualatex` over `xelatex`.
I don't have more reasons anyway, since otherwise, the programs are quite identical.
