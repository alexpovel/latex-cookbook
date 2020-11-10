from tests.utils import parse_size, fix_tzoffset, parse_duration
from datetime import timedelta as td
import pytest


@pytest.mark.parametrize(
    ["size", "n"],
    [
        ("0", 0),
        ("0.0000", 0),
        ("00000.0000", 0),
        ("  0  ", 0),
        ("  0  B", 0),
        ("0.1", 0),
        ("0.5", 0),
        ("0.0009K", 0),
        ("0.0009k", 0),
        ("0.009K", 9),
        ("1", 1),
        ("01", 1),
        ("1.0", 1),
        ("00022", 22),
        ("105", 105),
        ("106B", 106),
        ("0000106B", 106),
        ("769B", 769),
        ("12.234K", 12234),
        ("12.2349K", 12234),
        ("0.000009G", 9_000),
        ("497K", 497_000),
        ("0.3G", 300_000_000),
        ("554M", 554_000_000),
        ("155G", 155_000_000_000),
        ("664G", 664_000_000_000),
        ("864G", 864_000_000_000),
        ("155.3G", 155_300_000_000),
        ("853T", 853_000_000_000_000),
        ("999P", 999_000_000_000_000_000),
        ("100E", 100_000_000_000_000_000_000),
        # Case insensitive
        ("1b", 1),
        ("1k", 1_000),
        ("1m", 1_000_000),
        ("1g", 1_000_000_000),
        ("1t", 1_000_000_000_000),
        ("1p", 1_000_000_000_000_000),
        ("1e", 1_000_000_000_000_000_000),
    ],
)
def test_parse_size(size, n):
    assert parse_size(size) == n


@pytest.mark.parametrize(
    ["raw_date", "date"],
    [
        # Unchanged:
        # No timezone info:
        ("D:20201103155304", "D:20201103155304"),
        #
        ("D:20201103155304+1000", "D:20201103155304+1000"),
        ("D:20201103155304-1000", "D:20201103155304-1000"),
        # Examples for %z from
        # https://docs.python.org/3/library/datetime.html#tzinfo-objects
        ("D:20201103155304+063415", "D:20201103155304+063415"),
        ("D:20201103155304+1030", "D:20201103155304+1030"),
        ("D:20201103155304-0400", "D:20201103155304-0400"),
        ("D:20201103155304-0000", "D:20201103155304-0000"),
        ("D:20201103155304+0000", "D:20201103155304+0000"),
        # Changed due to malformed tzinfo:
        ("D:20201103155304+01'00'", "D:20201103155304+0100"),
        ("D:20201103155304-01'00'", "D:20201103155304-0100"),
        ("D:20201103155304-11'11'", "D:20201103155304-1111"),
        ("D:20201103155304+10-10", "D:20201103155304+1010"),
        ("D:20201103155304+10-10.347289", "D:20201103155304+1010.347289"),
        ("D:20201103155304+01foifre00shfs", "D:20201103155304+0100"),
    ],
)
def test_fix_tzoffset(raw_date, date):
    assert fix_tzoffset(raw_date) == date


@pytest.mark.parametrize(
    ["raw_duration", "duration"],
    [
        ("", None),
        ("    ", None),
        ("Shouldnt match", None),
        ("???", None),
        # Since words start with the actual short letters (duh!), this works:
        ("1 day", td(days=1)),
        ("1 hour", td(hours=1)),
        ("1 minute", td(minutes=1)),
        ("1 second", td(seconds=1)),
        # But they cannot be combined:
        ("1 day 1 hour 1 minute 1 second", td(days=1)),
        ("10 hours 100 second", td(hours=10)),
        ("10 hours DOESNT MATTER", td(hours=10)),
        ("10 h DOESNT MATTER", td(hours=10)),
        #
        ("1 hour", td(hours=1)),
        ("1 minute", td(minutes=1)),
        ("1 second", td(seconds=1)),
        # It also means these work:
        ("1 durr", td(days=1)),
        ("1 hurr", td(hours=1)),
        ("1 mailbox", td(minutes=1)),
        ("1 sand", td(seconds=1)),
        # Zero
        ("0d", td(minutes=0, hours=0, days=0)),
        ("0h", td(minutes=0, hours=0, days=0)),
        ("0m", td(minutes=0, hours=0, days=0)),
        ("0d0m", td(minutes=0, hours=0, days=0)),
        ("0d0h", td(minutes=0, hours=0, days=0)),
        ("0m0h", td(minutes=0, hours=0, days=0)),
        ("0d0h0m", td(minutes=0, hours=0, days=0)),
        # Whitespace
        ("1d 1h 1m", td(minutes=1, hours=1, days=1)),
        (" 1d 1h 1m ", td(minutes=1, hours=1, days=1)),
        ("     1d     1h     1m ", td(minutes=1, hours=1, days=1)),
        ("\t1d\t1h\t1m", td(minutes=1, hours=1, days=1)),
        ("1d1h1m", td(minutes=1, hours=1, days=1)),
        # Negative
        ("-1d-1h-1m-1s", td(seconds=-1, minutes=-1, hours=-1, days=-1)),
        # We would write "1 day, 6 hours", but there is not limit:
        ("30h", td(hours=30)),
        ("300h", td(hours=300)),
        ("300m", td(minutes=300)),
        ("300s", td(seconds=300)),
        #
        ("-30h", td(hours=-30)),
        ("-300h", td(hours=-300)),
        ("-300m", td(minutes=-300)),
        ("-300s", td(seconds=-300)),
        # See: https://gist.github.com/santiagobasulto/698f0ff660968200f873a2f9d1c4113c#file-tests-py
        ("3d", td(days=3)),
        ("-3d", td(days=-3)),
        ("-37D", td(days=-37)),
        ("18h", td(hours=18)),
        ("-5h", td(hours=-5)),
        ("11H", td(hours=11)),
        ("129m", td(minutes=129)),
        ("-68m", td(minutes=-68)),
        ("12M", td(minutes=12)),
        ("3d5h", td(days=3, hours=5)),
        ("-3d-5h", td(days=-3, hours=-5)),
        ("13d4h19m", td(days=13, hours=4, minutes=19)),
        ("13d19m", td(days=13, minutes=19)),
        ("-13d-19m", td(days=-13, minutes=-19)),
        ("-13d19m", td(days=-13, minutes=19)),
        ("13d-19m", td(days=13, minutes=-19)),
        ("4h19m", td(hours=4, minutes=19)),
        ("-4h-19m", td(hours=-4, minutes=-19)),
        ("-4h19m", td(hours=-4, minutes=19)),
        ("4h-19m", td(hours=4, minutes=-19)),
    ],
)
def test_parse_duration(raw_duration, duration):
    assert parse_duration(raw_duration) == duration
