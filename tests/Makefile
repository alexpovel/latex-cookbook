# No Docker image available for this yet. Refer to the CI config to configure this for
# local use.
TEST = poetry run pytest

ifdef CI
	TEST_FLAGS = --verbose
else
	TEST_FLAGS =
endif

test-self:  # Runs tests on the tests themselves.
	@$(TEST) tests/test_self.py $(TEST_FLAGS)

test-pdfs:  # Runs tests on found PDFs.
	@$(TEST) tests/test_pdfs.py $(TEST_FLAGS)
