# Project Architecture

Inspired by [this post](https://web.archive.org/web/20210208124935/https://news.ycombinator.com/item?id=26048784).
This file details the project's architecture, including:

1. the moving parts,
2. certain special directories,
3. certain special files.

It is pretty overkill and almost presumptuous to have such a file in such a small/simple project.
But it's still a good place to explain a bunch of stuff that can't be explained anywhere else,
even if the "architecture" itself is simple.
The below explanations start from the very basics, assuming very little preexisting knowledge.

## Moving parts

The moving parts are mainly the document generation of the main PDF.
Refer to the contents of that PDF itself to get an idea of how that is achieved.

## Special directories

- [bib](bib/): Contains bibliographical data:
  - Of course, the [bibliography itself](bib/bibliography.bib).
    This is auto-generated using [Zotero](https://www.zotero.org/).
    Please use a citation management software (any will do), or you will end up hating yourself.
  - All sorts of [glossaries](bib/glossaries/), which, thanks to [`bib2gls`](https://ctan.org/pkg/bib2gls), now also come in `bib` format.
- [chapters](chapters/): Your content source `tex` files.
  Splitting up files, putting them there and then running `\include` or `\input` on them is a good way of modularisation.
- [data](data/): For example, raw tabular data from experiments.
- [lib](lib/): Library modules, e.g. outsourced latex source code that is better off modularized.

  This directory also contains Lua code.
  Embedding Lua for `lualatex` to consume is very cool and we are gladly making use of it.
  However, embedding it verbatim into `\directlua` is a bit ugly [and has annoying issues with escaping](https://web.archive.org/web/20210208133949if_/https://www.overleaf.com/learn/latex/Articles/An_Introduction_to_LuaTeX_(Part_2):_Understanding_%5Cdirectlua).
  Therefore, we prefer to load external, proper Lua files using `\dofile`.
  These files live in [this directory](lib/lua/).
- [pandoc](pandoc/): `pandoc` is a tool almost completely separate from latex.
  It is not relevant to the main project and used here only as a cool showcase to convert the Markdown [README](README.md) to PDF (which uses latex in the background).
  This directory contains configuration files for `pandoc`.
- [tests](tests/): A Python module to run tests on the produced PDFs.
  This can help detect problems as early as possible (that's what CI is all about after all) in a reproducible and reliable way.
  Refer to the [README](tests/README.md) there for more info.

## Special files

- git:
  - [.gitignore](.gitignore): Tells git what files *not* to track in its version control.
  - [.gitattributes](.gitattributes): Tells platforms like GitLab to treat certain files in certain, customizable ways.
  - [.gitlab-ci.yml](.gitlab-ci.yml): Configures the GitLab Continuous Integration system, and as such has little to do with core git, the version control system.
    It relies heavily on the Makefile, see below.
- [Makefile](Makefile): Instructions for the [GNU `make` program](https://www.gnu.org/software/make/).
  This program is quite old, very stable, ubiquitous and widely used.
  It is a staple in the Linux world.
  There are ways to get it to run on Windows, but I haven't tried any.
  Use [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10) instead and save yourself the headaches.

  `make` runs steps according to the `Makefile` in order to arrive at a target, like a PDF compiled with latex.
  It checks all the dependencies automatically and only updates the target if changes in the sources are detected.

  The idea is that this project's PDFs can be compiled by simply calling e.g. `make file.pdf` *both locally and in CI*.
  Without make, we would otherwise have very different build steps in local and CI environments.
  Additionally, using `make`, the [CI instructions](.gitlab-ci.yml) can be simplified considerably, leading to decoupling.
  Moving CI systems then becomes much easier.
- [.latexmkrc](.latexmkrc): Instructions for the `latexmk` program.
  This program is somewhat like `make`, but tailored for latex.
  Latex has a distinct characteristic of regularly requiring *multiple runs* of the same program (e.g. `lualatex`) before the build is finished.
  In the intermediary runs, latex generates auxiliary files responsible for resolving references, links, tables of content etc.

  `latexmk` knows about these dependencies (otherwise we tell it in its `.latexmkrc` config file), detects these and runs latex (and other, outside programs) accordingly.

  Now, why do we need *both* `latexmk` and `make`?
  Both automate builds.

  `latexmk` is not powerful enough to cover all use cases.
  `make` is more general and more suitable to be integrated in CI.
  For our latex needs, `make` basically only delegates to `latexmk`.
  We **do not** call e.g. `lualatex` multiple times manually from `make`: this logic is left to `latexmk` and `.latexmkrc`.
  However, `make` can also do much more, e.g. cover `pandoc`, clean-up operations etc.
  Therefore, `make` and `latexmkrc` *together* are just super powerful and useful.
