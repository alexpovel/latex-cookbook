# Vector Graphics Directory

This directory holds vector graphics SVG files, to be used with `\includesvg{}`.
If there's a file `abc` in here, include it in the document with `\includesvg{abc}`:

- no leading path (`includesvg` knows to look in here),
- no file suffix (`includesvg` can only handle `.svg` anyway).
