# Docker image with custom, almost-full TeXLive distribution & various tools

[![Docker Pulls](https://img.shields.io/docker/pulls/alexpovel/latex)](https://hub.docker.com/r/alexpovel/latex)

Serves a lot of needs surrounding LaTeX file generation and handling.
For the rationale behind the installed Debian packages, see [below](#custom-tools).
To see how to build the image, also see [below](#building).

## Quick Intro

If you use [VSCode Remote Containers](https://code.visualstudio.com/docs/remote/containers), the below does not apply.
There is no need to run manual `docker` invocations on the host.

---

[Install Docker](https://docs.docker.com/get-docker/), navigate to your project directory, then run the image as follows:

- Bash:

  ```bash
  docker run --rm --volume $(pwd):/tex alexpovel/latex
  ```

- PowerShell:

  ```powershell
  docker run --rm --volume ${PWD}:/tex alexpovel/latex
  ```

The parts making up the command are:

- The last line is the location on [DockerHub](https://hub.docker.com/repository/docker/alexpovel/latex).
  Without specifying a [*tag*](https://hub.docker.com/repository/docker/alexpovel/latex/tags?page=1), the default `latest` is implied.
  See [below](#historic-builds) for more options.
- The `--rm` option removes the container after a successful run.
  This is generally desired since containers are not supposed to be stateful: once their process terminates, the container terminates, and it can be considered junk.
- Providing a `--volume`, in this case the current working directory aka pwd, is required for the container to find files to work on.
  It has to be *mounted* to a location *inside* the container.
  This has to be whatever the last `WORKDIR` instruction in the [Dockerfile](Dockerfile) is, e.g. `/tex`.

  Otherwise, you can always override the `WORKDIR` using the `--workdir` option.
  This is the directory in which the Docker container's process works in and expects to find files.
- Note that there is no command given, e.g. there is nothing *after* `alexpovel/latex`.
  In this form, the container runs as an executable (just as if you ran `lualatex` or similar commands), where the program to be executed is determined by the `ENTRYPOINT` instruction in the [Dockerfile](Dockerfile).

  For example, if the `ENTRYPOINT` is set to `latexmk`, running the above command will execute `latexmk` in the container's context, without you having to specify it.

  (`latexmk` is a recipe-like tool that automates LaTeX document compilation by running `lualatex`, `biber` and whatever else required for compilation as many times as needed for proper PDF output (so references like `??` in the PDF are resolved).
  It does this by detecting that auxiliary files no longer change (steady-state).
  The tool is best configured using its config file, `.latexmkrc`.)

  Any options to the `ENTRYPOINT` executable are given at the end of the command, e.g.:

  ```bash
  docker run --rm --volume $(pwd)/tests:/tex alexpovel/latex -c
  ```

  to run, if `latexmk` is the `ENTRYPOINT`, the equivalent of `latexmk -c` ([cleaning auxiliary files](https://mg.readthedocs.io/latexmk.html#cleaning-up)).

  To **overwrite** the `ENTRYPOINT`, e.g. because you want to run only `lualatex`, use the `--entrypoint` option, e.g. `--entrypoint="lualatex"`.
  Similarly, you can work inside of the container directly, e.g. for debugging, using `--entrypoint="bash"`.

### Image

For the above to work, the `alexpovel/latex` image needs to be available on whatever your default image registry is (usually [DockerHub](https://hub.docker.com/)).
If it's not available for pulling (i.e., downloading) from there, you can build this image locally, see [below](#building).

## Approach

This Dockerfile is based on a custom TeXLive installer using their [`install-tl` tool](https://www.tug.org/texlive/doc/install-tl.html), instead of [Debian's `texlive-full`](https://packages.debian.org/search?searchon=names&keywords=texlive-full).
Other, smaller `texlive-` collections would be [available](https://packages.debian.org/search?suite=default&section=all&arch=any&searchon=names&keywords=texlive), but TeXLive cannot install missing packages on-the-fly, [unlike MiKTeX](https://miktex.org/howto/miktex-console/).
Therefore, images should come with all desirable packages in place; installing them after the fact in running containers using [`tlmgr`](https://www.tug.org/texlive/tlmgr.html) is the wrong approach (containers are only meant to be run; if they are incomplete, modify the *image*, ordinarily by modifying the `Dockerfile`).

This approach has the following advantages:

- Using ["vanilla" TeXLive](https://www.tug.org/texlive/debian.html) affords us the latest packages directly from the source, while the official   Debian package might lag behind a bit.
  This is often not relevant, but has bitten me several times while working with the latest packages.
- The installation can be adjusted better.
  For example, *multiple GBs* of storage/image size are saved by omitting unneeded PDF documentation files.
- We can install arbitrary TeXLive versions, as long as they are the [current](https://tug.org/texlive/acquire-netinstall.html) or an archived (<ftp://tug.org/historic/systems/texlive/>) version.
  Otherwise, to obtain [older or even obsolete TeXLive installations](#historic-builds), one would have to also obtain a corresponding Debian version.
  This way, we can choose a somewhat recent Debian version and simply install an old TeXLive into it.

  Eligible archive versions are those year directories (`2019`, `2020`, ...) present at the above FTP link that have a `tlnet-final` subdirectory.
  This is (speculating here) a frozen, aka final, version, put online the day the *next* major release goes live.
  For example, version `2021` released on 2021-04-01 and `2020` received its `tlnet-final` subdirectory that same day.

The `install-tl` tool is configured via a [*Profile* file](config/texlive.profile), see also the [documentation](https://www.tug.org/texlive/doc/install-tl.html#PROFILES).
This enables unattended, pre-configured installs, as required for a Docker installation.

---

The (official?) [`texlive/texlive` image](https://hub.docker.com/r/texlive/texlive) follows [the same approach](https://hub.docker.com/layers/texlive/texlive/latest/images/sha256-70fdbc1d9596c8eeb4a80c71a8eb3a5aeb63bed784112cbdb87f740e28de7a80?context=explore).
However, there are a bunch of things this Dockerfile does differently that warrant not building `FROM` that image:

- a user-editable, thus more easily configurable [profile](config/texlive.profile).
  This is mainly concerning the picked package *collections*.
  Unchecking (putting a `0`) unused ones saves around 500MB at the time of writing.
- more elaborate support for [historic versions](#historic-builds)
- an installation procedure incorporating a proper `USER`

Things they do that do not happen here:

- verify download integrity using `gpg`

### Historic Builds

LaTeX is a slow world, and many documents/templates in circulation still rely on outdated practices or packages.
This can be a huge hassle.
Maintaining an old LaTeX distribution next to a current one on the same host is not fun.
This is complicated by the fact that (La)TeX seems to do things differently than pretty much everything else.
For this, Docker is the perfect tool.

This image can be built (`docker build`) with different build `ARG`s, and the build process will figure out the proper way to handle installation.
There is a [script](texlive.sh) to handle getting and installing TeXLive from the proper location ([current](https://www.tug.org/texlive/acquire-netinstall.html) or [archive](ftp://tug.org/historic/systems/texlive/)).
Refer to the [Dockerfile](Dockerfile) for the available `ARG`s (all `ARG` have a default).
These are handed to the build process via the [`--build-arg` option](https://docs.docker.com/engine/reference/commandline/build/#options).

Note that for a *specific* TeXLive version to be picked, it needs to be present in their [archives](ftp://tug.org/historic/systems/texlive/).
The *current* TeXLive is not present there (it's not historic), but is available under the `latest` Docker tag.
As such, if for example `2020` is the *current* TeXLive, and the image is to be based on Debian 10, there is *no* `debian-10-texlive-2020` tag.
You would obtain this using the `latest` tag.
As soon as TeXLive 2020 is superseded and consequently moved to the archives, the former tag can become available.

To build an array of different versions automatically, DockerHub provides [advanced options](https://docs.docker.com/docker-hub/builds/advanced/) in the form of hooks, e.g. a [build hook](hooks/build).
These are bash scripts that override the default DockerHub build process.
At build time, DockerHub provides [environment variables](https://docs.docker.com/docker-hub/builds/advanced/#environment-variables-for-building-and-testing) which can be used in the build hook to forward these into the Dockerfile build process.
As such, by just specifying the image *tags* on DockerHub, we can build corresponding images automatically (see also [here](https://web.archive.org/web/20201005132636/https://dev.to/samuelea/automate-your-builds-on-docker-hub-by-writing-a-build-hook-script-13fp)).
For more info on this, see [below](#on-dockerhub).

The approximate [matching of Debian to TeXLive versions](https://www.tug.org/texlive/debian.html) is (see also [here](https://www.debian.org/releases/) and [here](https://www.debian.org/distrib/archive).):

| Debian Codename | Debian Version | TeXLive Version |
| --------------- | :------------: | :-------------: |
| bullseye        |       11       |      2020       |
| buster          |       10       |      2018       |
| stretch         |       9        |      2016       |
| jessie          |       8        |      2014       |
| wheezy          |       7        |      2012       |
| squeeze         |      6.0       |      2009       |
| lenny           |      5.0       |     unknown     |
| etch            |      4.0       |     unknown     |
| sarge           |      3.1       |     unknown     |
| woody           |      3.0       |     unknown     |
| potato          |      2.2       |     unknown     |
| slink           |      2.1       |     unknown     |
| hamm            |      2.0       |     unknown     |

This is only how the official Debian package is shipped.
These versions can be, to a narrow extend, freely mixed.
Using `install-tl`, older versions of TeXLive can be installed on modern Debian versions.

#### Issues

Using [*obsolete* Debian releases](https://www.debian.org/releases/) comes with a long list of headaches.
As such, Debian versions do not reach too far back.
It does not seem worth the effort.
Instead, it seems much easier to install older TeXLive versions onto reasonably recent Debians.

Issues I ran into are:

- `apt-get update` will fail if the original Debian repository is dead (Debian 6/TeXLive 2014):

  ```plaintext
  W: Failed to fetch http://httpredir.debian.org/debian/dists/squeeze/main/binary-amd64/Packages.gz  404  Not Found
  W: Failed to fetch http://httpredir.debian.org/debian/dists/squeeze-updates/main/binary-amd64/Packages.gz  404  Not Found
  W: Failed to fetch http://httpredir.debian.org/debian/dists/squeeze-lts/main/binary-amd64/Packages.gz  404  Not Found
  E: Some index files failed to download, they have been ignored, or old ones used instead.
  ```

  As such, there needs to be a [dynamic way to update `/etc/apt/sources.list`](https://github.com/alexpovel/latex-extras-docker/blob/fa9452c236079a65563daff22767b2b637dd80c6/adjust_sources_list.sh) if the Debian version to be used in an archived one, see also [here](https://web.archive.org/web/20201007095943/https://www.prado.lt/using-old-debian-versions-in-your-sources-list).
- `RUN wget` (or `curl` etc.) via `HTTPS` will fail for older releases, e.g. GitHub rejected the connection due to the outdated TLS version of the old release (Debian 6/TeXLive 2015):

  ```text
  Connecting to github.com|140.82.121.4|:443... connected.
  OpenSSL: error:1407742E:SSL routines:SSL23_GET_SERVER_HELLO:tlsv1 alert protocol version
  ```

- Downloading older releases requires using the [Debian archives](http://archive.debian.org/debian/).
  This works fine, however a warning is issued (Debian 6/TeXLive 2014):

  ```plaintext
  W: GPG error: http://archive.debian.org squeeze Release: The following signatures were invalid: KEYEXPIRED 1520281423 KEYEXPIRED 1501892461
  ```

  Probably related to this, the installation then fails:

  ```plaintext
  WARNING: The following packages cannot be authenticated!
    libgdbm3 libssl0.9.8 wget libdb4.7 perl-modules perl openssl ca-certificates
  E: There are problems and -y was used without --force-yes
  ```

  According to `man apt-get`, `--force-yes` is both deprecated and absolutely not recommended.
  The correct course here is to `--allow-unauthenticated`, however this would also affect the build process for modern versions, where authentication *did not* fail.
  The official Debian archives are probably trustworthy, but this is still an issue.
- A more obscure issue is (Debian 7/TeXLive 2011):

  ```plaintext
  The following packages have unmet dependencies:
    perl : Depends: perl-base (= 5.14.2-21+deb7u3) but 5.14.2-21+deb7u6 is to be installed
  E: Unable to correct problems, you have held broken packages.
  ```

  While the error message itself is crystal-clear, debugging this is probably a nightmare.
- Tools like `pandoc`, which was released in [2006](https://pandoc.org/releases.html), limit the earliest possible Debian version as long as the tool's installation is part of the Dockerfile.
  In this example, 2006 should in any case be early enough (if not, update your LaTeX file to work with more recent versions, that is probably decidedly less work).

## Custom Tools

The auxiliary tools are (for the actual, up-to-date list, see the [Dockerfile](Dockerfile)):

- A *Java Runtime Environment* for [`bib2gls`](https://ctan.org/pkg/bib2gls) from the [`glossaries-extra` package](https://www.ctan.org/pkg/glossaries-extra).

  `bib2gls` takes in `*.bib` files with glossary, symbol, index and other definitions and applies sorting, filtering etc.
  For this, it requires Java.
- [`inkscape`](https://inkscape.org/) because the [`svg`](https://ctan.org/pkg/svg) package needs it.
  We only require the CLI, however there is no "no-GUI" version available.
  Headless Inkscape is [currently in the making](https://web.archive.org/web/20201007100140/https://wiki.inkscape.org/wiki/index.php/Future_Architecture).

  Using that package, required PDFs and PDF_TEXs are only generated at build-time (on the server or locally) and treated as a cache.
  As such, they can be discarded freely and are regenerated in the next compilation run, using `svg`, which calls `inkscape`.
  Therefore, the `svg` package gets rid of all the PDF/PDF_TEX intermediate junk and lets us deal with the true source -- `*.svg` files -- directly.
  These files are really [XML](https://en.wikipedia.org/wiki/Scalable_Vector_Graphics), ergo text-based, ergo suitable for VCS like `git` (as opposed to binary PDFs).

  Being an external tool, `svg`/`inkscape` also requires the `--shell-escape` option to `lualatex` etc. for writing outside files.
- [`gnuplot`](http://www.gnuplot.info/) for `contour gnuplot` commands for `addplot3` in `pgfplots`.
  So essentially, an external add-on for the magnificent `pgfplots` package.
  For `gnuplot` to write computed results to a file for `pgfplots` to read, `--shell-escape` is also required.
- [`pandoc`](https://pandoc.org/) as a very flexible, convenient markup conversion tool.
  For example, it can convert Markdown (like this very [README](README.md)) to PDF via LaTeX:

  ```bash
  pandoc README.md --output=README.pdf  # pandoc infers what to do from suffixes
  ```

  The default output is usable, but not very pretty.
  This is where *templates* come into play.
  A very tidy and well-made such template is [*Eisvogel*](https://github.com/Wandmalfarbe/pandoc-latex-template).
  Its installation is not via a (Debian) package, so it has to be downloaded specifically.
  For this, additional requirements are:

  - `wget` to download the archive,
  - `librsvg2-bin` for the `rsvg-convert` tool.
    This is used by `pandoc` to convert SVGs when embedding them into the new PDF.

  Note that `pandoc` and its *Eisvogel* template can draw [metadata from a YAML header](https://pandoc.org/MANUAL.html#metadata-variables), for example:

  ```yaml
  ---
  title: "Title"
  author: [Author]
  date: "YYYY-MM-DD"
  subject: "Subject"
  keywords: [Keyword1, Keyword2]
  lang: "en"
  ...
  ```

  among other metadata variables.
  *Eisvogel* uses it to fill the document with info, *e.g.* the PDF header and footer.

  `pandoc` is not required for LaTeX work, but is convenient to have at the ready for various conversion jobs.

## Building

The proper way to access these images is via DockerHub.

### On DockerHub ([Requires Pro Plan](https://docs.docker.com/docker-hub/builds/))

This repository and its [Dockerfile](Dockerfile) used to be built into the corresponding image continuously and made available on [DockerHub](https://hub.docker.com/repository/docker/alexpovel/latex).
This process now requires a Pro plan and was therefore retired.

For the currently available tags, see [here](https://hub.docker.com/repository/docker/alexpovel/latex/tags?page=1).

### Locally

The Dockerfile is now built locally and pushed manually.
Refer to the Dockerfile for all the available configuration environment variables (`ARG`s).

The build can take a very long time (if you have all collections selected in the [profile](config/texlive.profile)), especially when downloading from the TeXLive/TUG archives.
For developing/debugging, it is advisable to download the archive files once.
E.g. for TexLive 2014, you would want this directory: <ftp://tug.org/historic/systems/texlive/2014/tlnet-final/>.
Download in one go using:

```bash
wget --recursive --no-clobber ftp://tug.org/historic/systems/texlive/2014/tlnet-final
```

The `--no-clobber` option allows you to restart the download at will.
Then, work with the `--repository=/some/local/path` option of `install-tl`, after [copying the archive directory into the image at build time](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#understand-build-context) (see also [here](https://tex.stackexchange.com/a/374651/120853)).
Having a local copy circumvents [unstable connections](https://tex.stackexchange.com/q/370686/120853) and minimizes unnecessary load onto TUG servers.
