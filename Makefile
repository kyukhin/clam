# The commands that decide whether a change is clean. They need macOS, git and the Swift of
# the selected Xcode, and make no network request.
# Spec: docs/specs/E-03-automated-code-review.md, "Commands".

TOOL_PACKAGE := Tools/ClamChecks
# A compiler warning in the tool fails the build, so it fails lint, test-tools and check.
SWIFT_FLAGS := -Xswiftc -warnings-as-errors
# The commands of the check tool that `make lint` runs, one after the other.
CHECKS := whitespace

.PHONY: lint test-tools check

# Runs every check even when one fails, prints every violation and exits with an error if any
# check failed.
lint:
	@swift build --package-path $(TOOL_PACKAGE) $(SWIFT_FLAGS) --product clam-checks
	@bin="$$(swift build --package-path $(TOOL_PACKAGE) $(SWIFT_FLAGS) --show-bin-path)" && \
	status=0 && \
	for check in $(CHECKS); do \
		"$$bin/clam-checks" "$$check" || status=1; \
	done; \
	exit $$status

test-tools:
	@swift test --package-path $(TOOL_PACKAGE) $(SWIFT_FLAGS)

check:
	@swift --version
	@$(MAKE) --no-print-directory lint
	@$(MAKE) --no-print-directory test-tools
