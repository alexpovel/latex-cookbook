# Library code

This directory might contain, for example:

- Lua files for usage alongside `lualatex`.
    Embedding Lua for `lualatex` to consume is quite powerful and neat, and we are gladly making use of it.
    However, embedding Lua verbatim into `\directlua` is a bit ugly [and has annoying issues with escaping](https://web.archive.org/web/20210208133949if_/https://www.overleaf.com/learn/latex/Articles/An_Introduction_to_LuaTeX_(Part_2):_Understanding_%5Cdirectlua).
    Therefore, prefer to load external, proper Lua files using `\dofile`.
    These files might live in here, if required.
- Outsourced LaTeX source code that is better off modularized, like custom packages.
