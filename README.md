# Yet Another Thesis Template

Jesus Christ, who needs that many templates?
Aren't there enough by now?

Well, this template has one fragile aspect setting it apart.
Currently (2019), it is one of the most modern approaches.
Most of its core aspects are actively maintained and/or are relatively new in themselves.
At the time of writing, the core packages
([unicode-math](https://github.com/wspr/unicode-math), [glossaries-extra](https://ctan.org/pkg/glossaries-extra), [polyglossia](https://github.com/reutenauer/polyglossia/), [luatex](http://www.luatex.org/index.html) itself, ...)
saw updates within the last few weeks.

TeX is moving slowly, and as such, best practices, packages and methods from over 10 years ago are still actively used today.
Templates are handed down the generations, catching serious dust in parts that haven't been touched in ages.
Sometimes, packages will be from the previous century.
**They all work well**, but not great.
This template is an attempt to only employ the latest and greatest of what the LaTeX world has to offer (and some of that is still old).
Outdated, no longer maintained packages are avoided if possible.

## Features

At the core of it all is the [thesis template preamble](./settings/yatt_thesis_preamble.tex) (as well as the [presentation preamble](./settings/yatt_presentation_preamble.tex)).
At some point, these could be turned into class files `*.cls`.
It works for now.

The [compiled output](yatt_thesis.pdf) ([presentation](yatt_presentation.pdf)) is also part of the repository.

### Toolbox

This template is also a toolbox:
many templates don't go into much depth about actually 'doing' LaTeX, e.g. Tikz/InkScape, Math, Lists, Beamer...

This document does that, and as such can also serve as a quick reference tool to copy-paste code skeletons for annoying tasks with syntactical complexity (subfigures, tables, ...).

**As such, this template is more about features, and less about design.**
Design is a slippery slope, and for every one beautiful way, there are ninety-nine lackluster ones.
Of those ninety-nine, the majority will be plain eyesores.
It is better left to pros, which is why this template does not do much in the way of design.

**Contributions to add more features/examples or nice design tweaks are very welcome.**

### Languages

An effort is made to provide support for multiple languages.
We can simply pass desired languages as (global) options to the `documentclass`.
They will be picked up by all relevant packages, mainly of course `polyglossia`.
Other packages that then employ the correct language settings are:

- `KOMAScript` itself (*Chapter*, *Kapitel*, ...)
- `cleveref` (*Equation 1.1*, *Gleichung 1.1*, ...)
- `datetime2` (*June 6, 2019*, *6. Juni 2019*, ...)
- `caption` (*Table*, *Tabelle*, ...)
- `csquotes` (*'Quote'*, *,,Zitat''*, ...)
- `biblatex`
- perhaps more...

Current languages with full support are:

- **english**, german

With **english** in bold as the language in mind when creating this template in the first place.
It will remain the main language.

Current languages with partial support are **all others**.
Here, *partial support* simply means that **all features** offered by the above mentioned packages **will work**.
For example, you can pass `language=french` in the `documentclass` options.
All translations that are custom to this template will not work.

You can add your own translations in [the respective file](yatt-translations.sty).

There is currently no hope to also have 'variants' of languages (like british for english).
`polyglossia` does not provide and interface for that, only for the main language (<https://tex.stackexchange.com/a/413592/120853>).

### Packages

We now ...

- use beautiful, capabale fonts based on [TeX Gyre](http://www.gust.org.pl/projects/e-foundry/tex-gyre/index_html) for high-quality typesetting.

  For that, we do not rely on a package implementation: we bring our own fonts.
  That way, if you have favourites of yours, you can quickly adapt this template.
  It can also take system-installed fonts, e.g. the beautiful *Consolas* that ships with Windows (but is not free).
- employ [KOMA-script](https://ctan.org/pkg/koma-script) to handle our `documentclass`.

  That is nothing new at all, but still dangerously underrated in my opinion.
  It offers a great set of sensible default values, so we essentially won't have to do anything and still get correct margins etc.

  Some of its built-in packages are especially noteworthy:
  - `tocbasic` for a gateway into managing content lists (Table of Contents etc.)
  - `scrlayer-scrpage`, offering page styles.
  These are used to set headers and footers.
  We do not use `fancyhdr`.
- compile using `lualatex` for full Unicode support.
No fiddling with `inputenc` or `fontenc` packages anymore --- let's move on.

  `lualatex` is the designated successor to `pdflatex`. It supports the `contour` package and allocates memory as needed (so `tikz-externalize` and its caveats are avoided).

  AFAIK, `xelatex` is not as versatile, yet is much more prevalent (double the number of hits on Google).
  All issues I ever had with `xelatex` (see above) were banished switching to `lualatex`.

- use `glossaries-extra`, the latest, most capable glossary/nomenclature/indexing package.
It is used with `bib2gls` as its backend (a Java tool) to draw entries from respective `*.bib`-files.
This is also used for symbols, allowing for a highly cross-referenced document with absolutely consistent symbol typesetting and global management of them.

  You can have your abbreviations/symbols/sub-superscripts in `*.bib` files now, with the familiar syntax (reminiscent of JSON) for the entries.
  Their order does not matter, they will be sorted by the `bib2gls` tool.
  The sorting can be customized to a dizzying degree --- or left out entirely, if you don't want it sorted.

  The resulting glossary/nomenclature can also be printed in a fully customized way.

  `nomencl` with [its hacks](https://tex.stackexchange.com/questions/112884/how-to-achieve-nomenclature-entries-like-symbol-description-dimension-and-uni) is no longer needed.
- a custom title-page.

  It is nothing fancy, but I had a very good run with it over the years.
  [It is right there in plain sight for you](./chapters/frontmatter/titlepage.tex), easily modified.
- `biblatex` with `biber`, the currently most powerful bibliography tool.
  Its manual is over 300 pages long and will exhaust your every desire.
- custom environments for code, chemical reactions and illustrations.
- multiple sub-indices using `splitindex` (however, this should better be done using `glossaries-extra` in the future).

- have a lot of control over figure and caption configurations combining `floatrow` and `caption`.
`floatrow` is actually a bit old and awkward to use.
We could probably use something more modern here.

- are free to use A5 paper.
I am a huge fan!
[Many people ask why the default margins are so damn large](https://tex.stackexchange.com/questions/71172/why-are-default-latex-margins-so-big) (also, in that question, they mention the package `geometry`; we have KOMA-script for that).
The margins aren't too large: the (default A4) paper is.
Only avid readers can process lines in excess of approx. 80 characters.
All others get headaches and find texts like that hard to read.
KOMA knows about that and the many other 'rules' aka conventions, producing the margins you see.

  There is very good reason books don't usually come in A4 or letter format.
  It is often much closer to A5, which suddenly *makes sense*: margins are small, the text fits nicely.
  It is nice to read and hold.
  If your document is an actual thesis of many dozens of pages, maybe look into using A5.

  To see it in effect, uncomment the options `a5paper` and `10pt` (we decrease the font size by 1pt, down from the default of `11pt`) in [the base file](yatt_thesis.tex) when calling the `documentclass`.
  At this point, there is a reward for careful typesetting: specifying lengths etc. in absolute units will likely break the document.
  Having done all that jazz in relation to `linewidth`, `textwidth` and their siblings will scale everything accordingly.
  Nevertheless, not all things will come out right.
  These will require manual attention.

  It is probably telling that a document of *X* pages in `a4paper` and `11pt` (the KOMA default) will come out to very close to *X* pages again in `a5paper` and `10pt`: we mainly cut out on wasted white-space and made better use of available space, without suddely requiring *2X* pages (since we halved the page size).

### Presentation

The presentation template is largely a fork of the popular [mtheme/metropolis](https://github.com/matze/mtheme).
The changes made to it are mostly additions, not ommisions or replacements, since that template is already very good.

As you can see, the presentation shares content with the thesis.
It uses the same ...

- [image directory](images),
- [`*.bib` files](glossaries) for `glossaries-extra`: all the exact same abbreviations, symbols etc.,
- [CSV files](data) for plotting,
- [bibliography file](yatt.bib),
- [abstract](/chapters/frontmatter/abstract.tex).

The presentation uses [different fonts](fonts/presentation).
They are currently not used (with `unicode-math`), for reasons mentioned in the presentation preamble.
The `metropolis` theme brings its own Fira fonts (but not math font), so that it still works.
Once the wonderful [Fira Math](https://github.com/firamath/firamath) font works better, we should probably switch to full `unicode-math` and `Fira Math` functionality.
It will look stunning!

## Build

If you don't have a distribution already, I recommend [TeX Live](https://www.tug.org/texlive/) as a full installation.
It comes with everything this template needs (save for Java for `bib2gls`).

All this is quickly built using `latexmk` with a custom [`latexmkrc`](latexmkrc) file.
It contains some Perl commands to make it work with `bib2gls` and `splitidx` and their generated auxiliary files.
`latexmk` is maintained by John Collins, who contributed the `splitidx` routine.
The entire thing should be OS agnostic.

A single call

```bash
latexmk filename
```

on our core TeX files will process the entire chain, containing

- `lualatex`,
- `bib2gls`,
- `splitindex`,
- `biber`.

Calling

```bash
latexmk
```

without any arguments will process all `*.tex` files found in the directory.

On Windows, such calls can be made by right-clicking into the Explorer Window (but not on a file or directory) while holding down *Shift* , then *Open PowerShell window here*.
Linux users will know what they are doing, I won't be able to help.

The produced PDF will be processed fully, with all contained cross-references, citations etc. in place.
Once you get used to what all the individual steps do, you won't need `latexmk` each time.
For quick building and debugging, when you don't care for anything else, running `lualatex` once will likely suffice.

### CI

The entire thing can also be used in Continuous Integration.
A script for GitLab, alongside a [Docker image](https://github.com/alexpovel/latex-java-docker), is found in [the config file](.gitlab-ci.yml).
I do not yet have an equivalent GitHub/Travis config.

During the build process, you can use [the metadata text file](gitmeta.txt) to `sed` the relevant entries.
These are grabbed by TeX to print the metadata directly into the generated PDF.
Suggestions on improving that pipeline are welcome!

## Known Issues

- `glossaries-extra`:

  Using `\glssetcategoryattribute{<category>}{indexonlyfirst}{true}`.
  For all items in `<category>`, it is meant to only add the very first reference to the printed glossary.
  If this reference is within a float, this breaks, and nothing shows up in the '`##2`' column.

  The way the document was set up, most symbols are currently affected.
  However, in an actual document, it is highly unlikely you will be referencing/using (with `\gls{<symbol>}`) symbols the first time in floating objects.
  Therefore, this problem is likely not a realistic issue.

- `glossaries-extra`:

  When using package `subimport`.
  That package introduces a neat structure to have subdirectories and do nested imports of `*.tex` files.
  But that might not be worth it, since it breaks many referencing functionalities in TeXStudio.

  More importantly, it seems to cause `glossaries-extra` to no longer recognize which references have occurred.
  We currently call `selection = all` in `\GlsXtrLoadResources` to load all stuff found in the respective `*.bib` file, regardless of whether it has actually been called at some point (using `\gls{}` *etc.*).
  This is a bit like if `biblatex` did not recognize cite commands.
