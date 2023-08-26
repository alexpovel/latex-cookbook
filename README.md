# LaTeX Cookbook

[![Download PDF](https://img.shields.io/badge/Download-PDF-blue.svg)][download]

This repo contains a [LaTeX document](cookbook.tex), usable as a cookbook (different "recipes" to achieve various things in LaTeX) as well as as a template.
The resulting PDF covers LaTeX-specific topics and instructions on compiling the LaTeX source.

See the [releases page](https://github.com/alexpovel/latex-cookbook/releases) for more downloads.

> [!IMPORTANT]
> This project is not archived, and [issues are still
> addressed](https://github.com/alexpovel/latex-cookbook/issues/17). However, the
> document is regarded as "done" and no new feature development actively happens. As LaTeX is a glacially slow-moving target, the document
> should be useful, valid and buildable for many years to come still.
>
> There is a [fork
> maintained](https://collaborating.tuhh.de/m21/public/theses/itt-latex-template) by
> former coworkers of the author, at the research institute this template originated
> from as well. Active development is still happening there.

## Getting started

After installing [Docker](https://www.docker.com/) (and git), building works out of the
box:

- Bash:

  ```console
  $ git clone git@github.com:alexpovel/latex-cookbook.git
  $ cd latex-cookbook
  $ docker run --rm --volume $(pwd):/tex alexpovel/latex
  $ xdg-open cookbook.pdf
  ```

- PowerShell:

  ```powershell
  PS> git clone git@github.com:alexpovel/latex-cookbook.git
  PS> cd latex-cookbook
  PS> docker run --rm --volume ${PWD}:/tex alexpovel/latex
  PS> Invoke-Item cookbook.pdf
  ```

The [entrypoint](https://docs.docker.com/engine/reference/builder/#entrypoint) is
[`latexmk`](https://ctan.org/pkg/latexmk?lang=en), which when given no arguments (as
done here) runs on all found `*.tex` files, which in this case is only the root's [main
file](./cookbook.tex).

> [!NOTE]
> Should this fail to compile (this is a bug, please report!), feel free to try other
> images. When `alexpovel/latex` was built,
> [`texlive/texlive`](https://hub.docker.com/r/texlive/texlive) did not exist yet.
> **That image is strongly recommended**, as it is actively maintained by the actual
> authors of TeXLive. If tools are missing, like `inkscape`, build your own image `FROM
> texlive/texlive`, then install required software.
>
> Alternatively, there is [a
> fork](https://collaborating.tuhh.de/m21/public/theses/latex_dockerfile) for the image
> as well, accompanying the [template
> fork](https://collaborating.tuhh.de/m21/public/theses/itt-latex-template).

## Features

The [PDF itself][download] has much more to say on this and is meant to speak for itself, visually.
The following is simply a brief overview of the features contained in this repo.

### Tooling

- accompanying [Docker image](.devcontainer/image/Dockerfile), usable locally and in CI/CD, guaranteeing compilation success without interfering with your local installation.
  In fact, using Docker (containerization in general), no LaTeX installation is required at all.
  - accompanying Visual Studio Code [environment configuration](.devcontainer/devcontainer.json).

    If you open this repository in [Visual Studio Code](https://code.visualstudio.com/), it should automatically put you into the correct Docker container environment for development, and just work™.
    See [here](.devcontainer/README.md) for more info.
  - in the image, [`pandoc`](https://pandoc.org/) is available with the [Eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template) template, allowing beautiful PDFs to be generated from Markdown (like this README: download it from the latest [Actions artifacts](https://github.com/alexpovel/latex-cookbook/actions); it currently looks lackluster because this README is mainly PNGs)
- [tests](tests/config.yml) for your PDF, using Python to ensure some (basic) properties of your output adhere to expectations
- a [Makefile](Makefile) to facilitate ease of use and platform independence (commands like `make file.pdf` work locally as well as in CI pipelines)

### LaTeX-specific

- full Unicode support through `lualatex`, the [successor](https://en.wikipedia.org/wiki/LuaTeX) to the obsolete `pdflatex`.
  This also affords beautiful font typesetting through [`unicode-math`](https://ctan.org/pkg/unicode-math).
  High-quality fonts like [TeX Gyre Pagella](https://ctan.org/pkg/tex-gyre-pagella) have all desirable font shapes available:
  ![font-shapes](images/bitmaps/readme/font-shapes.png)
- automatic compilation using [`latexmk`](.latexmkrc), ensuring the PDF is built fully, running all steps necessary (generation of the bibliography, glossaries, ...) automatically as needed
- comprehensive support for:
  - generating [indices](bib/glossaries/index/),
  - typesetting and displaying [symbols](bib/glossaries/symbols/) in an automatically generated nomenclature,
  - [acronyms and abbreviations](bib/glossaries/abbreviations.bib), as well as
  - [mathematical constants](bib/glossaries/constants.bib),

  made possible through [`glossaries-extra`](https://ctan.org/pkg/glossaries-extra).
- structured and commented source code, explaining rationales and providing context
- showcasing plotting and data display (floats):
  - computing more complicated plots (in this example, a contour plot) *directly in LaTeX*, with no explicit outside tools used ([`gnuplot`](http://www.gnuplot.info/) is used by LaTeX in the background):

    ![plot-compute](images/bitmaps/readme/plot-compute.png)
  - ingesting a CSV directly, and plotting it (so we can skip [`matlab2tikz`](https://www.mathworks.com/matlabcentral/fileexchange/22022-matlab2tikz-matlab2tikz) etc.).
    The below style is inspired by [Tufte](https://www.edwardtufte.com/tufte/):

    ![plot-csv](images/bitmaps/readme/plot-csv.png)
  - typesetting more complex tables, with footnotes, decimal alignment and more:

    ![table](images/bitmaps/readme/tables.png)
  - using tikz:
    - for annotating bitmap graphics:

      ![tikz-annotation](images/bitmaps/readme/tikz-annotations.png)
    - for drawing diagrams (this template contains a (basic) `pgf`/`tikz` library for energy systems/thermodynamics/hydraulics/... symbols like pipes, compressors, valves, ...) and 3D sketches.
      For a much better and comprehensive collection of TikZ examples, see [here](https://texample.net/tikz/examples/).

      ![tikz-diagram](images/bitmaps/readme/tikz-diagram.png)
      ![tikz-libaries](images/bitmaps/readme/tikz-libraries.png)
- back-referencing of citations, using the excellent [`biblatex`](https://ctan.org/pkg/biblatex):

  ![backref](images/bitmaps/readme/backref.png)
- support for elaborate chemical reaction equations, using [`chemmacros`](https://ctan.org/pkg/chemmacros):

  ![chemmacros](images/bitmaps/readme/chem.png)
- comprehensive code syntax highlighting, thanks to [`minted`](https://ctan.org/pkg/minted) and `pygments`:

  ![pygments](images/bitmaps/readme/code.png)
- quick and structural switching of language contexts, provided by [`polyglossia`](https://ctan.org/pkg/polyglossia):

  ![language](images/bitmaps/readme/language.png)
- of course, support for enhanced mathematical typesetting, like highlighted equations or premade macros.
  The blue color are *hyperlinks*, turning those symbols into links to the glossary (this can be toggled off).

  ![math](images/bitmaps/readme/math.png)

  ![math-macros](images/bitmaps/readme/math-macros.png)

[download]: https://github.com/alexpovel/latex-cookbook/releases/latest/download/cookbook.pdf
