# ARGs before the first FROM are global and usable in all stages

ARG BASE_OS="debian"

# Tag of the base OS image
ARG OS_VERSION="testing"

# TeXLive version. This will be used by the `texlive.sh` script to determine what to
# download and install. `latest` will fetch the latest version available on their servers.
# Alternatively, you can specify *a past year* and it will download that version
# from the TeXLive archives and use it (can take a long time).
# For available years, see ftp://tug.org/historic/systems/texlive/ .
ARG TL_VERSION="latest"

ARG _BUILD_CONTEXT_PREFIX=".devcontainer/image/"

# Image with layers as used by all succeeding steps
FROM ${BASE_OS}:${OS_VERSION} as base

# Use `apt-get` over just `apt`, see https://askubuntu.com/a/990838/978477.
# Also run `apt-get update` on every `RUN`, see:
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    # wget for `install-tl` script to download TeXLive, and other downloads.
    wget \
    # In a similar vein, `curl` is required by various tools, or is just very
    # nice to have for various scripting tasks.
    curl \
    # wget/install-tl requires capability to check certificate validity.
    # Without this, executing `install-tl` fails with:
    #
    # install-tl: TLPDB::from_file could not initialize from: https://<mirror>/pub/ctan/systems/texlive/tlnet/tlpkg/texlive.tlpdb
    # install-tl: Maybe the repository setting should be changed.
    # install-tl: More info: https://tug.org/texlive/acquire.html
    #
    # Using `install-tl -v`, found out that mirrors use HTTPS, for which the
    # underlying `wget` (as used by `install-tl`) returns:
    #
    # ERROR: The certificate of '<mirror>' is not trusted.
    # ERROR: The certificate of '<mirror>' doesn't have a known issuer.
    #
    # This is resolved by installing:
    ca-certificates \
    # Update Perl, otherwise: "Can't locate Pod/Usage.pm in @INC" in install-tl
    # script; Perl is already installed, but do not use `upgrade`, see
    # https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#run
    perl \
    # Install `latexindent` Perl dependencies.
    # Found these using this method: https://unix.stackexchange.com/a/506964/374985
    # List of `latexindent` dependencies is here:
    # https://latexindentpl.readthedocs.io/en/latest/appendices.html#linux,
    # see also the helper script at
    # https://github.com/cmhughes/latexindent.pl/blob/master/helper-scripts/latexindent-module-installer.pl
    #
    # Installing via Debian system packages because installing the modules via
    # `cpanm` requires `gcc` and I wanted to avoid installing that (~200MB).
    #
    # YAML::Tiny:
    libyaml-tiny-perl \
    # File::HomeDir:
    libfile-homedir-perl \
    # Unicode:GCString:
    libunicode-linebreak-perl \
    # Log::Log4perl:
    liblog-log4perl-perl \
    # Log::Dispatch:
    liblog-dispatch-perl \
    # Usually, `latexmk` is THE tool to use to automate, in a `make`-like style,
    # LaTeX (PDF) file generation. However, if that is not enough, the following
    # will fill the gaps and cover all other use cases:
    make \
    # Get `envsubst` to replace environment variables in files with their actual
    # values.
    gettext-base \
    # Using the LaTeX package `minted` for syntax highlighting of source code
    # snippets. It's much more powerful than the alternative `listings` (which is
    # pure TeX: no outside dependencies but limited functionality) but requires
    # Python's `pygments` package:
    python3 \
    python3-pygments \
    # Required to embed git metadata into PDF from within Docker container:
    git
    # Required to use pdfunite for merging PDF files. Ghostscript is causing
    # trouble with Mozilla Firefox's PDF Reader.
    poppler-utils

