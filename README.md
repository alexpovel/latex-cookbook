# Thesis Template
Full thesis template, including a presentation template.

Features:
- Based on [TeX Gyre](http://www.gust.org.pl/projects/e-foundry/tex-gyre/index_html) fonts for high-quality typesetting.
- Compile using `lualatex` for full UTF8-support. `lualatex` is the designated successor to `pdflatex`. It supports the `contour` package and allocates memory as needed (so `tikz-externalize` and its many caveats are avoided); `xelatex` is not as versatile.
- Using `glossaries-extra`, the latest, most capable glossary/nomenclature/indexing package. With `bib2gls` (requires Java) to draw  entries from respective `.bib`-files. This is also used for symbols, allowing for a highly cross-referenced document with absolutely consistent symbol typesetting and global management of them.
- A custom title-page.
- `biblatex` with `biber`, the currently most powerful bibliography tool.
- Custom environments for code, chemical reactions and illustrations.
- Multiple sub-indices using `splitindex` (this should better be done using `glossaries-extra` in the future)
