# No Docker image available for this yet. Refer to the CI config to configure this for
# local use.
PYTEST = poetry run pytest

ifdef CI
	PYTEST_FLAGS = --verbose
else
	PYTEST_FLAGS =
endif

test-self:  # Runs tests on the tests themselves.
	@$(PYTEST) tests/test_self.py $(PYTEST_FLAGS)

test-pdfs:  # Runs tests on found PDFs.
	@$(PYTEST) tests/test_pdfs.py $(PYTEST_FLAGS)
