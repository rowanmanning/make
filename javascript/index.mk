
# Meta tasks
# ----------

.PHONY: test


# Configuration
# -------------

# Set up the npm binary path
NPM_BIN = ./node_modules/.bin
export PATH := $(PATH):$(NPM_BIN)


# Output helpers
# --------------

TASK_DONE = echo "✓ $@ done"


# Group tasks
# -----------

all: install ci
ci: verify test


# Install tasks
# -------------

# Clean the Git repository
clean:
	@git clean -fxd
	@$(TASK_DONE)

# Install dependencies
install: node_modules
	@$(TASK_DONE)

# Run npm install if package.json has changed more
# recently than node_modules
node_modules: package.json
	@npm prune --production=false
	@npm install
	@$(TASK_DONE)


# Verify tasks
# ------------

# Default configurations for code coverage
export EXPECTED_COVERAGE := 90

# Run all of the verify tasks
verify: verify-javascript verify-dust
	@$(TASK_DONE)

# Run all of the JavaScript verification tasks
verify-javascript: verify-eslint verify-jshint verify-jscs
	@$(TASK_DONE)

# Run dustmite against the codebase if a .dustmiterc
# file exists in the repo
verify-dust:
	@if [ -e .dustmiterc* ]; then dustmite --path ./view && $(TASK_DONE); fi

# Run eslint against the codebase if an .eslintrc
# file exists in the repo
verify-eslint:
	@if [ -e .eslintrc* ]; then eslint . && $(TASK_DONE); fi

# Run jshint against the codebase if a .jshintrc
# file exists in the repo
verify-jshint:
	@if [ -e .jshintrc* ]; then jshint . && $(TASK_DONE); fi

# Run jscs against the codebase if a .jscsrc
# file exists in the repo
verify-jscs:
	@if [ -e .jscsrc* ]; then jscs . && $(TASK_DONE); fi

# Verify that code coverage meets the expected percentage with nyc
verify-coverage:
	@if [ -d coverage ]; then \
		if [ -x $(NPM_BIN)/nyc ]; then \
			nyc check-coverage --lines $(EXPECTED_COVERAGE) --functions $(EXPECTED_COVERAGE) --branches $(EXPECTED_COVERAGE) && $(TASK_DONE); \
		fi \
	fi


# Test tasks
# ----------

# Default configurations for integration tests
export INTEGRATION_TIMEOUT := 5000
export INTEGRATION_SLOW := 4000

# Mocha command
UNIT_TEST_FLAGS = "test/unit/**/*.test.js" --recursive $(UNIT_TEST_EXTRA_FLAGS)

# Run all of the test tasks and verify coverage
test: test-unit-coverage verify-coverage test-integration
	@$(TASK_DONE)

# Run the unit tests using mocha
test-unit:
	@if [ -d test/unit ]; then make _test-unit-run && $(TASK_DONE); fi
_test-unit-run:
	@if [ -x $(NPM_BIN)/mocha ]; then make _test-unit-run-mocha; fi
_test-unit-run-mocha:
	@mocha $(UNIT_TEST_FLAGS)

# Run the unit tests using mocha, and
# generating a coverage report
test-unit-coverage:
	@if [ -d test/unit ]; then make _test-unit-coverage-run && $(TASK_DONE); fi
_test-unit-coverage-run:
	@if [ -x $(NPM_BIN)/mocha ] && [ -x $(NPM_BIN)/nyc ]; then \
		make _test-unit-coverage-run-mocha-nyc; \
	else \
		make test-unit; \
	fi
_test-unit-coverage-run-mocha-nyc:
	@nyc --reporter=text --reporter=html $(NPM_BIN)/_mocha $(UNIT_TEST_FLAGS)

# Run the integration tests using mocha
test-integration:
	@if [ -d test/integration ]; then make _test-integration-run && $(TASK_DONE); fi
_test-integration-run:
	@if [ -x $(NPM_BIN)/mocha ]; then make _test-integration-run-mocha; fi
_test-integration-run-mocha:
	@mocha "test/integration/**/*.test.js" --recursive --timeout $(INTEGRATION_TIMEOUT) --slow $(INTEGRATION_SLOW) $(INTEGRATION_TEST_MOCHA_FLAGS)


# Publish tasks (CI only)
# -----------------------

# Get the NPM publish tag
ifeq ($(NPM_PUBLISH_TAG),)
NPM_PUBLISH_TAG = $(CIRCLE_TAG)
endif
ifeq ($(NPM_PUBLISH_TAG),)
NPM_PUBLISH_TAG = $(TRAVIS_TAG)
endif

# Publish the project to npm
publish-npm: npm-set-auth-token npm-set-package-version
ifneq ($(NPM_PUBLISH_TAG),)
	@npm publish --access public
	@$(TASK_DONE)
endif

npm-set-package-version:
	@npm version --no-git-tag-version $(NPM_PUBLISH_TAG)
	@$(TASK_DONE)

npm-set-auth-token:
	@if [ ! -f $(HOME)/.npmrc ]; then \
		echo "//registry.npmjs.org/:_authToken=$(NPM_AUTH_TOKEN)" > $(HOME)/.npmrc; \
	fi
	@$(TASK_DONE)
