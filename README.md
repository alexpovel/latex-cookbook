---
title: "LaTeX, GitLab and Continuous Delivery"
author: [Alex Povel]
date: "2020"
subject: "Presenting the advantages and a workflow using LaTeX and GitLab"
keywords: [LaTeX, GitLab, CI, CD, Markdown]
lang: "en"
titlepage: true
toc: true
colorlinks: true
...

# A LaTeX Cookbook, git and Continuous Delivery

> [Remember, a few hours of trial and error can save you several minutes of looking at the README.](https://twitter.com/iamdevloper/status/1060067235316809729)

This [repository](https://collaborating.tuhh.de/cap7863/latex-git-cookbook)
contains two documents:

1. This README in Markdown format.
   Using `pandoc` with the *Eisvogel* template (more on that later), it is converted
   into a PDF and made available for download.

   The README covers git and Continuous Delivery.
2. A [LaTeX document](cookbook.tex), usable as a cookbook (different "recipes" to
   achieve various things in LaTeX) and also as a template.

   The LaTeX Cookbook PDF covers LaTeX-specific topics.

## git

That being said, onto git.
Eventually, following all the steps, a number of advantages will come to light:

- [SSOT](https://en.wikipedia.org/wiki/Single_source_of_truth): a *Single Source Of Truth*
  for data.
  No more file trees looking like this:

  ```text
  directory
  │   a.txt
  │   help.me.please
  │   Important-Document_2018_version1.pdf
  │   Important-Document_2018_version2.pdf
  │   Important-Document_2018_version3_final.pdf
  │   Important-Document_2018_version3_final_really.pdf
  │   Important-Document_2018_version3_final_really_I-promise.pdf
  │   Important-Document_2018_versionA.pdf
  │   Important-Document_2019-03-56.pdf
  │   Important-Document_2019-03-56_corrections_John-Doe.pdf
  │   Important-Document_2019-03-56_corrections_John-Doe_v2.pdf
  │   invoice.docx
  │   test - Copy (2).tex
  │   test - Copy.tex
  │   test.tex
  │
  └───old_stuff
          Screenshot 1999-09-03-15-23-15(1).bmp
          Screenshot 1999-09-03-15-23-15(2).bmp
          Screenshot 1999-09-03-15-23-15(3).bmp
          Screenshot 1999-09-03-15-23-15(3)_edited.bmp
          Screenshot 1999-09-03-15-23-15.bmp
  ```

  Instead, there is one *working copy* looking like this:

  ```text
  directory
  │   .git (a hidden directory)
  │   a.txt
  │   Important-Document.pdf
  │   Properly-Named-Invoice.docx
  ```

  assuming that `a.txt` is actually needed.
  **All the old junk and redundant copies have been pruned**.
  However, **nothing was lost**.
  The entire history is contained in [**git**](https://en.wikipedia.org/wiki/Git), a *Version Control System*.
  The history is readily summoned anytime, if so required.
  Git calls this its *log*.
  Git works best (some would say only) on text-based files, but it can deal with images, PDFs *etc.*, too.

  The history and everything else git needs is contained in its `.git` directory, which is hidden on both Linux and Windows.
  Everything else in `directory`, so in this case `a.txt`, `Important-Document.pdf` and `Properly-Named-Invoice.docx`, are accessible as usual.
  **There is no difference to how you would normally work with these files.**
  They are on your local disk.
  Together, they are called the *working tree*.

  Therefore (provided that git is used correctly):

  1. Duplicate files are gone,
  2. The art of cumbersome file naming will finally be forgotten,
  3. Old stuff can be safely deleted; this cleans up the working tree and makes it clear which files are no longer needed.
     Only the currently needed files are visible, the rest is history.
- File versioning and the ability to exactly match outputs (PDFs) to the source code
  that generated them.
- Accelerated bug fixing through `git bisect`, a binary search algorithm that helps
  pinpoint commits (stages of development) that introduced regressions.
- Collaboration: each contributor has a version of the source on their local machine.
  Adjustments are made there, and sent to a central, online repository if they are
  considered ready to be published.
  Git can also be used in a distributed fashion (its original strong suit), but we
  assume a remote repository on GitLab.

  Developers can then also fetch the latest changes from the remote and incorporate
  them into their local copy.
- The remote repository also serves as a back-up solution.
  So do all the distributed local copies.
  At all points, there will be a workable copy somewhere.
  In general, it is extremely hard to lose data using git.

## Git(Lab) and Continuous Delivery

GitLab is a platform to host git repositories.
Projects on there can serve as git remotes.
In this sense, it is like GitHub, the first large website to offer such a service.
It is still the largest today.
We use GitLab here because <https://collaborating.tuhh.de/> is an *instance* of
GitLab and therefore freely available to university members.

GitLab offers various features for each project.
This includes a Wiki, an issue tracker and pull request management.
Pull requests are requests from outside collaborators who have *forked* and
subsequently worked on a project.
Forking projects refers to creating a full copy of them in their own user space.
As such, they can then work on it, or do whatever else they want.
If for example they add a feature, their own copy is now ahead of the original by
that feature.
To incorporate the changes back to the original, the original repository's maintainers
can be *requested* to *pull* in the changes.
This way, anyone can collaborate and help, without ever interfering with the main
development in the original.

**Continuous Delivery** refers to continuously shipping out the finished "product".
In this case, these are the compiled PDFs.
This is done using Docker containers.
The advantages are that all collaborators no longer rely on their local toolchain,
but on a unified, common one that was agreed upon.
If LaTeX documents become very long, full compilation runs can take dozens of minutes.
This is outsourced and silently done on the remote servers, if Continuous Delivery
is used.
As such, for example, every `git push` to the servers triggers a *pipeline* which
compiles the PDF and offers it for download afterwards.
The last part could be called *Continuous Deployment*, albeit a very basic version.

### Docker

Docker is a tool providing so-called *containers*.
These containers provide isolated, well-defined environments for applications to run in.
They are created from *running* corresponding Docker *images*.
These images are in turn generated using scripts, so-called *Dockerfiles*.

In summary, we create a `Dockerfile` containing instructions on how the image should
look like.
As a baseline, these instructions often rely on a Debian distribution.
As such, all the usual Debian/Linux tools can be accessed.
The image is then built accordingly, resulting in a large-ish file that contains an
executable environment.
For example, if we install a comprehensive `TeXLive` distribution, the image will be
more than 2 GB in size.
Once the image is created, it can be run, creating the container.
We can then enter the container and use it like a pretty normal (in this case Linux)
machine, for example to compile our `tex` files.
Single commands can also be executed.
For example, to compile `cookbook.tex` in PowerShell when the `alexpovel/latex` image
is available after [installing Docker](https://docs.docker.com/docker-for-windows/install/)
and getting the image (`docker pull alexpovel/latex`), run:

```powershell
docker run --rm -v ${PWD}:/docs --workdir /docs alexpovel/latex latexmk
```

Done!
**For this to work, you do not have to have anything installed on your machine, only Docker**.

One concrete workflow to employ this chain is to have a Dockerfile repository on GitHub,
[like this one](https://github.com/alexpovel/latex-extras-docker).
GitHub integrates with [DockerHub](https://hub.docker.com/), the official service provided
by Docker themselves.
It allows users to share images.
As such, there is an image called
[alexpovel/latex](https://hub.docker.com/repository/docker/alexpovel/latex)
on Dockerhub.
This *image* was built using the above GitHub *Dockerfile* and can be downloaded and run,
yielding a live *container*.
On every `git push` (that is, on every change) in the GitHub repo, this image is rebuilt.
Given the size of `TeXLive`, this takes about on hour.

Refer to the
[Dockerfile itself](https://github.com/alexpovel/latex-extras-docker/blob/master/Dockerfile)
(that Dockerfile is used to compile this very README to PDF via `pandoc`)
for more details.

#### Installed packages

For more information on the LaTeX packages mentioned
[in the Dockerfile repository](https://github.com/alexpovel/latex-extras-docker),
refer to the accompanying LaTeX cookbook.

#### Equivalent Windows Install

To get the same, or at least a very similar environment running on Windows,
the elements can be installed individually:

1. [MiKTeX](https://miktex.org/download); for a closer match to the Docker, install
   [TeXLive](https://www.tug.org/texlive/windows.html) instead
2. [Java Runtime Environment](https://www.java.com/en/download/)
3. [InkScape](https://inkscape.org/release)
4. [gnuplot](https://sourceforge.net/projects/gnuplot/files/latest/download)

These are required to compile the LaTeX document.
If InkScape and gnuplot ask to put their respective binaries into the `$PATH`
environment variable, hit yes.
If they do not, add the path yourself to the directory containing the binaries
(`.exe`) in `Edit environment variables for your account -> Path -> Edit... -> New`.

### Enable Runner for the project

To build anything, we need someone to build for us.
GitLab calls these build-servers *runners*.
Such a runner does not materialize out of thin air.
Luckily, in the case of *collaborating.tuhh.de*, runner *tanis* is available to us.
Enable it (him? her?) for the project on the GitLab project homepage:
`Settings -> CI/CD -> Runners -> Enable Shared Runners`.
Otherwise, the build process will get 'stuck' indefinitely.

### Add git info to PDF metadata

After retrieving a built PDF, it might get lost in the nether.
That is, the downloader loses track of what commit it belongs to, or even what release.
This is circumvented by injecting the git SHA into the PDF metadata.
In git, every object is uniquely identified by its hash
([SHA256](https://stackoverflow.com/a/28792805/11477374)):

```text
412ba291b6980ab21f912b5cdf01a13c6268d0ed
```

It is convenient to abbreviate the full SHA to a short version:

```text
412ba291
```

Since a collision of even short hashes is essentially impossible in most use cases,
we can uniquely identify states of the project by this short SHA.
This is why commands like `git show 412ba291` work (try it out; the SHA exists in this repository!).
(As a side note: GitLab picks up on those hashes automatically, as shown in
[commit `ccedcda0`](https://collaborating.tuhh.de/cap7863/gitlab-and-latex-ci-presentation/-/commit/ccedcda05d0dd1bb200126aebdaf241d4ecb695d).)
So if we have this SHA available in the PDF, never again will there be confusion about versions.
The PDF will be be assignable to an exact commit.
It can look like this (in Adobe Reader, evoke file properties with `CTRL + D`):

![git SHA in PDF metadata](images/bitmaps/git_sha_in_pdf_metadata.png)

But how do we get it there?

We have a chicken-and-egg problem:
if we want to insert the *current* SHA into the *current* source files, we can't.
While building the *current* PDF, we can only know the SHA of the *previous* commit.
**But**, fear not, for GitLab has you covered:

During build-time, GitLab provides [*environment variables*](https://docs.gitlab.com/ee/ci/variables/).
These include things like `CI_COMMIT_SHORT_SHA`, which is exactly what we want.
Now, we only need to get the contents of that variable into the LaTeX source,
and finally the compiled PDF.

The LaTeX package `hyperref` can modify PDF metadata.
In the LaTeX preamble, we can then use

```latex
\usepackage[pdfusetitle]{hyperref}% pdfusetitle reads from \author and \title
    \hypersetup{%
        pdfcreator={LaTeX with hyperref (\GitVersion{}, \GitShortHash{})},
    }
```

to get metadata like in the PDF above.
Navigate to the `hyperref` line in the [class file](cookbook.cls) to the see
current implementation.
Note that in LaTeX, you likely used `\author{<author's name>}` and `\title{<document title>}`
somewhere in the preamble to generate a title page.
`hyperref`'s `pdfusetitle` option will use those values for the PDF metadata.
Lastly, `pdfcreator` will fill the `Application` field we see above.
However, `\GitVersion{}` and `\GitShortHash{}}` need to be defined.
These are defined earlier in the preamble:

```latex
\newcommand*{\GitVersion}{n.a.}
\newcommand*{\GitShortHash}{n.a.}
```

(Side note: use the [starred variant of `newcommand`](https://tex.stackexchange.com/a/1057/120853),
unless you need paragraph breaks, which is mostly not the case).

Using the above definition, the fields will just show up as *not available* if for example
compiling locally ("at home").
The server has a script employing `sed` (since we're using GNU/Linux there),
specified in [.gitlab-ci.yml](.gitlab-ci.yml), that seeks `GitVersion` and `GitShortHash`
and replaces whatever comes in the curly braces of those commands.
See the `script` of the `replace_git_metadata` job in that file.

### Add PDF Download Button

On the top of the project page, we can add *badges*.
That's how GitLab calls the small, clickable buttons.
For *real* software developers, these might display code coverage and similar things.
For, well... *us*, they can be used as a convenient way to download the built PDF.
It can look like this (center left):

![Screenshot of the PDF-Download button](images/bitmaps/pdf_download_button_gitlab.png)

A little image (`svg` format) can be generated using [shields.io](https://shields.io/).
That only needs to be done once, and if you want to reuse the existing ones, here they are:

![shields.io Cookbook Download Badge](images/vectors/gitlab/Download-Cookbook-informational.svg)
![shields.io README Download Badge](images/vectors/gitlab/Download-README-critical.svg)
![shields.io PDF Download Badge](images/vectors/gitlab/Download-PDF-success.svg)

They have been embedded directly into the repository to not have to download them
each time.
They could also be embedded via their URL, for example
<https://img.shields.io/badge/Cookbook-Download-informational.svg>.
To add them to the project, go to:
`Settings -> General -> Badges`.
Give it a `Name`, enter the above file path or URL for the `Badge image URL`
(or do whatever you want here), and finally enter the `Link`.
This part is a bit tricky, since we need a dynamic URL that adapts to our path.
For this, GitLab provides variables like `%{project_path}`.
As such, the URL is (the hyphen in the middle is intentional):

```bash
https://collaborating.tuhh.de/%{project_path}/-/jobs/artifacts/%{default_branch}/raw/<filename>.pdf?job=compile_pdf
```

The `project_path` is clear, the `default_branch` is just `master`.
It visits the job artifacts on `master` and gets the `PDF` with the supplied filename.
**This filename has to be adjusted accordingly**.

Note that the download is **unavailable** while a job is running.
To avoid this, work on a git branch and leave `master` alone.
Treat the PDF (or whatever it is) on `master` as the current stable version that only changes sometimes,
not with every commit.
For example, you can do your continuous business on a `dev` branch and then add a second button,

```bash
https://collaborating.tuhh.de/%{project_path}/-/jobs/artifacts/dev/raw/<filename>.pdf?job=compile_pdf
```

# Possible issues and pitfalls

Many nights were lost over issues involving GitLab CI/CD, but also plain LaTeX.
Here is a non-exhaustive list --- a bit like a gallery of failure --- of the most common ones.
Hopefully, it spares you some despair.

- The job is working on `Pulling docker image` [`link to docker image`](.gitlab-ci.yml#L2)
  for a while, and finally fails with

  ```bash
  ERROR: Job failed (system failure): Error response from daemon: No such container <some long container ID>
  ```

  Since, after we ensured the [image](.gitlab-ci.yml#L2) indeed exists, know that cannot be the case,
  we *Retry* the job from the job page's top right corner:

  ![GitLab Job Retry button](images/bitmaps/gitlab_error-job-failed-no-such-container_retry.png)

  It should work afterwards (it never failed to restart after retrying for me).
  This will happen once in a while for some reason, perhaps caching.
  This has been an [active issue](https://gitlab.com/gitlab-org/gitlab-runner/-/issues/4450)
  for over two years now, with (at time of writing) the most recent comment within the last
  24 hours.
  So, it is still in active discussion.
  It seems to have to do with caching.
  There does not seem to be a solution yet.
- When using package [`fontspec`](https://ctan.org/pkg/fontspec)
  (or its derivative [`unicode-math`](https://ctan.org/pkg/unicode-math)),
  compilation fails with

  ```text
  ! error:  (type 2): cannot find file ''
  !  ==> Fatal error occurred, no output PDF file produced!
  ```

  It is possible that the font cache is corrupted after moving fonts around.
  For example, if previously all fonts were in a flat `./fonts/` subdirectory of your
  document root, and then you decide to sort them into `./fonts/sans/` etc., the luatex
  cache will still point to the old ones.

  See [here](https://tex.stackexchange.com/a/311455/120853)
  and also, similarly, [here](https://tex.stackexchange.com/a/453878/120853)
  for a solution:
  delete the `.lua` and `.luc` files of the fonts in question from `luatex-cache/generic/fonts/`.
  For MiKTeX 2.9 on Windows 10, this was found in
  `%USERPROFILE%\AppData\Local\MiKTeX\2.9\luatex-cache`.
- When using package [`pgf-spectra`](https://ctan.org/pkg/pgf-spectra?lang=en)
  compilation fails with

  ```text
  LaTeX Error: File 'spectra.data.tex' not found.
  ```

  For a solution, see
  [here](https://tug.org/pipermail/tex-live/2017-January/039591.html), where it says:

  > Hi
  >
  > texlive/2016/texmf-dist/tex/latex/pgf-spectra/pgf-spectra.sty
  >
  > ends with
  >
  > \\input{spectra.data.tex}
  >
  > which generates a missing file error if the package is used, the data file
  > is on ctan but it's misplaced in texlive as
  >
  > texlive/2016/texmf-dist/doc/latex/pgf-spectra/spectra.data.tex
  >
  > It should be in the tex tree not doc,
  >
  > David

  So, get
  [`spectra.data.tex` from CTAN](http://mirrors.ctan.org/graphics/pgf/contrib/pgf-spectra/spectra.data.tex)
  and place it accordingly.
  This can mean placing it in the project root.
  It would be better to put it next to the package file itself, `pgf-spectra.sty`, but this did not
  work even after refreshing the package database.
  This occurred on MiKTeX 2.9.
  TeXLive seemed fine in version 2019.
- The error is or is similar to:

  ```text
  ! Undefined control sequence.
  l.52 \glsxtr@r
  ```

  With an `*.aux` file mentioned in the error message as well.
  Here, an auxiliary file got corrupted in an unsuccessful run and simply needs to be
  deleted.
  Do this manually or using `latexmk -c`.

# Appendix

## Hints for source files

These are valid not only for LaTeX files, but most text-based source files:

- For the love of God, use `UTF-8` or higher for text encoding.
  Stop using `Windows 1252`, `Latin` etc.
  Existing files can be easily updated to UTF-8 without much danger for regression
  (*i.e.*, introducing errors).
- Put each sentence, or even part of a sentence, and each instruction onto its own line.
  This is very important to `diff` files properly, aka `git diff`.
  Generally, [keep lines short](https://tex.stackexchange.com/q/325505/120853).
- In a similar vein, use indentation appropriately. Indent using **4 spaces**.
  There are schools of thought that advocate two spaces, or also one tab.
  Ultimately, that does not really matter.
  'Four spaces' just seems to generally win the fight for a common coding style,
  bringing us to the next point.
- **Be consistent**. Even if you pull your own custom stuff, at least be consistent in doing so.
  This makes things predictable, the code will be easier to read, and also more easily
  changed programmatically.
  GNU/Linux and by extension Windows using
  [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux)
  has a very wide range of tools that make search, and search-and-replace, and various other
  operations for plain text files easy.
  The same is true for similar tools in IDEs.
  However, if the text is scattered and the style was mangled and fragmented into various
  sub-styles, this becomes very hard.
  For example, one person might use `$<math>$` for inline-LaTeX math, another the
  ([preferred](https://tex.stackexchange.com/q/510/120853)) `\(<math>\)` style.
  Suddenly, you would have to search for both versions to find all inline-math.
  So stay consistent. If you work on pre-existing documents, use the established style.
  If you change it, change it fully, and not just for newly added work.
