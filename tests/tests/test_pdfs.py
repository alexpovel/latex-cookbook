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

from __future__ import annotations

import math
from datetime import datetime as dt
from decimal import Decimal
from pathlib import Path
from typing import TYPE_CHECKING, Any, Generator, NamedTuple, cast
from warnings import warn

import pymupdf
import pytest
import yaml  # PyYAML
from dateutil.parser import parse as parse_date
from papersize import parse_papersize

from tests.utils import (  # type: ignore[import-untyped]
    PROJECT_ROOT,
    fix_tzoffset,
    parse_duration,
    parse_size,
)

if TYPE_CHECKING:
    from _pytest.fixtures import FixtureRequest


class Rect(NamedTuple):
    width: Decimal
    height: Decimal


def et_project_root_files(suffix: str) -> Generator[Path, None, None]:
    yield from PROJECT_ROOT.glob("*." + suffix)


@pytest.fixture
def config() -> dict[str, Any]:
    with open(PROJECT_ROOT / "tests" / "config.yml") as f:
        return yaml.safe_load(f)


@pytest.fixture(params=et_project_root_files("pdf"))
def pdf(request: FixtureRequest) -> Generator[pymupdf.Document, None, None]:
    doc = pymupdf.open(request.param)
    # Context manager doesn't work, it closes too soon.
    yield doc
    doc.close()


def test_page_numbers(pdf: pymupdf.Document, config: dict[str, Any]) -> None:
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


@pytest.mark.skip(reason="README doesn't have bookmarks, but no one cares.")
def test_bookmarks(pdf: pymupdf.Document, config: dict[str, Any]) -> None:
    """Checks if a table of contents (ToC) is present."""
    bookmarks = config["file"]["bookmarks"]
    not_ = "\b" if bookmarks else "not"  # ASCII backspace, remove on space char
    toc = cast(list[Any], pdf.get_toc())
    assert bool(toc) == bool(
        bookmarks
    ), f"Bookmarks presence {not_} requested, but opposite found."


def test_required_strings(pdf: pymupdf.Document, config: dict[str, Any]) -> None:
    """Tests whether each required text is found in the document."""
    content_config = config["content"]
    required_strings: list[str] = content_config["required_strings"] or []
    for text in required_strings:
        hits = sum(text in page.get_text() for page in pdf)  # type: ignore[operator]
        assert hits, f"Text '{text}' not found in document."


def test_file_size(pdf: pymupdf.Document, config: dict[str, Any]) -> None:
    """Tests that filesize is within limits."""
    file_config = config["file"]
    assert pdf.name is not None
    pdf_path = Path(str(pdf.name))
    size = pdf_path.stat().st_size
    min_size = parse_size(file_config["min_size"]) or 0
    max_size = parse_size(file_config["max_size"]) or math.inf
    assert min_size <= size <= max_size


def test_metadata(pdf: pymupdf.Document, config: dict[str, Any]) -> None:
    """Tests file metadata."""
    meta_config = config["metadata"]

    expectations: dict[str, Any] = {
        # Fields as returned by `pymupdf.Document.metadata`
        "encryption": meta_config["encryption"],
        "format": f"PDF {meta_config['pdf_version']}",
    }

    assert pdf.metadata is not None
    metadata: dict[str, str] = pdf.metadata  # type: ignore[assignment]
    for field, content in metadata.items():
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


def test_freshness(pdf: pymupdf.Document, config: dict[str, Any]) -> None:
    """Tests if file is recently created or stale (e.g. from cache).

    If file was fetched from e.g. a CI cache and not regenerated properly, it's a
    warning sign.

    `pymupdf.Document.metadata` dates look like: "D:20201103155304+01'00'".
    """
    max_age = config["file"]["max_age"]
    if max_age is None:
        pytest.skip("No maximum age set, skipping.")

    max_age = parse_duration(max_age)

    categories = ["mod", "creation"]
    prefix = "D:"  # No idea what it stands for

    assert pdf.metadata is not None
    metadata: dict[str, str] = pdf.metadata  # type: ignore[assignment]
    dates: dict[str, dt] = {}
    for cat in categories:
        date_str = metadata[cat + "Date"]
        date_str = fix_tzoffset(date_str)
        # In Python 3.9, we would use `str.removeprefix`:
        dates[cat] = parse_date(date_str[len(prefix) :])

    assert dates["mod"] == dates["creation"], "Modification and Creation dates differ."
    # From here, both dates are equal, so it doesn't matter which we work with.
    mod_date = dates["mod"]

    now = dt.now()
    try:
        file_age = now - mod_date
    except TypeError:  # can't subtract offset-naive and offset-aware datetimes
        file_age = now.astimezone() - mod_date

    # Multiple asserts per unit test is terrible, but so is this entire thing.
    assert file_age <= max_age, f"File is older than {max_age}"


def test_page_size(pdf: pymupdf.Document, config: dict[str, Any]) -> None:
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

    assert pdf.name is not None
    pdf_name = str(pdf.name)
    try:
        # Allow to either have a single string for 'papersize' that is valid for *all*
        # PDFs, or a mapping of PDF stem names to their allowed sizes. This allows to
        # have mixed page sizes for multiple PDFs.
        size = size.get(Path(pdf_name).stem)
    except AttributeError:
        # Hopefully already a string
        pass

    target = Rect(*parse_papersize(size, unit=unit))
    assert target.height >= target.width  # Not a test, just correctness assertion

    for page in pdf:
        rect = page.cropbox  # cropbox always sets rotation to 0 first

        # Convert width and height floats (unit pt) to string for papersize to parse.
        # This is a stupid move, but ensures we get nice output with the same units and
        # also that both dimension sets are sent through the parser, aka get the same
        # treatment. Any bugs in `papersize` would then cancel out.
        rect_width: float = rect.width  # type: ignore[assignment]
        rect_height: float = rect.height  # type: ignore[assignment]
        actual = Rect(*parse_papersize(f"{rect_width} {rect_height}", unit=unit))
        assert actual.height >= actual.width  # Not a test, just correctness assertion

        for dimension, target_val, actual_val in zip(Rect._fields, target, actual):
            # Due to different ideas of what page sizes are exactly, compare with some
            # tolerance. Otherwise, the various floats would never compare equal.
            is_close = math.isclose(target_val, actual_val, rel_tol=tolerance)
            msg = (
                f"{dimension.capitalize()} mismatch (rel. tol.: {tolerance}):"
                + f" {round(actual_val, n_round)}{unit} found, but"
                + f" {round(target_val, n_round)}{unit} requested."
            )
            assert is_close, msg
