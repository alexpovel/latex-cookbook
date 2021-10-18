"""Tests whether PDFs documents fulfill certain criteria.

This is a bit backwards: `pytest` ordinarily tests functions/units, with sample data
being generated as needed. This module tests *data*, not the logic working on them.
For this, a package like `datatest` is maybe more suitable. However, the framework
provided by `pytest` works just fine. It gets us pretty summaries and the like, much
better than crafting that ourselves.
One core downside is that there is way too much logic in the tests themselves, with
no way of testing the tests that test the data. If these are wrong (likelihood increases
with more complexity), we are in for a bad time.

Idea from: https://blog.martisak.se/2020/05/16/latex-test-cases/
"""

import math
from collections import namedtuple
from datetime import datetime as dt
from itertools import compress
from pathlib import Path
from typing import List
from warnings import warn

import fitz  # PyMuPDF
import pytest
import yaml  # PyYAML
from dateutil.parser import parse as parse_date
from papersize import parse_papersize
from profanity_check import predict

from tests.utils import (
    fix_tzoffset,
    parse_duration,
    parse_size,
    _PROJECT_ROOT,
)

# Monkey-patch a new, prettier property to access a page's text, instead of calling the
# camelCase method. PEP-8 for the win.
fitz.Page.text = property(lambda self: self.getText())
fitz.Document.toc = property(lambda self: self.getToC())

Rect = namedtuple("Rect", ["width", "height"])


def get_project_root_files(suffix: str) -> List[Path]:
    yield from _PROJECT_ROOT.glob("*." + suffix)


@pytest.fixture
def config():
    with open(_PROJECT_ROOT / "tests" / "config.yml") as f:
        return yaml.safe_load(f)


@pytest.fixture(params=get_project_root_files("pdf"))
def pdf(request):  # HAS to be named 'request'
    doc = fitz.open(request.param)
    # Context manager doesn't work, it closes too soon.
    yield doc
    doc.close()


def test_profanity(pdf, config):
    if config["content"]["profanity_allowed"]:
        pytest.skip("Profanity is allowed, ignoring test.")
    for page in pdf:
        lines = page.text.splitlines()
        if lines:
            predictions = predict(lines)  # exception raised if argument empty
            # Compressing loses information on line number. Not too bad because that is
            # imprecise anyway, page number should be enough.
            # Cast to list because iterator evaluates to True even if empty.
            profanities = list(compress(lines, predictions))
            assert (
                not profanities
            ), f"Profanities {profanities} found on page {page.number + 1}!"


def test_page_numbers(pdf, config):
    """Tests that number of pages is within limits.

    Zero-length PDFs don't exist, but perhaps some form of file corruption could produce
    them.
    """
    n = len(pdf)

    page_config = config["pages"]
    n_min = page_config["n_min"] or 1
    n_max = page_config["n_max"] or math.inf

    msg = (
        f"Document page count out of bounds: {n} pages not within {n_min} and {n_max}."
    )
    assert n_min <= n <= n_max, msg


@pytest.mark.skip(
    reason="README doesn't have bookmarks, but no one cares."
)
def test_bookmarks(pdf, config):
    """Checks if a table of contents (ToC) is present."""
    bookmarks = config["file"]["bookmarks"]
    not_ = "\b" if bookmarks else "not"  # ASCII backspace, remove on space char
    assert bool(pdf.toc) == bool(
        bookmarks
    ), f"Bookmarks presence {not_} requested, but opposite found."


def test_required_strings(pdf, config):
    """Tests whether each required text is found in the document."""
    content_config = config["content"]
    for text in content_config["required_strings"] or []:
        hits = sum(text in page.text for page in pdf)
        assert hits, f"Text '{text}' not found in document."


def test_file_size(pdf, config):
    """Tests that filesize is within limits."""
    file_config = config["file"]
    size = Path(pdf.name).stat().st_size
    min_size = parse_size(file_config["min_size"]) or 0
    max_size = parse_size(file_config["max_size"]) or math.inf
    assert min_size <= size <= max_size


