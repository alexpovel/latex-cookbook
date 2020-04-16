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

# Grabbed from latexmk CTAN distribution:
# Implementing glossary with bib2gls and glossaries-extra, with the
# log file (.glg) analyzed to get dependence on a .bib file.
# !!! ONLY WORKS WITH VERSION 4.54 or higher of latexmk

# Push new file endings into list holding those files
# that are kept and later used again (like idx, bbl, ...):
push @generated_exts, 'glstex', 'glg';

# Add custom dependency.
# latexmk checks whether a file with ending as given in the 2nd
# argument exists ('toextension'). If yes, check if file with
# ending as in first argument ('fromextension') exists. If yes,
# run subroutine as given in fourth argument.
# Third argument is whether file MUST exist. If 0, no action taken.
add_cus_dep('aux', 'glstex', 0, 'run_bib2gls');

# PERL subroutine. $_[0] is the argument (filename in this case).
# File from author from here: https://tex.stackexchange.com/a/401979/120853
sub run_bib2gls {
    if ( $silent ) {
    #    my $ret = system "bib2gls --silent --group '$_[0]'"; # Original version, probably for Linux
        my $ret = system "bib2gls --silent --group $_[0]"; # Runs in PowerShell
    } else {
    #    my $ret = system "bib2gls --group '$_[0]'"; # Original version, probably for Linux
        my $ret = system "bib2gls --group $_[0]"; # Runs in PowerShell
    };

    my ($base, $path) = fileparse( $_[0] );
    if ($path && -e "$base.glstex") {
        rename "$base.glstex", "$path$base.glstex";
    }

    # Analyze log file.
    local *LOG;
    $LOG = "$_[0].glg";
    if (!$ret && -e $LOG) {
        open LOG, "<$LOG";
    while (<LOG>) {
            if (/^Reading (.*\.bib)\s$/) {
        rdb_ensure_file( $rule, $1 );
        }
    }
    close LOG;
    }
    return $ret;
}
