# This file contains instructions for the GNU `make` program: https://www.gnu.org/software/make/
#
# The program is quite old, very stable, ubiquitous and widely used.
# It is a staple in the Linux world.
# There are ways to get it to run on Windows, but I haven't tried any.
# Use WSL (https://docs.microsoft.com/en-us/windows/wsl/install-win10) instead and
# save yourself the headaches.

# `make` runs steps according to this very `Makefile` in order to arrive at a target,
# like a PDF compiled with latex.
# It checks all the dependencies automatically and only updates the target if changes
# in the sources are detected.

# The idea is that this project's PDFs can be compiled by simply calling e.g.
# `make file.pdf` *both locally and in CI*.
# Without make, we would otherwise have very different build steps in local and CI
# environments.
# Additionally, using `make`, the CI instructions (.gitlab-ci.yml, GitHub actions etc.)
# can be simplified considerably, leading to decoupling.
# Moving CI systems then becomes much easier.


# =====================================================================================
# =====================================================================================
# Prerequisites
# =====================================================================================
# =====================================================================================

# The following are "special targets", see:
# https://www.gnu.org/software/make/manual/html_node/Special-Targets.html#Special-Targets
# A phony target: not a file, just some routine.
.PHONY: all clean mostlyclean clean-aux clean-pdf tex preflight help

# =====================================================================================
# Helper tool, adjusted from:
# https://medium.com/@exustash/three-good-practices-for-better-ci-cd-makefiles-5b93452e4cc3
# Allows to annotate targets with regular comments and have a summary printed by calling
# `make help`.
# =====================================================================================

# Note escaping of comment char #
FS = ":.*?\#"

help: # List available targets on this project. First one shown is the default.
	@grep --extended-regexp --no-filename "\w+$(FS) .*" $(MAKEFILE_LIST) | \
		awk --field-separator="$(FS)" '{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# =====================================================================================
# Set variables, executables and their flags.
# =====================================================================================

# Common flags go here:

# Configure latexmk tool using '.latexmkrc' in project root, not in here.
LATEXMK_FLAGS =

# For pandoc, provide dynamic metadata for the date (see below). Git short SHA works
# both in CI and locally. All other settings are in the `defaults` file.
PANDOC_FLAGS = --defaults=pandoc/defaults.yaml

# Flags depending on CI/Local go here:

# GitLab CI defines variables that we can check for. This allows us to detect if we're
# in a CI scenario.
# See also:
# https://www.gnu.org/software/make/manual/html_node/Conditional-Syntax.html#Conditional-Syntax
# https://docs.gitlab.com/ee/ci/variables/predefined_variables.html
#
# That same environment variable is defined for GitHub Actions as well:
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
ifdef CI
	# In container, run commands directly:
	LATEXMK = latexmk
	PANDOC = pandoc
	#
	GIT_SHORT_SHA = $$CI_COMMIT_SHORT_SHA
	# pandoc is quiet by default
	PANDOC_FLAGS += --verbose
	# After the run, display the relevant rules (for debugging)
	LATEXMK_FLAGS += --rules
else
	DOCKER_RUN = docker run --rm --volume ${PWD}:/tex
	DOCKER_IMAGE = alexpovel/latex
	#
	LATEXMK = $(DOCKER_RUN) --entrypoint="latexmk" $(DOCKER_IMAGE)
	PANDOC = $(DOCKER_RUN) --entrypoint="pandoc" $(DOCKER_IMAGE)
	# No supporting Docker image available yet:
	GIT_SHORT_SHA = $(shell git rev-parse --short HEAD)
	# latexmk is verbose by default:
	LATEXMK_FLAGS += --quiet
endif

PANDOC_FLAGS += --metadata=date:"$(shell date --iso-8601) ($(GIT_SHORT_SHA))"

# =====================================================================================
# =====================================================================================
# Files to build
# =====================================================================================
# =====================================================================================

# Produce all found tex files.
tex_sources = $(wildcard *.tex)
tex_pdfs := $(tex_sources:.tex=.pdf)

# First rule is what is run by default if just using `make` with no arguments.
# It is the 'goal': https://www.gnu.org/software/make/manual/html_node/Goals.html.
# The name `all` is just a convention.
# Change suffix of multiple different extensions (.tex, .md), to the same suffix (.pdf).
# See also: https://stackoverflow.com/a/33926814
all: preflight tex README.pdf test  # Performs preflight checks, then builds and tests all PDFs.
# A rule for only LaTeX files:
tex: $(tex_pdfs)  # Builds all *.tex files into PDFs.