# The `minted` LaTeX package provides syntax highlighting using the Python `pygmentize`
# package. That package also installs a callable script, which `minted` uses, see
# https://tex.stackexchange.com/a/281152/120853.
# Therefore, `minted` primarily works by invoking `pygmentize` (or whatever it was
# overridden by using `\MintedPygmentize`). However, it requires `python` for other
# jobs, e.g. to remove leading whitespace for the `autogobble` function, see the
# "\minted@autogobble Remove common leading whitespace." line in the docs.
# It is invoked with `python -c`, but Debian only has `python3`. Therefore, alias
# `python` to invoke `python3`. Use `update-alternatives` because it's cooler than
# symbolic linking, and made for this purpose.
# If `python` is not available but `pygmentize` is, stuff like `autogobble` and
# `\inputminted`won't work but syntax highlighting will.
# See also https://stackoverflow.com/a/55351449/11477374
# Last argument is `priority`, whose value shouldn't matter since there's nothing else.
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1


FROM base as downloads

# Cannot share ARGs over multiple stages, see also:
# https://github.com/moby/moby/issues/37345.
# Therefore, work in root (no so `WORKDIR`), so in later stages, the location of
# files copied from this stage does not have to be guessed/WET.

# Using an ARG with 'TEX' in the name, TeXLive will warn:
#
#  ----------------------------------------------------------------------
#  The following environment variables contain the string "tex"
#  (case-independent).  If you're doing anything but adding personal
#  directories to the system paths, they may well cause trouble somewhere
#  while running TeX. If you encounter problems, try unsetting them.
#  Please ignore spurious matches unrelated to TeX.

#     TEXPROFILE_FILE=texlive.profile
#  ----------------------------------------------------------------------
#
# This also happens when the *value* contains 'TEX'.
# `ARG`s are only set during Docker image build-time, so this warning should be void.

# Renew (https://stackoverflow.com/a/53682110):
ARG TL_VERSION
ARG _BUILD_CONTEXT_PREFIX

ARG TL_INSTALL_ARCHIVE="install-tl-unx.tar.gz"
ARG EISVOGEL_ARCHIVE="Eisvogel.tar.gz"
ARG INSTALL_TL_DIR="install-tl"

COPY ./${_BUILD_CONTEXT_PREFIX}/texlive.sh .

RUN \
    # Get appropriate installer for the TeXLive version to be installed:
    ./texlive.sh get_installer ${TL_VERSION} && \
    # Get Eisvogel LaTeX template for pandoc,
    # see also #175 in that repo.
    wget https://github.com/Wandmalfarbe/pandoc-latex-template/releases/latest/download/${EISVOGEL_ARCHIVE}

RUN \
    mkdir ${INSTALL_TL_DIR} && \
    # Save archive to predictable directory, in case its name ever changes; see
    # https://unix.stackexchange.com/a/11019/374985.
    # The archive comes with a name in the form of 'install-tl-YYYYMMDD' from the source,
    # which is of course unpredictable.
    tar --extract --file=${TL_INSTALL_ARCHIVE} --directory=${INSTALL_TL_DIR} --strip-components 1 && \
    \
    # Prepare Eisvogel pandoc template (yields `eisvogel.latex` among other things):
    tar --extract --file=${EISVOGEL_ARCHIVE}


FROM base as main

# Renew (https://stackoverflow.com/a/53682110):
ARG TL_VERSION
ARG _BUILD_CONTEXT_PREFIX

ARG TL_PROFILE="texlive.profile"
# Auxiliary, intermediate file:
ARG TMP_TL_PROFILE="${TL_PROFILE}.tmp"

# Layer with graphical and auxiliary tools
# Put as early as possible in Dockerfile since this should rarely change (cache-friendly)
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    # headless, 25% of normal size:
    default-jre-headless \
    # No headless inkscape available currently:
    inkscape \
    # nox (no X Window System): CLI version, 10% of normal size:
    gnuplot-nox \
    # For various conversion tasks, e.g. EPS -> PDF (for legacy support):
    ghostscript

# Pandoc layer; not required for LaTeX compilation, but useful for document conversions
# Put as early as possible in Dockerfile since this should rarely change (cache-friendly)
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    # librsvg2 for 'rsvg-convert' used by pandoc to convert SVGs when embedding
    # into PDF
    librsvg2-bin \
    pandoc

