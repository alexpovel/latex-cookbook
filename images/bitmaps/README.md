# Bitmaps Graphics Directory

This directory holds bitmaps (JPG, PNG, ...), to be used with `\includegraphics{}`.
If there's a file `abc` in here, include it in the document with `\includegraphics{abc}`:

- no leading path (`includegraphics` knows to look in here),
- no file suffix (`includegraphics` looks for the common ones automatically).

**PDFs files (even if they're vectors) also go in here** and are usable via `\includegraphics` in the same way.
