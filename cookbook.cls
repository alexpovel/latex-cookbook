%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LuaLaTeX based on KOMA-Script
%
% Author (2020): Alex Povel - tex(at)alexpovel.de
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Class Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Refer to https://www.overleaf.com/learn/latex/Writing_your_own_class
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cookbook}[2020-10-29 v1.2.0 cookbook class]

% Fail early and give useful information on the required engine.
% This helps users who do not read the documentation beforehand, by promoting the
% requirement from some statement in the docs to actual code that errors out.
\RequirePackage{iftex}
\RequireLuaTeX{}

\newcommand*{\@baseclass}{scrbook}% Name of class this one is based on

% If option 'language' is not given at all, use initialization 'english' as a fallback.
% If it is called without a value, use default (or throw error of no default given)
% This method was chosen to have the language available in a macro, so it may be passed
% to polyglossia.
% This approach messes with the forwarding of the language and raises a warning
% 'Unused global options'; we can probably ignore that for now 
% (https://tex.stackexchange.com/a/278172/120853).
\RequirePackage{kvoptions}
    %[default]{language} % If no default entered: option requires a value:
    \DeclareStringOption[english]{language}
    \DeclareStringOption{titlestyle}
    \DeclareBoolOption{censoring}% Initially false by default
    \ProcessKeyvalOptions*

\PassOptionsToClass{%
    \cookbook@language,% Scheme: \filename@keyoption
    twoside,% For printing two-sided documents
    % 'List of (Tables, Figures, ...)' gets pushed down one hierarchical level:
    % listof=leveldown,
    listof=totoc,% All registered Lists of XYZ to Table of Contents
    bibliography=totoc,
    chapterprefix=true,% Print 'Chapter' etc. label in front of number
    open=right,% Open new Chapters on recto pages
    numbers=noenddot,% https://tex.stackexchange.com/a/102305/120853
}{\@baseclass}

% Bundle 'a5' to not only have a5paper but also decrease font size.
% https://tex.stackexchange.com/a/418947/120853
% https://tex.stackexchange.com/a/27149/120853
\DeclareOption{a5}{%
    % Not forwarded to typearea package if passed as class option: do it manually here:
    \PassOptionsToPackage{paper=a5}{typearea}
    \PassOptionsToClass{fontsize=10pt}{\@baseclass}%
}%

% Forward all other options given to \documentclass[] to base class:
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{\@baseclass}}

\ProcessOptions\relax% Execute these options

\LoadClass{\@baseclass}% Finally, load the base class

\RequirePackage[\cookbook@language]{tracklang}% Language Tracking

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Typography and Misc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Translations for somewhat automatic internationalization
\input{lib/translations.tex}

\RequirePackage{scrhack}% Fixes for packages incompatible with KOMA features

\RequirePackage{import}% Relative path imports

\RequirePackage[super]{nth}% For ordinal numbers, like \nth{1} -> 1^{st}

\RequirePackage{etoolbox}% Programming facilities

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tweaks and improvements for amsmath; also loads amsmath.
% Needs to be loaded before unicode-math!
\RequirePackage{mathtools}
    % We want to be cool, so standard parantheses don't cut it:
    \newtagform{brackets}{[}{]}
    \usetagform{brackets}

    % Allow multi-line environments to break across pages.
    % While it makes sense to disallow it, not doing so can produce big spacing issues.
    % Usually, any such environment will require manual attention.
    % Number from 1 to 4 as optional argument:
    % [1]: allow pagebreaks, but avoid as much as possible.
    % [4]: maximum permissiveness
    \allowdisplaybreaks[2]

    % Automatic macro for delimiters (parentheses, brackets, ...)
    % Using the starred variant of the created command (like \parens*{<content>})
    % also scales the delimiters automatically, using \left and \right.
    \DeclarePairedDelimiter{\parens}{(}{)}
    \DeclarePairedDelimiter{\brackets}{[}{]}
    \DeclarePairedDelimiter{\braces}{\{}{\}}
    \DeclarePairedDelimiter{\abs}{\lvert}{\rvert}% Absolute value