# User to install and run LaTeX as.
# This is a security and convenience measure: by default, containers run as root.
# To work and compile PDFs using this container, you will need to map volumes into it
# from your host machine. Those bind-mounts will then be accessed as root from this
# container, and any generated files will also be owned by root. This is inconvenient at
# best and dangerous at worst.
# The generated user here will have IDs of 1000:1000. If your local user also has those
# (the case for single-user Debians etc.), your local user will already have correct
# ownership of all files generated by the user we create here.
ARG USER="tex"
RUN useradd --create-home ${USER}

# Label according to http://label-schema.org/rc1/ to have some metadata in the image.
# This is important e.g. to know *when* an image was built. Depending on that, it can
# contain different software versions (even if the base image is specified as a fixed
# version).
LABEL \
    maintainer="Alex Povel <alex.povel@tuhh.de>" \
    org.label-schema.description="TeXLive with most packages, JavaRE, Inkscape, pandoc and more" \
    org.label-schema.vcs-url="https://github.com/alexpovel/latex-cookbook" \
    org.label-schema.schema-version="1.0"

ARG INSTALL_DIR="/install"
WORKDIR ${INSTALL_DIR}

# Copy custom file containing TeXLive installation instructions
COPY ${_BUILD_CONTEXT_PREFIX}/config/${TL_PROFILE} ${TMP_TL_PROFILE}
COPY --from=downloads /install-tl/ /texlive.sh ./

# Move to where pandoc looks for templates, see https://pandoc.org/MANUAL.html#option--data-dir
COPY --from=downloads /eisvogel.latex /home/${USER}/.pandoc/templates/

# Global wget config file, see the comments in that file for more info and the rationale.
# Location of that file depends on system, e.g.: https://askubuntu.com/a/368050
COPY ${_BUILD_CONTEXT_PREFIX}/config/.wgetrc /etc/wgetrc

# "In-place" `envsubst` run is a bit more involved, see also:
# https://stackoverflow.com/q/35078753/11477374.
# Do not use `mktemp`, will break Docker caching since it's a new file each time.
RUN cat "$TMP_TL_PROFILE" | envsubst | tee "$TL_PROFILE" && \
    rm "$TMP_TL_PROFILE"

# (Large) LaTeX layer
RUN ./texlive.sh install "$TL_VERSION"

# Remove no longer needed installation workdir.
# Cannot run this earlier because it would be recreated for any succeeding `RUN`
# instructions.
# Therefore, change `WORKDIR` first, then delete the old one.
WORKDIR /${USER}

USER ${USER}

# Load font cache, has to be done on each compilation otherwise
# ("luaotfload | db : Font names database not found, generating new one.").
# If not found, e.g. TeXLive 2012 and earlier, simply skip it. Will return exit code
# 0 and allow the build to continue.
# Warning: This is USER-specific. If the current `USER` for which we run this is not
# the container user, the font will be regenerated for that new user.
RUN luaotfload-tool --update || echo "luaotfload-tool did not succeed, skipping."

# Make our class file available for the entire latex/TeXLive installation, see also
# https://tex.stackexchange.com/a/1138/120853
COPY acp.cls /home/${USER}/texmf/tex/latex/

USER root
# Give back control to own user files; might be root-owned from previous copying processes
RUN chown --recursive ${USER}:${USER} /home/${USER}/
USER ${USER}

# The default parameters to the entrypoint; overridden if any arguments are given to
# `docker run`.
# `lualatex` usage for `latexmk` implies PDF generation, otherwise DVI is generated.
CMD [ "--lualatex" ]

# Allow container to run as an executable; override with `--entrypoint`.
# Allows to simply `run` the image without specifying any executable.
# If `latexmk` is called without a file argument, it will run on all *.tex files found.
ENTRYPOINT [ "latexmk" ]
