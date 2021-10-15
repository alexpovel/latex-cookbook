# Content files

This directory contains all the source `tex` files with the document content.
Splitting up files, putting them here and then running `\import` or `\subimport` on them is a good way of modularisation.
It allows to compile only what is needed by commenting out unneeded `\(sub)import` statements, greatly speeding up compilation times.
