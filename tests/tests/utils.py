import datetime
import logging
import re
import string
from pathlib import Path

_THIS_DIR = Path(__file__).parent

# `resolve` gets rid of ".." representation, important for `relative_to` to work.
_PROJECT_ROOT = (_THIS_DIR / ".." / "..").resolve()


def parse_size(size: str) -> int:
    """Parses a string file size (e.g. "32G") into a bytes number.

    Works on the basis of 1000 steps, so not 1024. Probably wrong for that reason.

    Args:
        size: A human-readable file size, e.g. "32G", "10M". That is, without the "B"
            for "Bytes".

    Returns:
        Number of bytes for that file size.
    """
    si_prefixes = ["B", "K", "M", "G", "T", "P", "E"]

    try:
        size = size.strip()
    except AttributeError:
        # Not a string, can't work with this, return this filth to the offender
        return size

    n = float(re.match(r"\d+(\.\d+)?", size).group())
    for i, prefix in enumerate(si_prefixes):
        if re.search(prefix, size, re.IGNORECASE):
            factor = 10 ** (i * 3)
            break
    else:  # nobreak
        logging.info(f"No unit prefix found in '{size}', interpreting as bytes.")
        factor = 1
    return int(factor * n)


def fix_tzoffset(date: str) -> str:
    """Fixes malformed timezone info in a string, without parsing it further.

    The dates returned by `fitz.Document.metadata` have timezone information in the
    form "±HH'MM'", i.e. with extra apostrophes. These will be filtered out so that the
    resulting string can be parsed correctly by `datetime`'s `%z`, or automatically by
    `dateutil`. The latter fails for the malformed timezone returned by
    `fitz.Document.metadata`.

    The return of this function is designed to be fed into `dateutil.parser.parse`.

    Args:
        date: A date string to be parsed, with potentially malformed timezone
            information.

    Returns:
        Input date with all disallowed characters removed from the timezone info.
    """

    def clean(match: re.Match) -> str:
        """Rebuilds match string to only contain allowed characters.

        See also: https://docs.python.org/3/library/re.html#re.sub
        """
        allowed = string.digits + "."
        return "".join(char for char in match.group() if char in allowed)

    # Positive lookbehind: match only if *preceded* by that regex, however that regex
    # will not be part of the match. This allows us to clean just the timezone info
    # w/o having to deal w/ the ±.
    return re.sub(r"(?<=[+-]).+", clean, date)


def parse_duration(duration: str) -> datetime.timedelta:
    """Parses a human-readable duration like "1d5h30m"

    Credit: https://gist.github.com/santiagobasulto/698f0ff660968200f873a2f9d1c4113c

    Args:
        duration: The human-readable string.

    Returns:
        A proper, parsed object to work with.
    """
    duration = re.sub(r"\s+", "", duration)  # Remove any whitespace
    pattern = re.compile(
        # Order here matters:
        r"((?P<days>-?\d+)d)?"
        + r"((?P<hours>-?\d+)h)?"
        + r"((?P<minutes>-?\d+)m)?"
        + r"((?P<seconds>-?\d+)s)?",
        re.IGNORECASE | re.VERBOSE,
    )
    match = pattern.match(duration)
    # Check if any match *content*, not just match object. All capture groups are
    # optional, so *any* string can match. See:
    # https://gist.github.com/santiagobasulto/698f0ff660968200f873a2f9d1c4113c#gistcomment-3518604
    if match.group():
        parts = {k: int(v) for k, v in match.groupdict().items() if v}
        return datetime.timedelta(**parts)
