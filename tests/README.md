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

Run

```bash
python -m venv .venv
. .venv/bin/activate
pip install .
```

in the directory containing [pyproject.toml](./pyproject.toml).

## Running

After the setup, you can simply run:

```bash
pytest
```

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

## Side note

Sadly, an inherent issue is that [PDF parsing/text extraction](https://news.ycombinator.com/item?id=22473263)
is incredibly hard.
Visually, PDFs might look fine to human eyes, but trying to tell a computer, in an
automated fashion, what *it* sees and have it parse that correctly is as of today
basically impossible.