% For a 'cases' environment that also supports equation numbering,
% https://tex.stackexchange.com/a/180910/120853
\RequirePackage{empheq}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Colour
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load this before unicode-math font specifications to make colors available there
\RequirePackage[x11names]{xcolor}% x11names provides some usable default names
    % Shades of grey (we don't need 50 though)
    % This is nice to have consistent color shading.
    \colorlet{g1}{black!70}
    \colorlet{g2}{black!55}
    \colorlet{g3}{black!40}
    \colorlet{g4}{black!20}
    \colorlet{g5}{black!10}
    \colorlet{g6}{black!05}

    % Different fluids/materials.
    \definecolor{Glass}{RGB}{170, 238, 255}% Very light blue
    \definecolor{Air}{RGB}{213, 246, 255}% Light blue
    \definecolor{LightFluid}{RGB}{148, 224, 255}
    \definecolor{MediumFluid}{RGB}{135, 178, 232}
    \definecolor{DarkFluid}{RGB}{119, 151, 197}
    \definecolor{HotFluid}{RGB}{255, 128, 128}% 255/128/128 is same as 'red!50'

    % Dark blue link color:
    \definecolor{darklink}{RGB}{48, 62, 116}%

    % From colorbrewer's RdYlBu: from red (1) to blue (6)
    \definecolor{rdylbu1}{RGB}{215,  48,  39}%
    \definecolor{rdylbu2}{RGB}{252, 141,  89}%
    \definecolor{rdylbu3}{RGB}{254, 224, 144}%
    \definecolor{rdylbu4}{RGB}{224, 243, 248}%
    \definecolor{rdylbu5}{RGB}{145, 191, 219}%
    \definecolor{rdylbu6}{RGB}{ 69, 117, 180}%

    % From colorbrewer's Set2 for qualitative data/color discernibility
    \definecolor{Set2A}{RGB}{102, 194, 165}%
    \definecolor{Set2B}{RGB}{252, 141,  98}%
    \definecolor{Set2C}{RGB}{141, 160, 203}%
    \definecolor{Set2D}{RGB}{231, 138, 195}%
    \definecolor{Set2E}{RGB}{166, 216,  84}%
    \definecolor{Set2F}{RGB}{255, 217,  47}%
    \definecolor{Set2G}{RGB}{229, 196, 148}%
    \definecolor{Set2H}{RGB}{179, 179, 179}%

    % Matlab colours:
    \definecolor{mBlue}{HTML}{0072BD}
    \definecolor{mOrange}{HTML}{D95319}
    \definecolor{mYellow}{HTML}{EDB120}
    \definecolor{mPurple}{HTML}{7E2F8E}
    \definecolor{mGreen}{HTML}{77AC30}
    \definecolor{mSky}{HTML}{4DBEEE}
    \definecolor{mRed}{HTML}{A2142F}

    % Code annotations:
    \definecolor{cRed}{RGB}{209,0,86}%
    \definecolor{cBlue}{RGB}{0, 130, 185}%
    \definecolor{cGreen}{RGB}{0, 128, 63}%
    \definecolor{cOrange}{RGB}{244, 131, 66}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Typeset code snippets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Custom package with style/language definitions:
\input{lib/listings-languages.tex}

% Colors for escaped, normal LaTeX in code environments
\newcommand*{\phstring}[1]{%
    \textcolor{cRed}{#1}%
}%
\newcommand*{\phnum}[1]{%
    \textcolor{cBlue}{#1}%
}%
\newcommand*{\phother}[1]{%
    \textcolor{cGreen}{#1}%
}%
\newcommand*{\phnote}[1]{%
    {%
        \hypersetup{allcolors=cOrange}% If references occur in here
        \textbf{\textcolor{cOrange}{#1}}%
    }%
}%

\lstset{% Global settings
    style=base,
    language={[3]Python},% global default; put most likely encountered language
}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO notes in the PDF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{todonotes}% TODO-notes in the margins
    \setuptodonotes{fancyline}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fonts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[
    warnings-off={
        % Unicode overwrites colon-commands but uses over/underbracket from mathtools
        % and warns us; suppress this:
        mathtools-colon,%
        mathtools-overbracket,%
    }
]{unicode-math}% Builds onto fontspec and loads it automatically

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% By explicitly including the actual font files in the project and also
% calling them explicitly, we ensure tight compatibility across machines and
% time (as opposed to relying on them being installed as system fonts for every user).
% The configuration has been confirmed to work with MiKTeX and TeXLive on
% Windows as well as TeXLive on Linux (Debian).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Source: https://ctan.org/texarchive/fonts/tex-gyre/opentype
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\defaultfontfeatures{% Options common for all fonts
    Extension=.otf,
}

\setmainfont[%
    Path=fonts/roman/,
    Numbers=Lowercase,% Hanging/OldStyle numbers through Lowercase numbers
    % Use asterisk-notation as a placeholder for what it says in brackets {} later:
    UprightFont=*-regular,%
    BoldFont=*-bold,%
    ItalicFont=*-italic,%
    BoldItalicFont=*-bolditalic,%
    % Color=Orange2,% Toggle color for debugging (should be xcolor name)
]{texgyrepagella}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Source: https://fonts.google.com/specimen/Inconsolata
% (Consolas is considered better but is not free (?))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\setmonofont[%
    Path=fonts/mono/,
    % Inconsolata doesn't have italics font, so fake it. Discouraged but should
    % only occur in a few places in code and not be noticable there. Inconsolata
    % is too nice to give up on it for lack of italics. See also
    % https://tex.stackexchange.com/a/183220/120853
    AutoFakeSlant,
    Scale=MatchLowercase,% Prettier when using inline-code alongside our main font
    UprightFont=*-medium,%
    BoldFont=*-bold,%
    % Color=DodgerBlue3,% Toggle color for debugging (should be xcolor name)
]{inconsolata}%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Source: https://www.exljbris.com/fontinsans.html
% Viable alternative: https://fonts.google.com/specimen/Fira+Sans
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\setsansfont[%
    Path=fonts/sans/,
    UprightFont=*_R_45b,%
    BoldFont=*_B_45b,%
    ItalicFont=*_I_45b,%
    BoldItalicFont=*_BI_45b,%
    SmallCapsFont=*_SC_45b,%
    % Color=Red3,% Toggle color for debugging (should be xcolor name)
]{Fontin_Sans}%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Source: https://ctan.org/texarchive/fonts/tex-gyre-math/opentype
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\setmathfont[%
    Path=fonts/roman/math/,
    %Set math-font-commands to new versions; use \symbf{} instead of \mathbf{} etc:
    mathrm=sym,%
    mathit=sym,%
    mathsf=sym,%
    mathbf=sym,%
    mathtt=sym,%
    % 'tpgl': 'TexGyrePagellaLining'.
    % This 'NFSS' style is required for \fontfamily{nfss-code}\selectfont to work,
    % e.g. in package chemformula
    NFSSFamily=tgpl,%
    % Color=Green4,% Toggle color for debugging (should be xcolor name)
]{texgyrepagella-math}%

% Provide a new font family for siunitx to work.
% See: https://tex.stackexchange.com/a/468031/120853.
% \newfontfamily is used similarly to \setmainfont etc,
% see: https://tex.stackexchange.com/a/12568/120853
\newfontfamily{\unitnumberfont}[
    Path=fonts/roman/,
    % New font family for typesetting units.
    % Required since otherwise, numbers typeset with \SI/\num etc. from siunitx
    % might be hanging if that feature is turned on in the main font (OldStyle numbers).
    % To ensure these physical numbers are always upright, set Numbers:
    Numbers=Uppercase,
    UprightFont=*-regular,%
    BoldFont=*-bold,%
    ItalicFont=*-italic,%
    BoldItalicFont=*-bolditalic,%
    % Color=LightCyan4,% Toggle color for debugging (should be xcolor name)
]{texgyrepagella}%

% Looking at CTAN, `fontawesome5' looks much more recent and packs many more symbols
% in comparison to `fontawesome'.
% It ships with its own font files, so no need to specify here.
\RequirePackage{fontawesome5}% High-quality Unicode vector web symbols

% Wrapper for "i.e.", "e.g.", "c.f.", "etc.", etc.
% Call this command as "The animals, \iecfeg{e.g.}\ an elephant, are..."
% to get a small space after the ending period.
% We do not define dedicated commands here (like \eg or \etc) to print that stuff
% automatically, since there are way too many exceptions and caveats.
% Such macros are not worth it because the requirements change too much from use to use
%  (different languages, capitalisation, ending dot if abbreviation is at end of
% sentence, ...).
% It is left to the user to do the specifics.
% This macro just makes sure it is all in italics.
\newcommand*{\iecfeg}[1]{\textit{#1}}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% System Information Banner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Provides \hologo and \Hologo to typeset various logos, like the LuaLaTeX logo.
\RequirePackage{hologo}

% Using fontspec, this document is incompatible with anything but XeLaTeX/LuaLaTeX.
% LuaLaTeX can grab additional memory as needed, therefore no issues with tikz and no
% need to tikzexternalize (!).
% Further, contour-package and XeLaTeX are strictly incompatible (LuaLaTeX works).
% Therefore, only ever use LuaLaTeX anyway.

\RequirePackage{xstring}% String manipulation macros

% Print only what occurs after 'This is ' and store in macro given in brackets at end.
% luatexbanner is provided by luatex engine, but prints 'This is luatex XYX' usually.
% https://tex.stackexchange.com/a/394043/120853
\StrBehind*{\luatexbanner}{This is }[\shortbanner]

% Take input and substitute strings; here: make plain LuaTeX string into pretty logo.
% StrSubstitue has no starred variant, therefore dekotenize.
% https://tex.stackexchange.com/a/350583/120853
\StrSubstitute{\shortbanner}{\detokenize{LuaTeX}}{\hologo{LuaTeX}}[\prettybanner]

% Generate some control sequences which contain metadata, which can be inserted e.g.
% into the PDF metadata (e.g. to have the exact git commit SHA of a build).
% Do not use Lua code in `\directlua`, way too annoying with all the escaping (see:
% https://www.overleaf.com/learn/latex/Articles/An_Introduction_to_LuaTeX_(Part_2):_Understanding_%5Cdirectlua
% ). Just execute an outside, proper file.
\directlua{%
    dofile("lib/lua/envvar_newcommands.lua")
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KOMA Layout, Sectioning etc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% label, e.g. 'Chapter', appearing before the chapter number:
\addtokomafont{chapterprefix}{\raggedleft}

\renewcommand*{\chapterformat}{%
    \color{g3}% g3 is a shade of grey
    %
    % chapappifchapterprefix{addtext} checks if 'chapterprefix=true' is active,
    % then prints 'Chapter' or 'Appendix' in front of number,
    % followed by more text 'addtext':
    \chapappifchapterprefix{~}% ~ is an unbreakable space character
    %
    % Autodot automates the generation of a dot/period, like \thechapter\autodot.
    % Leave out for no dot.
    \scalebox{4.5}{\thechapter}
}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Titlepage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define new font for the title page, so it is created once (\newkomafont)
% and can later be set however often required (\setkomafont)
\newkomafont{documenttype}{\usekomafont{subtitle}\footnotesize}

% Get titlepage definition from an outside file
\input{chapters/other/titlepage.tex}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tocbasic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dynamic width of number column in LoF/LoT etc (numsep + width of longest entry).
% 'tocline' is the (dynamic) default style.
\DeclareTOCStyleEntry[dynnumwidth=true]{tocline}{figure}
\DeclareTOCStyleEntry[dynnumwidth=true]{tocline}{table}

% Declare a new list of contents, with the file suffix in brackets.
% This will give access to \listof<name>s
\DeclareNewTOC[%
    type=example,% This also creates types=example+s, that is by appending an s
    % Listname is "List of <Type>s" by default, therefore translate:
    listname={\TransListOfExamples{}},
]{loe}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCRLayer for page makeup (header/footer etc.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[automark]{scrlayer-scrpage}% Automatically mark

\clearscrheadfoot% Reset defaults

% Declare new length (acting as a height) for the vertical bar in the header:
\newlength{\headerrulelength}
% Increase height of rule here; KOMA Script will complain, no idea how to fix
\setlength{\headerrulelength}{3ex}

% New command for the vertical rule, with height as specified by the new length above:
\newcommand*{\headerrule}{%
    \rule[-1ex]{0.1em}{\headerrulelength}%
}%

% Define headers:
\lehead{% Left, even head
    \llap{%
        \pagemark\enskip\headerrule%
    }%
    \enskip\headmark%
}%

\rohead{% Right, odd head
    \headmark\enskip%
    \rlap{%
        \headerrule\enskip\pagemark%
    }%
}%

% https://tex.stackexchange.com/q/299125/120853:
\renewcommand*{\chaptermarkformat}{\thechapter\enskip}%

\addtokomafont{pagehead}{\sffamily\itshape\footnotesize}%
\addtokomafont{pagenumber}{\sffamily\bfseries\footnotesize}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deliberately blank pages with message
% Occurs if new chapter starts (opens right) but previous chapter ended on
% a recto (right) page itself.
% The intermediate left page will be blank; leave a message that this is intentional.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand*{\blankpage}{% https://tex.stackexchange.com/a/205536/120853
    \par\vspace*{\fill}%
    \begin{center}
        \textcolor{g2}{%
            \TransBlankPage{}% See translations file
        }%
    \end{center}
}%

\DeclareNewLayer[% Create new layer under some name
    foreground,%
    textarea,%
    contents=\blankpage,%
]{blankpage.fg}

\DeclarePageStyleByLayers{blank}{blankpage.fg}% Make layer available as pagestyle
\KOMAoptions{cleardoublepage=blank}% Use pagestyle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Typesetting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Using 'shortcuts' package option, do e.g. 'fast\-/paced' to get a breakable
% 'fast-pace' word in print.
% Otherwise, LaTeX does not hyphenate/linebreak words that already come with a hyphen,
% since that could be ambiguous
\RequirePackage[shortcuts]{extdash}

\RequirePackage{microtype}% Advanced typesetting for kerning etc.

% Dummy text in readable English (Other languages are also detected)
% Provides a more realistic preview than Lorem Ipsum
\RequirePackage{blindtext}

\RequirePackage{pdflscape}% Pages in landscape format

\RequirePackage{url}% Escaping special chars as URL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Language Support
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{polyglossia}% Language rules. Replacement for babel in lualatex
    % Expand this properly; the version without \expandsafters does not work fully.
    % It works this way:
    % The first \expandafter is seen, so the following \setdefaultlanguage is not
    % expanded and skipped.
    % Next, the second \expandafter is looked at. It sees the token { next, saving it
    % for later.
    % \cookbook@language is then expanded fully, to the current language.
    % What is left is a properly working string, \setdefaultlanguage{<language string>}
    \expandafter\setdefaultlanguage\expandafter{\cookbook@language }

    % Whatever main language (setmainlanguage = setdefaultlanguage) was loaded, we want
    % the "other" one (since we expect only English and German) to be available as a
    % secondary language. This is very convenient if for example a thesis is in English,
    % but certain parts have to be in German, e.g. for legal reasons. A simple switch
    % \begin{german} ... \end{german} would then achieve that.
    %
    % Note that we can also do \setotherlanguages{english, german, ...}, for a
    % one-stop-shop, but that would also mean loading the main language as an "other"
    % language, which has "trouble" written all over it. Therefore, choose this weak/
    % somewhat manual approach.
    \iflanguageloaded{english}{%
        \setotherlanguage{german}%
    }{%
        % Nested ifs are ugly, but case-switch is not available and
        % flat, subsequent ifs could load the first language both as a main and
        % as an "other" language
        \iflanguageloaded{german}{%
            \setotherlanguage{english}%
        }{%
            % False: do nothing
        }
    }%

% Proper quotation support, mainly through \enquote
\RequirePackage[
    autostyle=true,% true always adapst quotes to current language
]
{csquotes}
    % Add itshape to beginning (beg) of display quote environments:
    \renewcommand*{\mkbegdispquote}[2]{\itshape}

\RequirePackage[inline]{enumitem}% Custom list environments
    \setlist{noitemsep}% No vertical spacing in lists
    \setlist[1]{labelindent=\parindent}% Indent lists by paragraph indent
    % Refer to unimath_symbols.pdf for source of \smblksquare etc.:
    % https://ctan.org/texarchive/macros/latex/contrib/unicode-math
    \setlist[itemize,1]{label=\smblksquare}%
    \setlist[enumerate]{font=\sffamily\bfseries}

    % For compact itemize lists within table cells:
    \newlist{tabitemize}{itemize}{1}% Second argument is max. depth
    \setlist[tabitemize]{%
        label=\smblksquare,%
        nosep,% nosep kills all vertical spacing
        align=parleft,
        leftmargin=*,
        % https://tex.stackexchange.com/a/443573/120853,
        % but before=\compress didn't work:
        after=\vspace{-\baselineskip},
        before=\vspace{-0.75\baselineskip},% Hacky manual parameter
    }

    % For compact enumerations lists within table cells:
    \newlist{tabenum}{enumerate}{1}% Second argument is max. depth
    \setlist[tabenum]{
        label={\arabic*.},
        font=\sffamily\bfseries,
        leftmargin=*,
        nosep,% nosep kills all vertical spacing
        align=parleft,
        % https://tex.stackexchange.com/a/443573/120853,
        % but before=\compress didn't work:
        after=\vspace{-\baselineskip},
        before=\vspace{-0.75\baselineskip},% Hacky manual parameter
    }

    % An enumerated description list:
    % https://tex.stackexchange.com/a/30035/120853
    \newcounter{descriptcount}
    \newlist{enumdescript}{description}{2}% Derive from existing description env.
    \setlist[enumdescript, 1]{% Set first level action
        before={%
            \setcounter{descriptcount}{0}%
            % \renewcommand*\thedescriptcount{\alph{descriptcount}}%
        },
        font={\bfseries\stepcounter{descriptcount}\thedescriptcount.~}
    }
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Floats
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Does \centering automatically, provides side captions (fcapside) and much more.
\RequirePackage{floatrow}

\floatsetup{footposition=bottom}% For all floats

\floatsetup[longtable]{LTcapwidth=table}% https://tex.stackexchange.com/a/345772/120853

\floatsetup[table]{%
    style=plaintop,% Always above, no matter where \caption is called
    footnoterule=none,%
    footskip=.35\skip\footins,%
}%

\floatsetup[figure]{%
    capbesideposition=right,%
    capbesidesep=quad,%
}%

\floatsetup[subfigure]{style=plain}% Plain style, so no rules

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Float Captions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{caption}

% Will be printed between 'Figure/Table/... XYZ' and the caption text:
\DeclareCaptionLabelSeparator{slash}{\ /\ }% `\ ' (backslash+space) is a short space

\DeclareCaptionFont{ftfont}{%
    \scriptsize%
    \color{g3}%
    \hypersetup{hidelinks}%
    \sffamily\raggedleft%
}%

\captionsetup{% All captions
    format=plain,%
    textformat=period,% Always print period at end
    font=small,% All fonts
    labelfont={sf,bf},%
    labelsep=slash,%
    labelformat=simple,% Just Name/Number, no period or similar
    indention=1em,%
}%

\captionsetup[floatfoot]{%
    footfont=ftfont,% https://tex.stackexchange.com/q/9547/120853
}%

\captionsetup[capbesidefigure]{
    % When using sidecaptions, the linewidth can be rather small and awkward breaks and
    % many underfull hboxes occur. Therefore, raggedright.
    justification=raggedright,
}

\captionsetup[subfigure]{%
    labelformat=simple,% 'parens' uses parantheses, 'brace' just the right one
    labelsep=slash,%
    labelfont={sf,bf},%
    list=off,% list=off removes subfigures from LoF
}%

\captionsetup[subtable]{%
    labelformat=simple,% 'parens' uses parantheses, 'brace' just the right one
    labelsep=slash,%
    labelfont={sf,bf},%
    list=off,% list=off removes subfigures from LoF
}%

\captionsetup[lstlisting]{%
    width={\dimexpr1\linewidth-0.24\linewidth},% Manual, a bit hacky
}%

% Change counter from Arabic number to letter:
\renewcommand*{\theContinuedFloat}{\alph{ContinuedFloat}}

% Make this new length and indent, same length as regular caption indent:
\newlength{\floatfootruleindent}
\setlength{\floatfootruleindent}{\caption@indent}% Set the new length

% A bit hacky; introduce a rule underneath caption if \floatfoot is called:
\renewcommand*{\floatfootskip}{2pt\hspace{\floatfootruleindent}\hrulefill}%

\RequirePackage{subcaption}% For subfloats

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bibliography
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[% Default back-end: biber
    % short style is 'alphabetic' (like [AB99]);
    % longer: 'authoryear' (like (Einstein, 1940)):
    style=authoryear,
    autocite=footnote,% Control what \autocite does
    %
    sortcites=true,% Apply what is specified in sorting=
    % Introduce back references in bibliography:
    % https://tex.stackexchange.com/a/211631/120853
    % Do not use hyperref for this
    backref,
    url=false,% Still prints URL for @online, but nowhere else
    doi=false,%
    isbn=false,%
]{biblatex}%

\addbibresource{bib/bibliography.bib}% *.bib file goes here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Special Treatment for anything in \nocite{*}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Provides a category/sub-bibliography where all entries that occur in the bib-
% file(s) but were not actually cited occur. Kind of like a "Further Reading".

% New heading
\defbibheading{notcited}{%
    \section*{%
        \TransFurtherReadingTitle{}%
    }%
}%

\defbibnote{further}{%
    \textit{\TransFurtherReadingText{}}%
}%

% https://tex.stackexchange.com/a/280545/120853
\DeclareBibliographyCategory{cited}
\AtEveryCitekey{\addtocategory{cited}{\thefield{entrykey}}}

% A header for when the bibliography is divided per-chapter:
\defbibheading{subbibliography}{%
    \section*{%
        \Cref{refsegment:\therefsection\therefsegment}%
    }%
}%

% https://tex.stackexchange.com/a/477525/120853
\defbibenvironment{bibnonum}{
        \list{%
            %
        }{%
            \setlength{\leftmargin}{\bibhang}%
            \setlength{\itemindent}{-\leftmargin}%
            \setlength{\itemsep}{\bibitemsep}%
            \setlength{\parsep}{\bibparsep}
        }%
    }%
    {\endlist}%
    {\item}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arrays / Tables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{tabu}% For longtabu in the glossary

\RequirePackage{array}
    \newcolumntype{M}[1]{>{\centering\arraybackslash}m{#1}}% Vert.+Hor. centered cells

    % A command to have a cell with vertical text as a multirow:
    \newcommand*{\multirotatecell}[2]{%
        \multirow{#1}{*}{%
            \begin{tabular}{@{}c@{}}%
                \rotatebox[origin=c]{90}{#2}%
            \end{tabular}%
        }%
    }%

\RequirePackage{multirow}% Cells spanning multiple rows (like multicolumn)

\RequirePackage{booktabs}% Pretty tables; an absolute must

% More vertical stretch for more relaxed visuals in all tables (global setting)
\renewcommand*{\arraystretch}{1.3}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Replaces datetime; use regional date format from document language
\RequirePackage[useregional]{datetime2}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visuals, Graphics, Drawing etc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{censor}
    \ifcookbook@censoring
        % censor package censors by default; do nothing if censoring requested
        % TeX doesn't have \ifnot or similar, see also
        % https://tex.stackexchange.com/q/386093/120853
    \else
        % Turn off if document option given
        \StopCensoring
    \fi

\RequirePackage{cancel}% Cancel out math in equations

\RequirePackage{setspace}% Line spacing, used for title page
    % To achieve a reasonable 'text color', i.e. 'filled-ness' of the text,
    % adjust line spacing.
    % Recommendation for Palatino fonts (TeX Gyre Pagella is a Palatino clone) is a
    % factor of 1.05.
    % Discussion: https://tex.stackexchange.com/q/31064/120853
    % For German, we might even want to go higher to allow space for the many capital
    % letters.
    % Also note that inline-math will look terrible at too low leading/linespread
    \linespread{1.05}
    \KOMAoption{singlespacing}{true}% Do not apply changed linespread to header/footer

% Print a contour around letters, e.g. black text with a white border on some noisy
% background, so that text remains legible.
% NOT COMPATIBLE WITH XELATEX! Requires pdflatex or lualatex (our case)
\RequirePackage[outline]{contour}
    \contourlength{0.12em}

    \newcommand*{\ctrw}[1]{% Black text, white contour
        \hypersetup{hidelinks}% Hide links, which might be colored
        \contour{white}{\textcolor{black}{#1}}%
    }%

    \newcommand*{\ctrb}[1]{% White text, black contour
        \hypersetup{hidelinks}% Hide links, which might be colored
        \contour{black}{\textcolor{white}{#1}}%
    }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphics + Path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{graphicx}
    % Set a global standard path, so don't specify ourselves each time;
    % only do bitmaps here, vectors are handled by the svg package and its path specs
    \graphicspath{{images/bitmaps/}}

\RequirePackage{svg}
    % See also:
    % https://tex.stackexchange.com/a/158612/120853.
    % pdftexcmds package etc. no longer seems necessary.
    % svg package documentation states that it is a dependency, but done automatically.
    % https://tex.stackexchange.com/a/74693/120853

    % Build failed on my system due to lack of the 'canberra' module,
    % see for a fix: https://askubuntu.com/a/872397/978477

    % Running the document to generate the PDF and PDF_TEX file from the original SVG
    % will require SHELL ESCAPE (--shell-escape), aka elevation.
    % However, after the auxiliary images have been created, they only need to be input;
    % shell-escape will no longer be required.
    \svgpath{images/vectors/}% Analogous to \graphicspath{}
    \svgsetup{%
        inkscapepath=svgsubdir,% Put into subdirectory of where original SVG was found
        % In most cases, we include SVGs that contain no text, then add it in a
        % tikzpicture overlay. Therefore, don't generate *.pdf_tex file.
        % Toggle this back to true wherever needed, on a per-file basis
        inkscapelatex=false,
    }

    % When placing nodes over included SVGs using Tikz,
    % we require some help to debug the positions:
    \newcommand*{\debugtikzsvg}{%
        % This has to be evoked within a TikZ scope of:
        % `\begin{scope}[x={(image.south east)},y={(image.north west)}]`
        % The image we invoke the grid "on top of" needs to be labelled "image":
        \draw[help lines, xstep=0.02,ystep=0.02, opacity=0.5]
            (image.south west) grid (image.north east);
        \draw[gray, thick, xstep=0.1,ystep=0.1, opacity=0.8]
            (image.south west) grid (image.north east);
        %
        \foreach \posfraction in {%
            0, 0.1, ...,1%
        }{%
            \foreach \startpoint/\endpoint/\nodeorientation in {% 2D-grid
                south west/south east/below,%
                north west/north east/above,%
                south east/north east/right,%
                south west/north west/left%
            }{
                \node[\nodeorientation, opacity=0.5]
                    at ($(image.\startpoint)!\posfraction!(image.\endpoint)$)
                    {%
                        \pgfmathparse{int(\posfraction*10)}% Round result
                        \num{\pgfmathresult}%
                    };
            }%
        }%
    }%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Custom Symbols
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{scalerel}% Scale stuff relative to e.g. letters

% Wrapper to include vectors icons by filename and scale them
\newcommand*{\mtlbsmlkicon}[1]{%
    \scalerel*{%
        \includesvg{logos/matlab_simulink/#1}%
    }{%
        X% Scale first argument to height for capital X
    }%
}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tikz + Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{pgfplots}% Also loads Tikz

% For advanced table calcs, e.g. 'y expr' to mathematically process input data:
\RequirePackage{pgfplotstable}

\RequirePackage[edges]{forest}% Comprehensive trees

\RequirePackage{tikz-3dplot}

% Only use libraries as needed to keep compilation times low
\usetikzlibrary{%
    positioning,% Relative positioning etc.
    calc,% Calculate distances, coordinates etc.
    shapes, % For cross out
    backgrounds,% Draw on background layer
    fit,% Fit new node around existing coordinates
    decorations,
    arrows,
    arrows.spaced,
    intersections,
    trees,
    circuits.ee.IEC,% Electrical engineering circuits lib
    patterns,
    3d,
    tikzmark,% Marks/coordinates at arbitrary positions
}%
\usepgfplotslibrary{%
    colorbrewer,%
    units,%
    dateplot,
    fillbetween,
    groupplots,
}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Colour Cycle for plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\pgfplotscreateplotcyclelist{mod RdYlBu3}{% Modify existing colorbrewer
    {rdylbu2},
    {black!50},
    {rdylbu5}% No comma or space here!
}%

\pgfplotscreateplotcyclelist{mod mark list}{% Modify predefined to start without mark
    every mark/.append style={solid,fill=\pgfplotsmarklistfill}\\
    every mark/.append style={solid,fill=\pgfplotsmarklistfill},mark=*\\
    every mark/.append style={solid,fill=\pgfplotsmarklistfill},mark=square*\\
    every mark/.append style={solid,fill=\pgfplotsmarklistfill},mark=triangle*\\
    every mark/.append style={solid},mark=star\\
    every mark/.append style={solid,fill=\pgfplotsmarklistfill},mark=diamond*\\
    every mark/.append style={solid,fill=\pgfplotsmarklistfill!40},mark=otimes*\\
    every mark/.append style={solid},mark=|\\
    every mark/.append style={solid,fill=\pgfplotsmarklistfill},mark=pentagon*\\
}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global plot settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\pgfplotstableset{col sep=comma}% If ALL files/tables are comma-separated

\pgfplotsset{%
    % Version this document was originally created with;
    % see also https://tex.stackexchange.com/a/81912/120853
    % Important for reproducibility
    compat=1.16,
    % In case nodes reach out of plot area, dont clip them off.
    % See: https://tex.stackexchange.com/a/127904/120853 and
    % https://tex.stackexchange.com/a/311194/120853
    clip mode=individual,
    label style={font=\small},% https://tex.stackexchange.com/a/300673/120853
    tick label style={%
        font=\small,%
        /pgf/number format/1000 sep={\,}% Small space instead of comma
    },
    cycle multi list={%
        mod mark list\nextlist% Just in case; likely never reached
        linestyles*\nextlist
        % Iterate through last one first; if at end,
        % start anew using next in parent (linestyles *):
        mod RdYlBu3%
    },%
    colormap/viridis,% For 3D/surf plots
    legend style={%
        at={(0.5,1.05)},% Center hor. (0.5), slightly out of drawing(>1 vert.)
        anchor=south,%
        legend columns=-1,% -1 means only rows, as many columns as required
        font=\footnotesize,%
        draw=none,% Do not draw box
        fill=none,% No white fill. Important for gray backgrounds
    },%
    % These comment lines (visual separation) are super important.
    % Empty lines will throw errors here!
    unit code/.code 2 args={\si{#1#2}},% Use siunitx for units library
    unit markings={slash space},% The proper way... apparently?
    %
    % Fix micro unit display, see https://tex.stackexchange.com/a/224574/120853:
    x SI prefix/micro/.style={/pgfplots/axis base prefix={axis x base 6 prefix \micro}},
    y SI prefix/micro/.style={/pgfplots/axis base prefix={axis y base 6 prefix \micro}},
    z SI prefix/micro/.style={/pgfplots/axis base prefix={axis z base 6 prefix \micro}},
    %
    % Plot styles:
    regularplot/.style={% A broadly usable, regular plot
        ultra thick,
        axis line style=thick,
        ymajorgrids=true,
        xmajorgrids=true,
        grid style=dashed,
        axis lines=left,
        % scale only axis,% If off, labels are taken into account for size calculations
        ytick align=outside,% Puts ticks outside the plot itself
        xtick align=outside,%
        % Won't work if enlarge limits are invoked before 'axis lines left':
        enlargelimits=0.05,
    },%
    plainplot/.style={%
        % A clean, simple plot when numerical values and labels don't matter
        regularplot,
        xmajorgrids=false,
        ymajorgrids=false,
        ticks=none,% No ticks with numbers
    },
    tuftelike/.style={% https://tex.stackexchange.com/a/155210/120853
        axis line shift=10pt,% Also shifts label automatically
        try min ticks=3,% https://tex.stackexchange.com/a/95753/120853
        max space between ticks=50,% High number so ticks are far apart
        axis lines=left,
        ultra thick,
        axis line style = {semithick, -},% '-' suppresses arrow
        tick style = {semithick, black},%
        ytick align=inside,% Puts ticks inside the plot itself
        xtick align=inside,%
        xtick={%
            % Always set min, max and middle ticks;
            % if more desired, use 'extra x ticks={}'
            \pgfkeysvalueof{/pgfplots/xmin},
            \pgfkeysvalueof{/pgfplots/xmax},
            (\pgfkeysvalueof{/pgfplots/xmax}+\pgfkeysvalueof{/pgfplots/xmin})/2
        },
        ytick={% Same as x
            \pgfkeysvalueof{/pgfplots/ymin},
            \pgfkeysvalueof{/pgfplots/ymax},
            (\pgfkeysvalueof{/pgfplots/ymax}+\pgfkeysvalueof{/pgfplots/ymin})/2
        },
        clip = false,% https://tex.stackexchange.com/a/311194/120853
    },%
    % Unfortunately, decorations lib is relatively verbose:
    arrowplot/.style={
        decoration={
            markings,
            mark=at position 0.25 with {\arrow{#1}},
            mark=at position 0.5 with {\arrow{#1}},
            mark=at position 0.75 with {\arrow{#1}},
        },
        postaction=decorate,
    },
    %
    log x ticks with fixed point/.style={%
        % Logarithmic plot, but with linear labels instead of scientific notation
        % (10^2 becomes 100 etc.)
        % https://tex.stackexchange.com/a/139084/120853
        xticklabel={
            \pgfkeys{/pgf/fpu=true}
            \pgfmathparse{exp(\tick)}%
            \pgfmathprintnumber[fixed relative, precision=3]{\pgfmathresult}
            \pgfkeys{/pgf/fpu=false}
        }
    },
    %
    log y ticks with fixed point/.style={
        yticklabel={
            \pgfkeys{/pgf/fpu=true}
            \pgfmathparse{exp(\tick)}%
            \pgfmathprintnumber[fixed relative, precision=3]{\pgfmathresult}
            \pgfkeys{/pgf/fpu=false}
        }
    }
}

% Required in \tikset body for node placing at x style.
% Requires intersection lib
% https://tex.stackexchange.com/a/93968/120853
\def\parsenode[#1]#2\pgf@nil{%
    \tikzset{label node/.style={#1}}
    \def\nodetext{#2}
}

\tikzset{%
    >=stealth',% Global arrow style
    symmetrycross/.style={%
        % Style for a center-cross to mark symmetry in technical drawings.
        % Styles have one argument per default. Use it for size,
        % but also provide a default
        draw,
        cross out,% From shapes library
        thin,
        dashdotted,
        rotate=45,
        minimum size=#1,% This is an argument
    },
    symmetrycross/.default={2em},
    pipecrosssection/.style={
        circle,
        minimum size=#1,
        draw=black!90!red,
        ultra thick,% Simulate thick pipe around it
        fill=MediumFluid
    },
    pipecrosssection/.default={0.5em},
    arrowlabel/.style={ % Style for labels along arrows
        pos=#1,
        text=black,% Overwrite in case encapsulating draw command is white etc.
        draw=none,% Do not draw border
        fill=white,
        inner sep=1.5pt,
        rounded corners,
    },
    arrowlabel/.default={0.5}, % Default for position: middle
    wall/.style={ % For all walls, e.g. in crosssections of pipes, ...
        draw,
        thick,
        fill=#1,
        line join=round,
        rounded corners=0.5,
    },
    wall/.default={g5},
    fluid/.style={ % For all fluids
        fill=#1,
    },
    fluid/.default={MediumFluid},
    flowarrow/.style 2 args={% A style for squiggly arrows, for flows:
        ->,
        line join=round,
        thick,
        dashed,
        decorate,
        decoration={
            snake, % alternatives: snake, zigzag
            segment length=#1,
            amplitude=#2,
            % Stop with decoration at start and end by the given length and just draw
            % a line:
            pre=lineto,
            post=lineto,
            pre length=1em,
            post length=1em
        },
    },
    annotationarrow/.style={%
        % A style intended to point a line with a thick black dot at its end onto
        % elements to give further explanations.
        % Since we shorten the line START, any line using this style should originate
        % from the place where the shortening is supposed to take place.
        % Further explanation here:
        % https://tex.stackexchange.com/a/115268/120853
        % Simply call -* (or any other similar command) after annoationarrow if the
        % direction should be inverted.
        *-,
        shorten <=-(1.8pt + 1.4\pgflinewidth),%
    },
    flowarrow/.default={3em}{2em},% {<INVERSE FREQUENCY>}{<AMPLITUDE>}
    origindot/.style={ % A simple small dot for coordinate starts/origins
        circle,
        fill=#1,
        inner sep=0pt,
        minimum width=0.4em
    },
    origindot/.default={black},
    add node at x/.style 2 args={% https://tex.stackexchange.com/a/93968/120853
        % Add node on a plot by just specifying its x-position.
        % The corresponding y/value is computed automatically!
        name path global=plot line,
        /pgfplots/execute at end plot visualization/.append={
                \begingroup
                \@ifnextchar[{\parsenode}{\parsenode[]}#2\pgf@nil
            \path [name path global=position line #1-1]
                ({axis cs:#1,0}|-{rel axis cs:0,0}) --
                ({axis cs:#1,0}|-{rel axis cs:0,1});
            \path [xshift=1pt, name path global=position line #1-2]
                ({axis cs:#1,0}|-{rel axis cs:0,0}) --
                ({axis cs:#1,0}|-{rel axis cs:0,1});
            \path [
                name intersections={
                    of={plot line and position line #1-1},
                    name=left intersection
                },
                name intersections={
                    of={plot line and position line #1-2},
                    name=right intersection
                },
                label node/.append style={pos=1}
            ] (left intersection-1) -- (right intersection-1)
            node [label node]{\nodetext};
            \endgroup
        }
    },
    shorten <>/.style={% Allow shortening of both ends simultaneously
        shorten >=#1,
        shorten <=#1,
    },
    circlednum/.style={% Used for a custom circled number command
        shape=circle,
        draw,
        inner sep=2pt,
        fill=white
    }%,
    % A reusable little 'pic' for a common radiator.
    % Further down, we also declare a 'shape' for a radiator. A 'shape' is a node shape with anchors etc. and intended to be used to connect nodes together, like in a circuit diagram.
    % A 'pic' is really just a reusable picture that can be put anywhere, but it (by the package author) not intended to be connected etc.
    % This pic is prettier than the shape below. The pic should be used for large radiator images where more detail is desired.
    radiator/.pic={
        \tikzset{%
            every path/.style={
                    draw,
                    thick,
                    line join=round,
                    line cap=round,% End of lines
                    fill=g5,
                    pic actions,% Whatever is used in \pic[<drawing options>], e.g. dashed, is propagated to this drawing
                },
        }
        % Base measurements. Default unit is centimeter
        \pgfmathsetmacro{\radiatorheight}{2}
        \pgfmathsetmacro{\radiatorwidth}{3}
        \pgfmathsetmacro{\radiatordepth}{0.5}

        % Right surface:
        \begin{scope}[canvas is yz plane at x=\radiatorwidth]
            \draw[fill=g4] (0,0) rectangle (\radiatorheight,\radiatordepth);

            % Fake the thermostat a bit:
            \draw[fill=g3] (0.8*\radiatorheight,0.5*\radiatordepth) circle (0.2*\radiatordepth);

            % Generate some coordinates in analogy to regular tikz naming convetions:
            \foreach \yfrac/\zfrac/\coordname in {%
                    0.5/0.5/center,%
                    0/0.5/south,%
                    1/0.5/north,%
                    0.5/0/east,
                    0.5/1/west,
                    0/0/south east,%
                    0/1/south west,%
                    1/1/north east,%
                    1/0/north west,%
                    0.8/0.5/thermostat%
                }{
                    \coordinate (-right \coordname) at (\yfrac*\radiatorheight,\zfrac*\radiatordepth);
                }
        \end{scope}

        % Top surface:
        \begin{scope}[canvas is xz plane at y=\radiatorheight]
            \draw (0,0) rectangle (\radiatorwidth,\radiatordepth);

            % "Hollow space" inside the radiator:
            \draw[fill=g2, rounded corners=0.75] (0.05*\radiatorwidth,0.3*\radiatordepth) rectangle (0.95*\radiatorwidth,0.7*\radiatordepth);

            % Generate some coordinates in analogy to regular tikz naming convetions:
            \foreach \xfrac/\zfrac/\coordname in {%
                    0.5/0.5/center,%
                    0.5/1/south,%
                    0.5/0/north,%
                    1/0.5/east,
                    0/0.5/west,
                    1/1/south east,%
                    0/1/south west,%
                    1/0/north east,%
                    0/0/north west%
                }{
                    \coordinate (-top \coordname) at (\xfrac*\radiatorwidth,\zfrac*\radiatordepth);
                }
        \end{scope}

        % Front surface:
        \begin{scope}[canvas is xy plane at z=\radiatordepth]
            \draw (0,0) rectangle (\radiatorwidth,\radiatorheight);

            \foreach \posfraction in {0.1, 0.2, ..., 0.9}
                {%
                    \draw[
                        thick,
                        preaction={draw, ultra thick, g3},
                    ] (\posfraction*\radiatorwidth, 0.1*\radiatorheight) -- (\posfraction*\radiatorwidth, 0.9*\radiatorheight);
                }
            % Generate some coordinates in analogy to regular tikz naming convetions:
            \foreach \xfrac/\yfrac/\coordname in {%
                    0.5/0.5/center,%
                    0.5/0/south,%
                    0.5/1/north,%
                    1/0.5/east,
                    0/0.5/west,
                    1/0/south east,%
                    0/0/south west,%
                    1/1/north east,%
                    0/1/north west%
                }{
                    \coordinate (-front \coordname) at (\xfrac*\radiatorwidth,\yfrac*\radiatorheight);
                }
            \node at (-front center) {\ctrw{\tikzpictext}};% value of "pic text" key is stored in \tikzpictext macro
        \end{scope}

        % Coordinates for convenience:
        \coordinate (-thermostat) at (-right thermostat);
        \coordinate (-entry) at ($(-front north west)!0.2!(-front south west)$);
        \coordinate (-exit) at ($(-right south)!0.2!(-right north)$);
        \coordinate (-left center) at (-front west|--right center);% To have an exact opposite of the visible 'center right' position

        % Debugging coordinate system:
        % \draw[->] (0,0,0) -- (1,0,0) node[right] {\(x\)};
        % \draw[->] (0,0,0) -- (0,1,0) node[left] {\(y\)};
        % \draw[->] (0,0,0) -- (0,0,1) node[above] {\(z\)};
    },
    TUHHuman/.pic={% A human member of TUHH. Hilarious......
        \pgfmathsetmacro{\roundingradius}{0.4}
        \filldraw[pic actions] (0,0) circle (1);% Head
        %
        % Use arc over just specifying 'rounded corners', because rounded corners are absolute and aren't affected by 'scale'
        \filldraw[pic actions]
        (0,-1.2)% Below head
         -- ++ (2.5-\roundingradius,0) arc (90:0:\roundingradius)% Right shoulder
         -- ++ (0,{-(5 - 2*\roundingradius)}) arc (0:-90:\roundingradius) -- ++ ({-(0.8 - 2*\roundingradius)},0) arc (270:180:\roundingradius) -- ++ (0,{4 - \roundingradius})% Right arm
         -- ++ (-0.25,0)% Right arm pit
         -- ++ (0,{-(8 - \roundingradius)}) arc (0:-90:\roundingradius) -- ++ ({-(1 - 2*\roundingradius)},0) arc (270:180:\roundingradius) -- ++ (0,{4 - 2*\roundingradius}) arc (0:90:\roundingradius)% Right leg
         -- ++ ({-(1 - 2*\roundingradius)},0)% Gap between legs
         arc (90:180:\roundingradius) -- ++ (0,{-(4 - 2*\roundingradius)}) arc (0:-90:\roundingradius) -- ++ ({-(1 - 2*\roundingradius)},0) arc (270:180:\roundingradius) -- ++ (0,{8 - \roundingradius})% Left leg
         -- ++ (-0.25,0)% Left arm pit
         -- ++ (0,{-(4 - \roundingradius)}) arc (0:-90:\roundingradius) -- ++ ({-(0.8 - 2*\roundingradius},0) arc (270:180:\roundingradius) -- ++ (0,{5 - 2*\roundingradius})% Left arm
         arc (180:90:\roundingradius)-- cycle;% Left shoulder; cycle back to below head
        
        \node[right, transform shape] at (-1.25,-2.5) {\ctrw{\textcolor[RGB]{45,198,214}{\textbf{\textsf{TUHH}}}}};% Chest emblem; transform shape allows node to be affected by 'scale' option
        %
        % \draw[help lines] (-3,-11) grid (3,1);% Debugging grid
    },
    boilercylinder/.style={
        cylinder,% Shapes lib
        draw,
        thick,
        shape border rotate=90,
        aspect=0.3,% Flatten
        cylinder uses custom fill,
        % cylinder body fill=g5,% For regular filling, use these and comment out the colors at the bottom here
        % cylinder end fill=g4,%
        left color=HotFluid!70,
        middle color=orange!20,
        right color=g4,
        shading angle=180,
    },
    % Still use a pic so we can flexible add stuff to all boilers later one, like a burner on the bottom left side:
    boiler/.pic={
        \node[
            boilercylinder,
            minimum width=4em,
            minimum height=6em,
            pic actions,% Whatever is used in \pic[<drawing options>], e.g. dashed, is propagated to this drawing
        ] () {\ctrw{\tikzpictext}};% Empty coordinate is important for namespace stuff
    },
    equalizing tank/.style={
        circle split,
        draw,
        solid,% In case surrounding context is dashed etc.
        -,% As opposed to arrows etc.
        fill=white,
        double,
        minimum width=#1,
    },
    equalizing tank/.default={1.5em},
    pipe/.style={% (Water) pipes between devices. For a pipe without arrow line end, call it as e.g. \draw[pipe, -]
        line width=#1,
        double=MediumFluid,
        double distance={1*#1},
        -{Triangle Cap []. Fast Triangle[] Fast Triangle[] Fast Triangle[]},% dot represents line end
        line join=round,
    },
    pipe/.default={1.5pt},
    valve/.style={
        shape=valve,
        draw,
        solid,% In case surrounding context is dashed etc.
        -,% As opposed to arrows etc.
        fill=white,
        rounded corners=0.5,
        rotate=90,% We probably need the horizontal version more often. Also, this way, \draw ... node[midway, valve, sloped] {}; works out of the box
        minimum width=0.6*#1,% Fixed aspect ratio
        minimum height=#1,
    },
    valve/.default={1em},
    control valve/.style={% Same node style but different shape
        valve,
        % blue!10,
        shape=controlvalve,
    },
    threeway valve/.style={
        valve,
        shape=threeway valve,
        minimum width=0.85*#1,% Scale it a bit...
        minimum height=#1,
    },
    threeway valve/.default={1em},
    fourway valve/.style={
        valve,
        rotate=-90,% It's symmetrical, no need to rotate; undo inherited rotation
        shape=fourway valve,
        minimum width=#1,% Fixed aspect ratio, square
        minimum height=#1,
    },
    fourway valve/.default={1em},
    threeway control valve/.style={
        threeway valve,
        shape=threewaycontrolvalve,
    },
    radiator/.style={
        shape=radiator,
        draw,
        fill=g6,
        line join=round,
        minimum width=#1,
        minimum height=(2/3)*#1,% Fixed aspect ratio
    },
    radiator/.default={3em},
    vented radiator/.style={
        radiator,% Inherit from style
        shape=vented radiator,% Different shape
    },
    pump/.style={
        shape=pump,
        draw,
        solid,% In case surrounding context is dashed etc.
        -,% As opposed to arrows etc.
        fill=white,
        line join=round,
        minimum width=#1,
        rounded corners=0.5,% Alter rounded corners in case surrounding style has them
    },
    pump/.default={1.5em},
    compressor/.style={
        shape=compressor,
        draw,
        solid,
        -,
        fill=white,
        line join=round,
        minimum size=#1,
        sloped,% Because why not
    },
    compressor/.default={1.5em},
    heat exchanger/.style={
        shape=heat exchanger,
        draw,
        solid,
        -,
        fill=white,
        line join=round,
        rounded corners=0.5,
        minimum width=#1,
        minimum height=0.5*#1,% Fixed aspect ratio
        sloped,% Because why not
    },
    heat exchanger/.default={1.5em},
    simple heat exchanger/.style={
        shape=simple heat exchanger,
        draw,
        solid,
        -,
        fill=white,
        line join=round,
        minimum width=#1,
        minimum height=2/3*#1,% Fixed aspect ratio
        sloped,% Because why not
    },
    simple heat exchanger/.default={1.5em},
    sensor/.style={% A vertical stroke with with three horizontal lines of decreasing width underneath
        shape=sensor,
        draw,
        solid,
        -,
        line join=round,
        line cap=round,
        minimum width=#1,
        minimum height=2*#1
    },
    sensor/.default={0.5em},
    level indicator/.style={% An upside-down triangle with three horizontal lines of decreasing width underneath
        shape=levelindicator,
        draw,
        fill=white,
        solid,
        -,
        line join=round,
        line cap=round,
        minimum width=#1,
        minimum height=2*#1,
        inner sep=1.5pt,
    },
    level indicator/.default={0.25em}
}


% PGF shape definitions for thermodynamic pictures, icons, ...
\input{lib/thermo_pgf.tex}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scientifics Typesetting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{chemformula}% \ch{}, \chcpd[]{compound} etc.
    \setchemformula{%
        font-family={tgpl}% Use math font family
    }

    % Provide a new environment for chemical reactions.
    % I tried the syntax from the 'environ' package and also the \NewDocumentEnvironment
    % command from 'xparse', but none of them worked especially well, so it's back to
    % plain syntax, unfortunately.
    \newcounter{chemreac}[chapter]
    %
    \newenvironment{chemreac}{%
        \addtocounter{equation}{-1}
        \renewcommand*{\theequation}{\textbf{R}\thechapter.\thechemreac}
        \begin{equation}
            % Our counter is called 'chemreac', however it seems that cref always uses
            % the 'type' of the last \refstepcounter{} called.
            % Therefore, step our custom counter after equation starts
            % see https://tex.stackexchange.com/a/239121/120853
            \refstepcounter{chemreac}
    }{%
        \end{equation}%
    }%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{siunitx}% Typesetting physical units correctly
    \sisetup{%
        detect-all,% Detect surrounding font context, like weight, italics etc.
        text-rm=\unitnumberfont,% https://tex.stackexchange.com/a/468031/120853
        %
        % Alternative range-phrase:
        % en-dash via '--', but inside \text{}, so it's not 'two minus signs'
        % range-phrase={\,\text{--}\,},
        range-units=single,% single: Print unit only once, at end
        math-micro=\text{µ},% https://tex.stackexchange.com/a/54915/120853
        text-micro=µ,
        per-mode=symbol,
    }%
    % Second setup step, with locales. See also
    % https://tex.stackexchange.com/a/46979/120853
    \gappto{\blockextras@german}{%
        \sisetup{locale=DE}
    }
    \gappto{\blockextras@english}{%
        \sisetup{locale=US}
    }

    % Declare units ourselves:
    % Set as text so it stays a hyphen in math mode, as opposed to minus sign
    \DeclareSIUnit{\volpercent}{Vol.\text{-}\%}
    \DeclareSIUnit{\kilowatthour}{kWh}%
    \DeclareSIUnit{\annum}{a}%
    \DeclareSIUnit{\atmosphere}{atm}%
    \DeclareSIUnit{\partspermillion}{ppm}%

    % Unit qualifiers, i.e. subscripts.
    % We already have a dedicated system (bib file with glossaries-extra) for subscripts
    % for symbols, so use those (just format, don't index) also for units here.
    \DeclareSIQualifier{\dryair}{% for moist air context
        \glsfmtname{sub.dry}\glsfmtname{sub.air}%
    }
    \DeclareSIQualifier{\water}{%
        \glsfmtname{sub.water}%
    }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hyperref and PDFs appearance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage[pdfusetitle]{hyperref}% Loads url-package internally
    \hypersetup{%
        % Unicode settings are automatically true for luatex engine,
        % don't specify manually
        colorlinks=true,% No ugly frames, but still colored
        allcolors=darklink,%
        % hidelinks,% Toggle here!
        plainpages=false,%
        pdfcreator={%
            LaTeX with hyperref,
            glossaries-extra/bib2gls
            and biblatex/biber
            [\GitRefName{}@\GitShortSHA{}]%
        },
        bookmarksnumbered=true,%
        % Default opening of the document in supported PDF viewers:
        pdfpagelayout=TwoPageRight,
        % pdfsubject={},%
        % pdfkeywords={},%
        pdfdisplaydoctitle,% https://tex.stackexchange.com/a/435434/120853
    }%

    % In order to translate, polyglossia wraps things into \text<language>, e.g.
    % \textenglish. If this is part of a PDF string, like when we do
    % \addchap{\glossaryname}, LaTeX/hyperref will complain that \textenglish is not a
    % PDF string and is dropped.
    % Therefore, disable commands of the form \text<language> in this document. Don't
    % use a static language but the current language from kvoptions.
    %
    % Expansion works as follows:
    % \expandafter is executed, causing \let to be saved for later.
    % \csname is then executed next. It scans ahead to its matching \endcsname,
    % "performing full expansion as it goes" (Quote from
    %  https://tex.stackexchange.com/a/430557/120853).
    % In that process, \cookbook@language is expanded to the value it was given in the
    % document options through kvoptions.
    % Now, \csname finishes and presents a token \text<language>, e.g. \textenglish.
    % LaTeX starts over; \expandafter is now gone, so it reads \let\text<language> ...
    % In this case, ... is \relax, removing the macro definition.
    % It will no longer occur in PDF commands.
    % See also:
    % https://www.overleaf.com/learn/latex/Articles/How_does_%5Cexpandafter_work:_A_detailed_study_of_consecutive_%5Cexpandafter_commands
    % and
    % TUGboat, Volume 9, 1988, No. 1: Macros: A Tutorial on \expandafter by
    % Stephan v. Bechtolsheim.
    %
    % Idea from https://tex.stackexchange.com/a/230197/120853
    \pdfstringdefDisableCommands{%
        \expandafter\let\csname text\cookbook@language\endcsname \relax%
    }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Appearance of the bookmarks popup in viewers that support it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\RequirePackage{bookmark}% Control bookmark appearance in PDF
    \bookmarksetup{%
        open,% Open bookmark pane in PDF viewer
        openlevel=1,% Open first two levels, hide all subsections etc. (0-indexed)
        addtohook={%
            \ifnum\bookmarkget{level}=0% Only print top-level (0) bookmarks bold
                \bookmarksetup{bold}%
            \fi%
        },%
    }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Glossaries
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[% Initiate with package options for predefined styles
    nomain,% Nomain, aka no default glossary
    record,% Record usages of commands to auxiliary files for bib2gls
    abbreviations,% Regular abbreviations/acronyms
    symbols,% Physical symbols
    index,% A regular book index at the end
    numbers% constants like Pi
]{glossaries-extra}% Also see https://tex.stackexchange.com/q/477658/120853

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New Glossary 'types'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Using Abbreviations/Symbols etc. package options creates these glossaries already.
    % Create the rest manually.
    \newglossary*{subscripts}{\TransSubscripts{}}%

    % For example, in the case of symbols, there are three groups: roman, greek and
    % other.
    % If the 'other' sub-glossary is used (it provides the built-ins like
    % \mean, \vect, \deriv, ...) but is NOT supposed to be printed in the PDF glossary,
    % it is assigned to the following glossary type.
    % The glossary is printed using \printunsrtglossary with a `type=<entry type>`
    % keyword specified, which would also print the 'other' entries, since they are of
    % type 'symbols' as well. Only by assigning a different type altogether is this
    % circumvented. This does not impact using the commands and the defined entries using
    % \sym{<entry name>}, since that is provided by the 'label-prefix', not the 'type'.
    % Analogue procedures apply to all glossaries.
    \newglossary*{notprinted}{Non-printed entries}% Title never occurs anyway!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New Glossary 'fields'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add custom key for a 'unit' field for symbols:
    \glsaddkey{unit}%
        {\relax}%
        {\glsentryunit}%
        {\Glsentryunit}%
        {\glsunit}%
        {\Glsunit}%
        {\GLSunit}

    % For specific quantities (enthalpy etc.)
    \glsaddkey{specific}%
        {\relax}%
        {\glsentryspecific}%
        {\Glsentryspecific}%
        {\glsspecific}%
        {\Glsspecific}%
        {\GLSspecific}

    % For First names of people
    \glsaddkey{firstname}%
        {\relax}%
        {\glsentryfirstname}%
        {\Glsentryfirstname}%
        {\glsfirstname}%
        {\Glsfirstname}%
        {\GLSfirstname}

    % For values of numbers/constants
    \glsaddkey{value}%
        {\relax}%
        {\glsentryvalue}%
        {\Glsentryvalue}%
        {\glsvalue}%
        {\Glsvalue}%
        {\GLSvalue}

    % For international versions of symbols
    \glsaddkey{international-symbol}%
        {\relax}%
        {\glsentryinternationalsymbol}%
        {\Glsentryinternationalsymbol}%
        {\glsinternationalsymbol}%
        {\Glsinternationalsymbol}%
        {\GLSinternationalsymbol}

    % For alternative versions of symbols
    \glsaddkey{alternative-symbol}%
        {\relax}%
        {\glsentryalternativesymbol}%
        {\Glsentryalternativesymbol}%
        {\glsalternativesymbol}%
        {\Glsalternativesymbol}%
        {\GLSalternativesymbol}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Abstract the prefixes here.
% For example, if we load 'symbols' from a 'roman' file,
% we define a prefix and call entries later as \gls{<prefix>.<entry>}
% These prefixes are used in various places; define them here once and reference later
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    \newcommand*{\symprefix}{sym.}
    \newcommand*{\subprefix}{sub.}
    \newcommand*{\nameprefix}{name.}
    \newcommand*{\constantsprefix}{cons.}
    \newcommand*{\indexprefix}{idx.}
    \newcommand*{\abbreviationprefix}{abb.}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the bib files:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    \GlsXtrLoadResources[%
        src={bib/glossaries/abbreviations},%
        sort=doc,% Use document language for sorting
        label-prefix={\abbreviationprefix},
        type=abbreviations,
        selection={all},%
    ]%
    \GlsXtrLoadResources[%
        src={bib/glossaries/index/terms},%
        sort=doc, % Use document language for sorting
        type=index,
        group=terms,
        label-prefix={\indexprefix},
        selection={all},%
    ]%
    \GlsXtrLoadResources[%
        src={bib/glossaries/index/names},%
        sort=doc, % Use document language for sorting
        type=index,
        category=names,
        group=names,
        label-prefix={\nameprefix},
        selection={all},%
    ]%
    \GlsXtrLoadResources[%
        src={bib/glossaries/symbols/roman},%
        sort=doc, % Use document language for sorting
        symbol-sort-fallback=name,% Sort by name aka symbol if sort field is missing
        %
        % If first field is equal, sort by this next (by appending it).
        % E.g. 'c' for 'Velocity' and also for 'Heat Capacity' is then sorted with
        % 'Heat Capacity' first etc.:
        sort-suffix=description,
        label-prefix={\symprefix},
        type=symbols,% Change this to 'notprinted' to omit printing in the glossary
        category={same as type},
        selection={all},
        group={roman},
    ]%
    \GlsXtrLoadResources[%
        src={bib/glossaries/symbols/greek},%
        sort=doc, % Use document language for sorting
        symbol-sort-fallback=name,% Sort by name aka symbol if sort field is missing
        %
        % If first field is equal, sort by this next (by appending it).
        % E.g. 'c' for 'Velocity' and also for 'Heat Capacity' is then sorted with
        % 'Heat Capacity' first etc.:
        sort-suffix=description,
        label-prefix={\symprefix},
        type=symbols,% Change this to 'notprinted' to omit printing in the glossary
        category={same as type},
        selection={all},
        group={greek},
    ]%
    \GlsXtrLoadResources[%
        src={bib/glossaries/symbols/other},%
        sort=doc, % Use document language for sorting
        symbol-sort-fallback=name,% Sort by name aka symbol if sort field is missing
        %
        % If first field is equal, sort by this next (by appending it).
        % E.g. 'c' for 'Velocity' and also for 'Heat Capacity' is then sorted with
        % 'Heat Capacity' first etc.:
        sort-suffix=description,
        label-prefix={\symprefix},
        type=symbols,% Change this to 'notprinted' to omit printing in the glossary
        category={same as type},
        selection={all},
        group={other},
    ]%
    \GlsXtrLoadResources[%
        src={bib/glossaries/symbols/subscripts},%
        % sort=doc, % Use document language for sorting
        sort-field=name,% Default is by label, not by name
        type=subscripts,%
        category=subscripts,
        label-prefix={\subprefix},
        selection={all},%
    ]%
    \GlsXtrLoadResources[
        src={bib/glossaries/constants},% constants.bib
        type={numbers},% set the type for all selected entries
        category={number},% set the category for all selected entries
        label-prefix={\constantsprefix},
    ]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Introduce new commands that alias \gls commands and allow modifiers
% You then use e.g. \sym{velocity} to access \gls{sym.velocity} etc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    \glsxtrnewgls{\symprefix}{\sym}% \sym{XYZ} is like \gls{sym.XYZ}
    \glsxtrnewgls{\subprefix}{\sub}
    \glsxtrnewgls{\nameprefix}{\name}
    \glsxtrnewgls{\constantsprefix}{\cons}
    \glsxtrnewgls{\indexprefix}{\idx}
    \glsxtrnewgls{\abbreviationprefix}{\abb}

    % We cannot alias the commands introduced by `\glsaddkey` the same way:
    % \glsxtrnewgls only works on \gls{<prefix>.<key>} to alias the <prefix> away
    % into its own command. However, for a command like \glsspecific{}, it does not work.
    % We can therefore do \sym{volume}, but have to do \glsspecific{sym.volume}, i.e.
    % specify the prefix manually.
    % A short-cut command is therefore enabled by the following commands.
    \newcommand*{\symspec}[2][]{\glsspecific[#1]{\symprefix#2}}
    % Register with glossaries-extra so it writes info to aux file:
    \glsxtridentifyglslike{\symprefix}{\symspec}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Further Options:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % indexonlyfirst can also be a package option.
    % Index only on first use for certain categories, as set manually above.
    % https://tex.stackexchange.com/a/318886/120853
    % \glssetcategoryattribute{symbols}{indexonlyfirst}{true}
    % \glssetcategoryattribute{subscripts}{indexonlyfirst}{true}
    \glssetcategoryattribute{names}{textformat}{textsc} % As printed in the text
    \glssetcategoryattribute{names}{glossnamefont}{textsc} % As printed in the Glossary

    \newcommand*{\specificsymbolmark}{*}
    %
    \glsdefpostdesc{symbols}{% If entry has field 'specific', its description is marked
        \ifglshasfield{specific}{\glscurrententrylabel}%
        {\specificsymbolmark}%
        {}%
    }

    % Append stuff after 'name' field for the 'symbols' category.
    % Syntax: \ifglshasfield{<field>}{<label>}{<true part>}{<falsepart>}
    \newcommand*{\alternativesymbolmark}{/}
    %
    \glsdefpostname{symbols}{%
        % If entry has field 'international-symbol', append it after the regular entry:
        \ifglshasfield{international-symbol}{\glscurrententrylabel}%
        { [\glsentryinternationalsymbol{\glscurrententrylabel}]}%
        {}% Do nothing in else
        % If entry has a field 'alternative-symbol', append it after the regular entry:
        \ifglshasfield{alternative-symbol}{\glscurrententrylabel}%
        {\ \alternativesymbolmark{}\ \glsentryalternativesymbol{\glscurrententrylabel}}%
        {}%
    }

    % Give proper names for all groups here to override the default,
    % automatically generated ones
    \AtBeginDocument{% Do this after preamble, else errors out
        \glsxtrsetgrouptitle{greek}{\TransGreek{}}
        \glsxtrsetgrouptitle{roman}{\TransRoman{}}
        \glsxtrsetgrouptitle{other}{\TransOther{}}
        \glsxtrsetgrouptitle{terms}{\TransTerms{}}
        \glsxtrsetgrouptitle{names}{\TransNames{}}
    }

    \setglossarysection{section} % One down in rprt/book

    % Some styles require manual setting of width for the first column.
    % Automate this and find widest entry:
    \setglossarypreamble[subscripts]{\glsfindwidesttoplevelname[\currentglossary]}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New Styles for glossary printing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    \RequirePackage{glossary-bookindex} % The style used for the Index

    \RequirePackage{glossary-mcols} % Multi-column styles used for Subscripts

    % Long, elaborate base style, providing e.g. 'long3col' for the abbreviations etc.:
    \RequirePackage{glossary-longextra}

    \newcommand*{\glshdrfont}[1]{\textbf{#1}} % Font for gls table heads

    % To print symbols:
    \newglossarystyle{symbunitlong}{% https://tex.stackexchange.com/a/269571/120853
        % Base new style on existing one. This is quite important, since it implements
        % all otherwise missing but maybe required commands,
        % like \glsgroupskip if --group option is used for bib2gls
        \setglossarystyle{long-name-desc-loc}

        \renewcommand*{\glossaryheader}{}% Remove it

        \renewenvironment{theglossary}{%
            % Use Longtabu over longtable, the latter caused inexplicable issues with
            % 'Column widths have changed, rerun Latex'
            \begin{longtabu}{%
                r%
                p{0.5\linewidth}%
                p{\glspagelistwidth}%
                l%
            }%
        }{%
            \end{longtabu}%
        }%

        \renewcommand*{\glsgroupskip}{\addlinespace\addlinespace}%

        \renewcommand*{\glsgroupheading}[1]{%
            \glshdrfont{\glsgetgrouptitle{##1}} &
            \glshdrfont{\descriptionname} &
            \glshdrfont{\pagelistname} &
            \glshdrfont{\TransUnit{}}
            \tabularnewline
        }%

        \renewcommand*{\glossentry}[2]{%
            \glsentryitem{##1}\glstarget{##1}{\glossentryname{##1}} &
            \glossentrydesc{##1}\glspostdescription &
            ##2 &
            % Use glsentryunit to access entry, NOT glsunit,
            % https://tex.stackexchange.com/a/281772/120853:
            \glsentryunit{##1}
            \tabularnewline
        }
    }

    % To print constants, as in physical constants with values and unit:
    \newglossarystyle{numberlong}{% https://tex.stackexchange.com/a/269571/120853
        % Base new style on existing one. This is quite important, since it implements
        % all otherwise missing but maybe required commands, like
        % \glsgroupskip if --group option is used for bib2gls
        \setglossarystyle{long-name-desc-loc}

        \renewcommand*{\glossaryheader}{}% Remove it

        \renewenvironment{theglossary}{
            % Use Longtabu over longtable, the latter caused inexplicable issues with
            % 'Column widths have changed, rerun Latex'
            \begin{longtabu}{%
                r%
                p{0.3\linewidth}%
                r%
                @{\;}%
                l%
                p{\glspagelistwidth}%
            }%
        }{%
            \end{longtabu}%
        }%

        \renewcommand*{\glossaryheader}[1]{%
            \glshdrfont{\symbolname} &
            \glshdrfont{\descriptionname} &
            \multicolumn{2}{l}{{\glshdrfont{\TransPhysicalQuantity{}}}} &
            \glshdrfont{\pagelistname}
            \tabularnewline
        }%

        \renewcommand*{\glossentry}[2]{%
            \glsentryitem{##1}\glstarget{##1}{\glossentryname{##1}} &
            \glossentrydesc{##1}\glspostdescription &
            \glsentryvalue{##1} &
            % Use glsentryunit to access entry, NOT glsunit,
            % https://tex.stackexchange.com/a/281772/120853:
            \glsentryunit{##1} &
            ##2
            \tabularnewline
        }%
    }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% References
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Should be loaded late, because it does a lot of redefinitions.
% With Polyglossia, cleveref recognizes what was passed in
% \setdefaultlanguage and uses it. It must come before cleveref is loaded.

\RequirePackage[
    % Always capitalise; still, use \Cref and \cref appropriately in case that changes!
    capitalise,
    nameinlink,% Name of reference is part of PDF hyperlink
    noabbrev,% Full expansion: Figure instead of Fig., etc.
]{cleveref}%
    \creflabelformat{equation}{#2#1#3}% No (1), but 1, aka remove parentheses

    % Syntax: \crefname{<counter>}{<singular>}{<plural>}
    % \Crefname (capitalised) is not required; when it is not present but \Cref{} is
    % called, it uses \MakeUppercase on \crefname definitions.
    % However, if LaTeX macros are used in the definition, it is required.
    \crefname{chemreac}{\TransReaction{}}{\TransReactions{}}
    \Crefname{chemreac}{\TransReaction{}}{\TransReactions{}}
    \creflabelformat{chemreac}{#2\textbf{R}#1#3}% No (1), but 1, aka remove parentheses

    % Note that there is also a \crefname redefinition for listings,
    % later in the document

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Color Boxes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{tcolorbox}% Put after tikz
    \tcbuselibrary{many}%
    \tcbset{%
        highlight math style={%
            colframe=white,
            colback=g6,
        },%
    }%

    \newtcolorbox[%
        auto counter,%
        number within=chapter,%
        % Set cleveref, see https://tex.stackexchange.com/a/126023/120853:
        crefname={\TransExample{}}{\TransExamples{}},
        % List of Examples. *.loe file ending could clash with package thmtools,
        % careful if that is used!
        list inside=loe,
    ]{example}% Name of environment itself
        [2]% Number of arguments for the environment
        []% Default of optional argument, which is the first one. Use it for label
        {%
            beforeafter skip=18pt plus 4pt minus 4pt,%
            width=0.95\linewidth,%
            % Center box; see https://tex.stackexchange.com/a/273111/120853:
            enlarge left by=0.025\linewidth,
            title=\TransExample{}\ \thetcbcounter: #2,%
            fonttitle=\sffamily,%
            leftrule=1mm,%
            arc is angular,%
            parbox,% Allows regular paragraph breaks
            breakable,% Breaks across pages
            enhanced,% Hands drawing to tikz
            rightrule=0mm,%
            bottomrule=0mm,%
            % Setting what ends up in 'list of' so that '<Title>' is not shown:
            list text=#2,
            #1,%
            colback=g6,%
            colframe=g1,%
            % float,
        }%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Custom Commands
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{suffix}% For variants of custom commands

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Maths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To insert math equations into the text flow,
% we need punctuation marks at the end of display-style equations.
% Prepend them with a small horizontal space for visual separation.

\newcommand*{\eqend}{\,.}% Command \eqdot reserved by unicode-math
\newcommand*{\eqcomma}{\,,}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gradient operator (so that it will be printed upright)
\DeclareMathOperator{\grad}{grad}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand*{\const}{\text{\TransConstant{}.}}% For all 'constant' expressions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quick Quad like physics package. For text between two equation parts.
% We do not use physics package because it is currently not in a good condition:
% https://tex.stackexchange.com/q/471532/120853
\newcommand*{\qq}[1]{\quad\text{#1}\quad}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Unified markup for constructs of the form:
% '1.2 ppm CO2' etc., with correct, specified spacing.
\newcommand*{\chemamount}[3]{%
    \ensuremath{%
        \SI{#1}{#2}%
        \;% Medium-sized space
        \chcpd{#3}%
    }%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Circle input and parse as a number
\newcommand*{\circlednum}[1]{%
    \tikz[baseline=(char.base)]{%
            \node[circlednum] (char) {\num{#1}};
    }
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a couple of wrappers to integrate with gls
% These are only necessary because we cannot really create gls entries that also accept
% arguments, so we treat them separately.

% Use the \<XYZ>fmt commands only to format arguments, without doing anything else.
% Then use the \<XYZ> commands in the text, which includes indexing etc.
% We use \glsdisp, which works like \glsdisp{<indexed label>}{<displayed link text>}
% and respects the first use flag.
% If {<displayed link text>} contains another glossary-entry, e.g. a \sym command,
% that is still indexed and seems to work. The link leads to <indexed label>.

% If the custom commands do not make use of gls-like commands explicitly,
% add a \glsadd to create an entry in the glossary, but no text at the location
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use dottedsquare (provided by unicode-math package, refer to unimath-symbols.pdf)
% as a placeholder for symbols
% HACKY: Raise it a bit, since default symbol hangs low
\newcommand*{\symbolplaceholder}{\raisebox{0.3ex}{\dottedsquare}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mean value: horizontal overbar. The built-in options all look poor
% https://tex.stackexchange.com/a/22134/120853
\newcommand*{\meanfmt}[1]{%
    \ensuremath{%
        \mkern 1.5mu%
        \overline{%
            \mkern-1.5mu#1\mkern-1.5mu%
        }%
        \mkern 1.5mu%
    }%
}
\newcommand*{\mean}[1]{\glsdisp{sym.mean}{\meanfmt{#1}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Logarithmic mean
\newcommand*{\logmeanfmt}[1]{\ensuremath{\tilde{#1}}}
\newcommand*{\logmean}[1]{\glsdisp{sym.logmean}{\logmeanfmt{#1}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dotted symbol for flows
\newcommand*{\flowfmt}[1]{\ensuremath{\dot{#1}}}
\newcommand*{\flow}[1]{\glsdisp{sym.flow}{\flowfmt{#1}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delta/Difference
\newcommand*{\differencefmt}[1]{\ensuremath{\Delta #1}}
\newcommand*{\difference}[1]{\glsdisp{sym.difference}{\differencefmt{#1}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wrapper for Nabla Operator
\newcommand*{\nablaoperatorfmt}[1]{\ensuremath{\nabla #1}}
\newcommand*{\nablaoperator}[2][]{% Optional argument is degree
    \ensuremath{%
        \glsdisp{sym.nabla}{\nablaoperatorfmt{^{#1}#2}}
    }%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wrapper for Heat Exchanger Entry
\newcommand*{\heatexentryfmt}[1]{\ensuremath{#1'}}
\newcommand*{\heatexentry}[1]{\glsdisp{sym.heatexentry}{\heatexentryfmt{#1}}}

% Wrapper for Heat Exchanger Exit
\newcommand*{\heatexexitfmt}[1]{\ensuremath{#1''}}
\newcommand*{\heatexexit}[1]{\glsdisp{sym.heatexexit}{\heatexexitfmt{#1}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vector with bold symbol instead of arrow
\newcommand*{\vectfmt}[1]{\ensuremath{\symbf{#1}}}
\newcommand*{\vect}[1]{\glsdisp{sym.vector}{\vectfmt{#1}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Derivatives
% These functionalities are also provided by the otherwise useful 'physics' package.
% However, that package has many issues and is best avoided!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Base Version:
% Syntax: \deriv[<degree>]{<symbol>}

% Starred variant gives partial derivative.
% The star/asterisk and brackets (optional argument in []) may both be left out.

% Usage example 1: \deriv*[2]{x} -> 2nd degree partial derivative of x
% Usage example 2: \deriv{x} -> derivative of x
% Usage example 3: \deriv*{x} -> partial derivative of x
% Usage example 4: \deriv[5]{x} -> 5th derivative of x

% \newcommand syntax: 
% \newcommand{<command>}[<number of arguments>][<defaults>]{<code>}

% I.e., if [<defaults>] is empty, no default values exist.
% If one optional argument exists, it takes #1, and the mandatory arguments are appended
% as #2, ...

% Use explicit glssymbol, since the regular field 'name' is oppcupied by what will be
% printed in the glossary (with the \symbolplaceholder appended)
\newcommand*{\derivativefmt}[1]{%
     % Upright d in derivatives
    \ensuremath{\mathup{d}#1}%
}%

\newcommand*{\partialderivativefmt}[1]{%
    \ensuremath{\partial #1}%
}

\newcommand*{\deriv}[2][]{%
    \ensuremath{%
        \glsdisp{sym.derivative}{%
            \derivativefmt{^{#1}#2}%
        }%
    }%
}%

% Make it so that starred version of \deriv{} command gives partial derivative
\WithSuffix\newcommand\deriv*[2][]{%
    \ensuremath{%
        \glsdisp{sym.partial_derivative}{%
            \partialderivativefmt{^{#1}#2}%
        }%
    }%
}%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fraction version:

% Syntax: \fracderiv[<degree>]{<numerator>}{<denominator>}

% Starred variant gives partial derivative.
% The star/asterisk and brackets (optional argument in []) may both be left out.

% timederiv simply inserts the time symbol as the denominator automatically.
% posderiv does the same for the positional coordinate symbol.

% Usage example 1: \fracderiv*[2]{x}{y}
% Usage example 2: \fracderiv{x}{y}
% Usage example 3: \timederiv[3]{x} % Note how there is no second mandatory argument
% Usage example 4 \posderiv*[2]{y} % Note how there is no second mandatory argument

\newcommand{\fracderiv}[3][]{%
    \ensuremath{%
        \frac{%
            \deriv[#1]{#2}%
        }{%
            \deriv{#3}^{#1}%
        }%
    }%
}%
% starred version gives partial derivative
\WithSuffix\newcommand\fracderiv*[3][]{%
    \ensuremath{%
        \frac{%
            \deriv*[#1]{#2}%
        }{%
            \deriv*{#3}^{#1}%
        }%
    }%
}

% Time derivative
\newcommand*{\timederiv}[2][]{%
    \fracderiv[#1]{#2}{\gls{sym.time}}%
}%
% Partial Time derivative
\WithSuffix\newcommand\timederiv*[2][]{%
    \fracderiv*[#1]{#2}{\gls{sym.time}}%
}

% Positional derivative
\newcommand*{\posderiv}[2][]{%
    \fracderiv[#1]{#2}{\gls{sym.first_cart_coord}}%
}
% Partial Positional derivative
\WithSuffix\newcommand\posderiv*[2][]{%
    \fracderiv*[#1]{#2}{\gls{sym.first_cart_coord}}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temperature splits/pairs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To print: 45/55 °C
\newcommand*{\temperaturepair}[2]{%
    \SIrange[%
        range-phrase={/},%
        range-units=single%
    ]{#1}{#2}{\degreeCelsius}%
}%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Indicating an image etc. has been adapted from it source
\newcommand*{\adaptedfrom}{%
    \TransAdaptedFrom{}%
}%

% Document metadata commands, like \author etc.
% See also https://stackoverflow.com/a/2833982
\newcommand*{\documenttype}[1]{%
    \renewcommand*{\@documenttype}{#1}%
}

% \@ehc is generic error text, see also
% https://tex.stackexchange.com/a/59952/120853.
% A quick test showed that it prints:
%
%      Try typing <return> to proceed.If that doesn’t work, type X <return>
%      to quit.
%
% It's a help message. Help messages are a required third argument for ClassErrors
% and PackageErrors, but not Warnings.

\newcommand*{\@documenttype}{%
    \ClassWarning{cookbook}{No \noexpand\documenttype given}%{\@ehc}%
}

% Student ID number
\newcommand*{\idnumber}[1]{%
    \renewcommand*{\@idnumber}{#1}%
}
\newcommand*{\@idnumber}{%
    \ClassWarning{cookbook}{No \noexpand\idnumber given}%{\@ehc}%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A signature field with places for the date and time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand{\signaturefield}[1][\@author]{%
    % This should only occur on pages with a lot of other pages behind it, to support
    % writing on it here.
    % If is occurs at the beginning of the document, put it recto. At the end, verso.
    % Else, writing and stamping on here won't have much support.
    \vspace*{1.5cm}% Leave room for signature
    \begin{center}
        \begin{tabular}{%
            % Columns widths control signature line length
            M{12em}
            M{4em}% Empty middle
            M{12em}
        }
            \cmidrule{1-1}\cmidrule{3-3}
                \textit{#1} &
                & % Empty column
                \textit{\TransPlaceDate{}}
                \\
        \end{tabular}
    \end{center}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Only for the purpose of demonstration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\definecolor{DarkLinkGreen}{RGB}{65, 107, 60}

% Wrapper for links to CTAN, or elsewhere
\newcommand*{\ctanpackage}[2][None]{%
    % Usage:
    % \ctanpackage[]{siunitx} -> no link generated, warning issued
    % \ctanpackage[www.test.com]{siunitx} -> link to optional argument
    % \ctanpackage{siunitx} -> link to siunitx on CTAN (https://ctan.org/pkg/siunitx)
    \ifstrequal{#1}{None}{%
        \def\package@link{https://ctan.org/pkg/#2}%
    }{%
        \def\package@link{#1}%
    }%
    \expandafter\href\expandafter{\package@link}{%
        \textcolor{DarkLinkGreen}{\texttt{\textbf{#2}}}%
    }%
}%

% This sentence contains all 26 letters of the Latin alphabet (pangram)
\newcommand*{\sampletext}{%
    The quick brown Fox jumps over the lazy Dog 13 times!%
}

% For demonstrating upright math operators
\DeclareMathOperator{\examplemean}{MEAN}
