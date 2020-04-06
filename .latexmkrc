# PERL latexmk config file

# PDF-generating modes are:
# 1: pdflatex, as specified by $pdflatex variable (still largely in use)
# 2: postscript conversion, as specified by the $ps2pdf variable (useless)
# 3: dvi conversion, as specified by the $dvipdf variable (useless)
# 4: lualatex, as specified by the $lualatex variable (best)
# 5: xelatex, as specified by the $xelatex variable (second best)
$pdf_mode = 4;

# --shell-escape option (execution of code outside of latex) is required for the 'svg' package.
# It converts raw SVG files to the PDF+PDF_TEX combo using InkScape.
$lualatex = "lualatex --shell-escape";
