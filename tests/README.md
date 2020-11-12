# Automated Testing

This sub-project contains Python-based code for testing the PDF output produced by
earlier CI stages, or by you locally.

The desired properties of the PDFs under test (by default, all PDFs in the project root),
are configured in the [tests config file](config.yml).
Once that is done to your liking, [set up the testing framework](#setup) and [run](#running)
the tests (or don't and use CI instead, where everything is done for you already and
Just Works™).

This is helpful to check for basic stuff.
A more involved approach is shown [here](https://blog.martisak.se/2020/05/16/latex-test-cases/).
This includes checking for publisher-specific requirements, allowing us to detect errors
and iterate much faster.

## Setup

There are two steps to this.
This is unfortunately not as easy as it could be, owed to the nature of Python's
ecosystem.

### Python dependencies

The project uses [poetry](https://python-poetry.org/docs/#installation) for dependency
management.
Once you have it installed according to their documentation, it is very easy to pull in
the dependencies of this project.
In the directory containing [the `poetry` config file](pyproject.toml), run

```bash
poetry install
```

This will pull the precise requirements needed from the [lock file](poetry.lock).
Otherwise, it uses the config file.
That's it... almost.

### Python itself

You will also need a suitable Python interpreter, aka Python version.
This is "Python itself".
If your system's Python *is* compatible with what is listed in the [config](pyproject.toml),
you do not need to do anything.
The easiest way to test this is to just run:

```bash
poetry run pytest
```

and see if it fails.
If it does, `poetry` will complain to you accordingly.
In such a case, [`pyenv`](https://github.com/pyenv/pyenv) has worked well for me to set
up a suitable, local or system-wide Python interpreter of *any* desired version.

The [setup for the CI pipeline](../.gitlab-ci.yml) is quite different.
Take a look if you like, but the steps there are not applicable to local usage.

## Running

After the setup, you can simply run:

```bash
poetry run pytest
```

Prepending everything with `poetry run` will make sure all commands run in the suitable
[virtual environment](https://docs.python.org/3/tutorial/venv.html) with the correct
packages installed in the correct versions, as well as using the Python version set up
using `pyenv`, if any.

Any sub-commands or flags after `pytest` are courtesy of `pytest`, not `poetry`.
There, you can for example specify which tests to run.

### Makefile

Otherwise, the testing procedure is tucked away and made accessible via the [Makefile](Makefile).
It requires you to have [GNU `make`](https://www.gnu.org/software/make/) installed.
If you are on Linux you might already have it, since a lot of development workflows rely
on it.
The tests can then be run using:

```bash
make test
```

or any of the other *targets* in that Makefile:

```bash
make test-self
make test-pdfs
```

## Troubleshooting

- This project uses [`profanity-check`](https://pypi.org/project/profanity-check/).
  For now, mainly just for fun, but perhaps it can be useful in the future.
  That package makes heavy use of *ARTIFICIAL INTELLIGENCE™*.
  As a result, it seems to be more sensitive about what dependencies it requires.
  Due to [this issue](https://github.com/vzhou842/profanity-check/issues/15), this
  project is using Python 3.7 for the time being.

### Side note

Sadly, an inherent issue is that [PDF parsing/text extraction](https://news.ycombinator.com/item?id=22473263)
is incredibly hard.
Visually, PDFs might look fine to human eyes, but trying to tell a computer, in an
automated fashion, what *it* sees and have it parse that correctly is as of today
basically impossible.

This is also the reason for the hardship of converting back and forth between document
formats.
Converting *to* PDF works beautifully all the time.
It is the way to go (please stop emailing Word documents for simple, to-be-read-only
documents: use PDF).
However, trying to read a PDF into Word will break a lot of the content.
This is true even for the most modern tools like Office 2019 with an Acrobat Pro 2020
"backend", where there's arguably a *lot* of genuine business demand (and therefore, $$)
for such a feature.
Still, no dice yet.
