#!/bin/bash

# Script to fetch `install-tl` script from different sources, depending on argument
# given.

set -ueo pipefail

usage() {
    echo "Usage: $0 get_installer|install latest|version (YYYY)"
}

check_path() {
    # The following test assumes the most basic program, `tex`, is present, see also
    # https://www.tug.org/texlive/doc/texlive-en/texlive-en.html#x1-380003.5
    echo "Checking PATH and installation..."
    if tex --version
    then
        echo "PATH and installation seem OK, exiting with success."
        exit 0
    else
        echoerr "PATH or installation unhealthy, further action required..."
    fi
}

if [[ $# != 2 ]]; then
    echoerr "Unsuitable number of arguments given."
    usage
    # From /usr/include/sysexits.h
    exit 64
fi

# From: https://stackoverflow.com/a/2990533/11477374
echoerr() { echo "$@" 1>&2; }

# Bind CLI arguments to explicit names:
ACTION=${1}
VERSION=${2}

# Download the `install-tl` script from the `tlnet-final` subdirectory, NOT
# from the parent directory. The latter contains an outdated, non-final `install-tl`
# script, causing this exact problem:
# https://tug.org/pipermail/tex-live/2017-June/040376.html
HISTORIC_URL="ftp://tug.org/historic/systems/texlive/${VERSION}/tlnet-final"
REGULAR_URL="http://mirror.ctan.org/systems/texlive/tlnet"

case ${ACTION} in
    "get_installer")
        if [[ ${VERSION} == "latest" ]]
        then
            # Get from default, current repository
            GET_URL="${REGULAR_URL}/${TL_INSTALL_ARCHIVE}"
        else
            # Get from historic repository
            GET_URL="${HISTORIC_URL}/${TL_INSTALL_ARCHIVE}"
        fi
        wget "$GET_URL"
    ;;
    "install")
        if [[ ${VERSION} == "latest" ]]
        then
            # Install using default, current repository.
            # Install process/script documentation is here:
            # https://www.tug.org/texlive/doc/texlive-en/texlive-en.html
            perl install-tl \
                --profile="$TL_PROFILE"
        else
            # Install using historic repository (`install-tl` script and repository
            # versions need to match)
            perl install-tl \
                --profile="$TL_PROFILE" \
                --repository="$HISTORIC_URL"
        fi

        # If automatic `install-tl` process has already adjusted PATH, we are happy.
        check_path
        echo "install-tl procedure did not adjust PATH automatically, trying other options..."

        # `\d` class doesn't exist for basic `grep`, use `0-9`, which is much more
        # portable. Finding the initial dir is very fast, but looking through everything
        # else afterwards might take a while. Therefore, print and quit after first result.
        # Path example: `/usr/local/texlive/2018/bin/x86_64-linux`
        TEXLIVE_BIN_DIR=$(find / -type d -regextype grep -regex '.*/texlive/[0-9]\{4\}/bin/.*' -print -quit)

        # -z test: string zero length?
        if [ -z "$TEXLIVE_BIN_DIR" ]
        then
            echoerr "Expected TeXLive installation dir not found and TeXLive installation did not modify PATH automatically."
            echoerr "Exiting."
            exit 1
        fi

        echo "Found TeXLive binaries at $TEXLIVE_BIN_DIR"
        echo "Trying native TeXLive symlinking using tlmgr..."

        # To my amazement, `tlmgr path add` can fail but still link successfully. So
        # check if PATH is OK despite that command failing.
        "$TEXLIVE_BIN_DIR"/tlmgr path add || \
            echoerr "Command borked, checking if it worked regardless..."
        check_path
        echoerr "Symlinking using tlmgr did not succeed, trying manual linking..."

        SYMLINK_DESTINATION="/usr/local/bin"

        # "String contains", see: https://stackoverflow.com/a/229606/11477374
        if [[ ! ${PATH} == *${SYMLINK_DESTINATION}* ]]
        then
            # Should never get here, but make sure.
            echoerr "Symlink destination ${SYMLINK_DESTINATION} not in PATH (${PATH}), exiting."
            exit 1
        fi

        echo "Symlinking TeXLive binaries in ${TEXLIVE_BIN_DIR}"
        echo "to a directory (${SYMLINK_DESTINATION}) found on PATH (${PATH})"

        # Notice the slash and wildcard.
        ln \
            --symbolic \
            --verbose \
            --target-directory="$SYMLINK_DESTINATION" \
            "$TEXLIVE_BIN_DIR"/*

        check_path

        echoerr "All attempts failed, exiting."
        exit 1
    ;;
    *)
        echoerr "Input not understood."
        usage
        # From /usr/include/sysexits.h
        exit 64
esac
