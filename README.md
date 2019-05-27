# Yet Another Thesis Template

Jesus Christ, who needs that many templates?
Aren't there enough by now?

Well, this template has one fragile advantage.
Currently (2019), it is one of the most modern approaches.
Most of its core aspects are actively maintained and/or are relatively new in themselves.
At the time of writing, the core packages ([unicode-math](https://github.com/wspr/unicode-math), [glossaries-extra](https://ctan.org/pkg/glossaries-extra), [luatex](http://www.luatex.org/index.html) itself, ...) saw updates within the last few weeks.

TeX is moving slowly, and as such, best practices, packages and methods from over 10 years ago are still actively used today.
Sometimes, packages will be from the previous century.
They all work well, but not great.
This template is an attempt to only employ the latest and greatest of what the LaTeX world has to offer (and some of that is still old).
Outdated, no longer maintained packages are avoided if possible.

## Features

At the core of it all is [the preamble](./settings/preamble.tex).
At some point, this could be turned into a class file `*.cls`.
It works for now.

The [compiled output](main.pdf) is also part of the repository.

### Toolbox

This template is also a toolbox:
many templates don't go into much depth about actually 'doing' LaTeX, e.g. Tikz/InkScape, Math, Lists, ...

This document does that, and as such can also serve as a quick reference tool to copy-paste code skeletons for annoying tasks with syntactical complexity (subfigures, tables, ...).

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
No fiddling with `inputenc` or `fontenc` packages anymore. Forget about those, it is high time to move on.

  `lualatex` is the designated successor to `pdflatex`. It supports the `contour` package and allocates memory as needed (so `tikz-externalize` and its many caveats are avoided).

  AFAIK, `xelatex` is not as versatile, yet is much more prevalent (double the number of hits on Google).
  All issues I ever had with `xelatex` (see above) were banished switching to `lualatex`.

- use `glossaries-extra`, the latest, most capable glossary/nomenclature/indexing package.
It is used with `bib2gls` as its backend (a Java tool) to draw entries from respective `*.bib`-files.
This is also used for symbols, allowing for a highly cross-referenced document with absolutely consistent symbol typesetting and global management of them.

  You can have your abbreviations/symbols/sub-superscripts in `*.bib` files now, with the familiar syntax (reminiscent of JSON) for the entries.
  Their order does not matter, they will be sorted by the `bib2gls` tool.
  The sorting can be customized to a dizzying degree --- or left out entirely, if you don't want it sorted.

  The resulting glossary/nomenclature can also be printed in a fully customized way.

  `nomencl` with [its hacky functionalities](https://tex.stackexchange.com/questions/112884/how-to-achieve-nomenclature-entries-like-symbol-description-dimension-and-uni) is no longer needed.
- a custom title-page.

  It is nothing fancy, but I had a very good run with it over the years.
  [It is right there in plain sight for you](./chapters/frontmatter/titlepage.tex), easy to modify.
- `biblatex` with `biber`, the currently most powerful bibliography tool.

  Its manual is over 300 pages long and will exhaust your every desire.
- custom environments for code, chemical reactions and illustrations.
- multiple sub-indices using `splitindex` (however, this should better be done using `glossaries-extra` in the future).

- have a lot of control over figure and caption configurations combining `floatrow` and `caption`.
`floatrow` is actually a bit old and awkward to use.
We could probably use something more modern here.

- are free to use A5 paper.
I am a *huge* fan.
[Many people ask why the default margins are so damn large](https://tex.stackexchange.com/questions/71172/why-are-default-latex-margins-so-big) (by the way, in that question, they mention the package `geometry`; we have KOMA-script for that, don't touch `geometry`).
The margins aren't too large: the (default A4) paper is.
Only real bookworms can process lines in excess of approx. 80 characters.
All others get headaches and find texts like that hard to read.
KOMA knows about that and the many other 'rules' aka conventions, producing the margins you see.

  There is very good reason books don't usually come in A4 or letter format.
  It is often much closer to A5, which suddenly *makes sense*: margins are small, the text fits nicely.
  It is nice to read and hold.
  If your document is an actual thesis of many dozens of pages, consider using A5.

  To see it in effect, uncomment the options `a5paper` and `10pt` (we decrease the font size by 1pt, down from the default of `11pt`) in [the base file](main.tex) when calling the `documentclass`.
  At this point, there is a reward for careful typesetting: specifying lengths etc. in absolute units will break the document.
  Having done all that jazz in relation to `linewidth`, `textwidth` and their siblings will scale everything accordingly.
  Nevertheless, not all things will come out right.
  These will require manual attention.

  It is probably telling that a document of *X* pages in `a4paper` and `11pt` (the KOMA default) will come out to very close to *X* pages again in `a5paper` and `10pt`: we mainly cut out on wasted white-space and made better use of available space, without suddely requiring *2X* pages (since we halved the page size).

## Build

If you don't have a distribution already, I recommend [TeX Live](https://www.tug.org/texlive/) as a full installation.
It comes with everything this template needs (save for Java for `bib2gls`).

All this is quickly built using `latexmk` with a custom [`latexmkrc`](latexmkrc) file.
It contains some Perl commands to make it work with `bib2gls` and `splitidx` and their generated auxiliary files.
`latexmk` is maintained by John Collins, who contributed the `splitidx` routine.
The entire thing should be OS agnostic.

A single call

```bash
latexmk main
```

on our core TeX file [`main`](main.tex) will process the entire chain, containing

- `lualatex`,
- `bib2gls`,
- `splitindex`,
- `biber`.

On Windows, such a call can be made by right-clicking into the Explorer Window (but not on a file or directory) while holding down *Shift* , then *Open PowerShell Window here*.
Linux users will know what they are doing, I won't be able to help.

The produced PDF will be processed fully, with all contained cross-references, citations etc. in place.
Once you get used to what all the individual steps do, you won't need `latexmk` each time.
For quick building and debugging, when you don't care for anything else, running `lualatex` once will likely suffice.

### CI

The entire thing can also be used in Continuous Integration.
A script for GitLab, alongside a Docker image, is found in [the config file](.gitlab-ci.yml).
I do not yet have an equivalent GitHub/Travis config.

During the build process, you can use [the metadata text file](gitmeta.txt) to `sed` the relevant entries.
These are grabbed by TeX to print the metadata directly into the generated PDF.
