# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2020-11-11

### Added

- Python-based tests for the produced PDFs (1746e4e).
  This allows the user to automatically run a test suite against the produced PDFs,
  for example checking for page count, metadata and much more.
- Makefiles for the [root](Makefile) and [tests](tests/Makefile) directories, while
  also swapping all CI routines over to use `make` (b4a9881).
  This allows for local as well as CI use using the same commands, and reduces coupling
  with the CI engine.
- Caching of files in CI, for much faster pipelines (while introducing some issues) (28aea76).
- Showcase and fixing of `\abs` macro for absolute values (4d0c6ff, bb11b72).

### Changed

- Git metadata display in the colophon (7c59cbe).

## [1.2.0] - 2020-10-29

### Added

- Showcase for multiple lines with contours in TikZ overlay (ae4ad39)
- Hint for the `glossaries-extra` *Beginner's Guide* (d8b7fb4)
- Written permission (license) to use and distribute the [Fontin Sans](https://www.fontsquirrel.com/fonts/fontin-sans)
  font (cf79ee4)
- Summary for font licenses (0372475)
- Contributing guideline (56c4eac)
- README info on git and Docker (fa228b7)
- A `matlab2tikz` exported plot example (86dac19, c3e9b09)
- `YAML`-based configs for pandoc (cb39706)
- Proper check for the used TeX engine (de2a293)

### Changed

- Fontawesome implementation, away from the `fontawesome` package to the more
  modern `fontawesome5` (8df784e)
- Insertion of git metadata into the document (PDF metadata or into the printed text
  directly): now based on Lua (6d0cd7e)
- Also adjusted the README according to the new Lua implementation (ed946b8)

## [1.1.1] - 2020-06-09

### Added

- Entry `Mach` in `names.bib` (d0d5683). Was previously removed, but is required.

## [1.1.0] - 2020-06-09

### Added

- Added `bib` file entries for the built-in math macros (f1803d3b):
  - `\mean`
  - `\logmean`
  - `\flow`
  - `\difference`
  - `\nablaoperator`
  - `\vect`
  - `\deriv`
  - `\fracderiv`
  - `\timederiv`
  - `\posderiv`
- New tabular showcasing those built-in math macros (119fce11)
- New tabular showcasing the built-in glossary commands (0e7ed5a9):
  - `\idx`
  - `\name`
  - `\sym`
  - `\sub`
  - `\abb`
  - `\cons`
- Added sample entries for the *Terms* index (6ca2670b)

### Removed

- Unused entry `Mach` in `names.bib` (c000d4ec)

## [1.0.0] - 2020-04-22

### Added

- Initial release
