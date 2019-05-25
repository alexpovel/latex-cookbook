# Yet Another Thesis Template

Jesus Christ, who needs that many templates?
Aren't there enough by now?

This template is different than almost all others.
It has one primary, fragile advantage: it is currently (2019) right on the edge of state-of-the-art LaTeX typesetting.

TeX is moving slowly, and as such, best practices, packages and methods from over 10 years ago are still actively used today.
Sometimes, packages will be from the previous century.
They all work well, but not great.
This template is an attempt to only employ the latest and greatest of what the LaTeX world has to offer (and some of that is still old).
Outdated, no longer maintained packages are avoided if possible.

## Features

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

  Its built-in packages are especially noteworthy:
  - `tocbasic` for a gateway into managing content lists (Table of Contents etc.)
  - `scrlayer-scrpage` blows `fancyhdr` out of the water, offering page styles.
  These are used to set headers and footers.
- compile using `lualatex` for full Unicode support.
No fiddling with `inputenc` or `fontenc` packages anymore. Forget about those, it is high time to move on.

  `lualatex` is the designated successor to `pdflatex`. It supports the `contour` package and allocates memory as needed (so `tikz-externalize` and its many caveats are avoided).

  AFAIK, `xelatex` is not as versatile, yet is much more prevalent (double the number of hits on Google).
  All issues I ever had with `xelatex` (see above) were banished switching to `lualatex`.

- use `glossaries-extra`, the latest, most capable glossary/nomenclature/indexing package. With `bib2gls` (a Java tool) to draw  entries from respective `*.bib`-files. This is also used for symbols, allowing for a highly cross-referenced document with absolutely consistent symbol typesetting and global management of them.

  You can have your abbreviations/symbols/sub-superscripts in `*.bib` files now, with the familiar syntax for the entries.
  Their order does not matter, they will be sorted by the `bib2gls` tool.
  The sorting can be customized to a dizzying degree --- or left out entirely, if you don't want it sorted.

  The resulting glossary/nomenclature can also be printed in a fully customized way.

  `nomencl` with [its hacky functionalities](https://tex.stackexchange.com/questions/112884/how-to-achieve-nomenclature-entries-like-symbol-description-dimension-and-uni) is no longer needed.
- a custom title-page.

  It is nothing fancy, but I had a very good run with it over the years.
  It is right there in plain sight for you, easy to modify.
- `biblatex` with `biber`, the currently most powerful bibliography tool.

  Its manual is over 300 pages long and will exhaust your every desire.
- custom environments for code, chemical reactions and illustrations.
- multiple sub-indices using `splitindex` (however, this should better be done using `glossaries-extra` in the future).

- have a lot of control over figure and caption configurations combining `floatrow` and `caption`.
`floatrow` is actually a bit old and awkward to use.
We could probably use something more modern here.

## Build

All this is quickly built using `latexmk` with a custom [`latexmkrc`](latexmkrc) file.
It contains some Perl commands to make it work with `bib2gls` and `splitidx` and their generated auxiliary files.
`latexmk` is maintained by John Collins, who contributed the `splitidx` routine.

A single call
```
latexmk main
```
on our core TeX file [`main`](main.tex) will process the entire chain, containing
- `lualatex`,
- `bib2gls`,
- `splitindex`,
- `biber`.

The produced PDF will be processed fully, with all contained cross-references, citations etc. in place.

### CI

The entire thing can also be used in Continuous Integration.
A script for GitLab, alongside a Docker image, is found in [the config file](.gitlab-ci.yml).
I do not yet have an equivalent GitHub/Travis config.

During the build process, you can use [the metadata text file](gitmeta.txt) to `sed` the relevant entries.
These are grabbed by TeX to print the metadata directly into the generated PDF.