def test_metadata(pdf, config):
    """Tests file metadata."""
    meta_config = config["metadata"]

    expectations = {  # Fields as returned by `fitz.Document.metadata`
        "encryption": meta_config["encryption"],
        "format": f"PDF {meta_config['pdf_version']}",
    }

    for field, content in pdf.metadata.items():
        try:
            expectation = expectations[field]
        except KeyError:
            # Couldn't get successfully, no expected value present. However, the
            # user might still want to be warned about empty metadata fields.
            if not content:
                warn(f"File metadata field '{field}' is empty.")
        else:
            msg = f"Field '{field}' is '{content}', not '{expectation}'."
            assert content == expectation, msg


def test_freshness(pdf, config):
    """Tests if file is recently created or stale (e.g. from cache).

    If file was fetched from e.g. a CI cache and not regenerated properly, it's a
    warning sign.

    `fitz.Document.metadata` dates look like: "D:20201103155304+01'00'".
    """
    max_age = config["file"]["max_age"]
    if max_age is None:
        pytest.skip("No maximum age set, skipping.")

    max_age = parse_duration(max_age)

    categories = ["mod", "creation"]
    prefix = "D:"  # No idea what it stands for

    dates = {}
    for cat in categories:
        date = pdf.metadata[cat + "Date"]
        date = fix_tzoffset(date)
        # In Python 3.9, we would use `str.removeprefix`:
        dates[cat] = parse_date(date[len(prefix) :])

    assert dates["mod"] == dates["creation"], f"Modification and Creation dates differ."
    # From here, both dates are equal, so it doesn't matter which we work with.
    date = dates["mod"]

    now = dt.now()
    try:
        file_age = now - date
    except TypeError:  # can't subtract offset-naive and offset-aware datetimes
        file_age = now.astimezone() - date

    # Multiple asserts per unit test is terrible, but so is this entire thing.
    assert file_age <= max_age, f"File is older than {max_age}"


def test_page_size(pdf, config):
    """Tests if all pages sizes are within allowed bounds.

    We require some rounding black-magic, since page dimensions in pt deviate between
    official definitions and what the used packages return from the metadata.
    """
    size = config["pages"]["papersize"]
    if size is None:
        pytest.skip("No page size specified, skipping.")

    unit = "cm"  # Cast to same unit for comparison
    tolerance = 0.01  # Tolerance for value comparison

    # When rounding for display, round roughly according to the actual tolerance we
    # compare at. This is probably buggy as hell.
    n_round = abs(round(math.log(tolerance, 10)))

    try:
        # Allow to either have a single string for 'papersize' that is valid for *all*
        # PDFs, or a mapping of PDF stem names to their allowed sizes. This allows to
        # have mixed page sizes for multiple PDFs.
        size = size.get(Path(pdf.name).stem)
    except AttributeError:
        # Hopefully already a string
        pass

    target = Rect(*parse_papersize(size, unit=unit))
    assert target.height >= target.width  # Not a test, just correctness assertion

    for page in pdf:
        rect = page.CropBox  # CropBox always sets rotation to 0 first

        # Convert width and height floats (unit pt) to string for papersize to parse.
        # This is a stupid move, but ensures we get nice output with the same units and
        # also that both dimension sets are sent through the parser, aka get the same
        # treatment. Any bugs in `papersize` would then cancel out.
        actual = Rect(*parse_papersize(f"{rect.width} {rect.height}", unit=unit))
        assert actual.height >= actual.width  # Not a test, just correctness assertion

        for dimension, t, f in zip(Rect._fields, target, actual):
            # Due to different ideas of what page sizes are exactly, compare with some
            # tolerance. Otherwise, the various floats would never compare equal.
            is_close = math.isclose(t, f, rel_tol=tolerance)
            msg = (
                f"{dimension.capitalize()} mismatch (rel. tol.: {tolerance}):"
                + f" {round(f, n_round)}{unit} found, but"
                + f" {round(t, n_round)}{unit} requested."
            )
            assert is_close, msg
