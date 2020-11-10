"""File to configure pytest, e.g. to implement hooks.
See also: https://stackoverflow.com/q/34466027/11477374
List of hooks: https://pytest.org/en/latest/reference.html#hook-reference
"""

from tests.utils import _PROJECT_ROOT


def pytest_make_parametrize_id(config, val, argname):
    """Provide IDs aka names for test cases.
    pytest generates automatic IDs. Using this function, they can be altered to
    whatever more legible representation, see
    https://doc.pytest.org/en/latest/example/parametrize.html#different-options-for-test-ids.
    Implementing this function in a specific file using a specific name will hook it
    into pytest and use it for *all* ID generation automatically, so no need to specify
    `ids=<func>` all the time.
    Demo: https://raphael.codes/blog/ids-for-pytest-fixtures-and-parametrize/
    """
    try:
        # Shorten filepath significantly, in relation to project root.
        val = val.relative_to(_PROJECT_ROOT)
    except AttributeError:
        pass
    return str(val)
