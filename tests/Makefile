# Get this file's directory, allows this Makefile to be run on its own or via
# `include` from a root Makefile. From:
# https://www.systutorials.com/how-to-get-a-makefiles-directory-for-including-other-makefiles/
SELF_DIR = $(dir $(lastword $(MAKEFILE_LIST)))

# No Docker image available for this yet. Refer to the CI config to configure this for
# local use.
TEST = poetry run pytest
TESTS_DIR = tests

.PHONY: test test-self test-pdfs

define run_test
	cd $(SELF_DIR) && \
		$(TEST) $(TESTS_DIR)/$(subst -,_,$(1)).py $(TEST_FLAGS)
endef

ifdef CI
	TEST_FLAGS = --verbose
else
	TEST_FLAGS =
endif

test: test-self test-pdfs # Runs all tests.
	@echo "All tests passed."

# Target names correspond to actual Python test files, with some modifications made, see
# the `run_test` function.

test-self:  # Runs tests on the tests themselves.
	@$(call run_test,$@)

test-pdfs:  # Runs tests on found PDFs.
	@$(call run_test,$@)