# =====================================================================================
# Rules for file building
# =====================================================================================

# This Makefile uses implicit rules, see:
# https://www.gnu.org/software/make/manual/html_node/Implicit-Rules.html#Implicit-Rules
# For those, Automatic Variables are important:
# https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
# $*: "The stem with which an implicit rule matches"
# $<: "The name of the first prerequisite"
# $@: "The file name of the target of the rule"
# $^: "The names of all the prerequisites, with spaces between them"

# Pattern rule, see:
# https://www.gnu.org/software/make/manual/html_node/Pattern-Rules.html,
# Just sets up an implicit rule to specify how to get from prerequisite to target,
# called whever `make` detects it needs to do so. No need to specify things manually.
%.pdf: %.tex  # Allows to build any PDF from a corresponding *.tex file.
	$(info Running $(LATEXMK) to build $@...)
	@$(LATEXMK) $(LATEXMK_FLAGS) $<

PANDOC_TEMPLATE = $(strip $(shell grep "^template:" pandoc/defaults.yaml | cut --delimiter=":" --field=2)).latex
PANDOC_TEMPLATE_DIR = ~/.pandoc/templates

%.pdf: %.md $(PANDOC_TEMPLATE_DIR)/$(PANDOC_TEMPLATE)  # Allows to build any PDF from a corresponding *.md file.
	$(info Running $(PANDOC) to build $@...)
	@$(PANDOC) $(PANDOC_FLAGS) --output=$@ $<

EISVOGEL_ARCHIVE = Eisvogel.tar.gz

# The `$(info ...)` function gives out-of-order logging, while `echo` works with the
# `wget` progress display.
$(PANDOC_TEMPLATE_DIR)/$(PANDOC_TEMPLATE):
	@echo "Template not found at $@, downloading..."
	@wget --quiet --show-progress --no-clobber \
		"https://github.com/Wandmalfarbe/pandoc-latex-template/releases/latest/download/${EISVOGEL_ARCHIVE}"
	@echo "Extracting $(EISVOGEL_ARCHIVE)..."
	@tar --extract --file=${EISVOGEL_ARCHIVE} eisvogel.latex
# `$(@D)` is directory part of current target:
	@mkdir --parents $(@D)
	@mv eisvogel.latex $@
	@$(RM) $(EISVOGEL_ARCHIVE)

# =====================================================================================
# Help users install programs required for compilation and help debug.
# =====================================================================================
preflight:  # Performs checks to ensure prerequisites for compilation are met.
	@echo "Checking presence of required libraries..."
	@ldconfig --print-cache | grep --silent "librsvg" || \
		(echo "librsvg missing: required by pandoc to convert files containing SVGs."; exit 69)
	@echo "Libraries OK."
# Output looks like: https://tex.stackexchange.com/a/311753/120853
	@$(LATEXMK) --commands

# =====================================================================================
# Testing.
# =====================================================================================

include tests/Makefile

# =====================================================================================
# Cleanup jobs.
# =====================================================================================
clean-aux:  # Cleans LaTeX's auxiliary files.
	@echo "Removing auxiliary files of all found TeX files..."
	@$(LATEXMK) -c $(LATEXMK_FLAGS)

clean-pdf:  # Cleans all found PDFs.
	@echo "Removing all PDF files:"
	@ls *.pdf 2>/dev/null || echo "No files to remove."
	@$(RM) *.pdf

# For target name, see: https://www.gnu.org/prep/standards/html_node/Standard-Targets.html
mostlyclean: clean-aux clean-pdf  # Runs clean-{aux,pdf}, then cleans more.
	@echo "Removing downloaded pandoc archive, if any..."
	@$(RM) $(EISVOGEL_ARCHIVE)

clean: mostlyclean  # Runs all other clean jobs, then cleans absolutely everything.
	@echo "Removing all files ignored by git (.gitignore)..."
	@echo "For safety, this is done interactively:"
	@git clean -xd --interactive
	@echo "Removing pandoc template..."
	@$(RM) $(PANDOC_TEMPLATE_DIR)/$(PANDOC_TEMPLATE)
