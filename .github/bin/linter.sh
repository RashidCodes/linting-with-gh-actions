#!/usr/bin/env bash
set -eu

main() {
    export TOP_DIR=$(git rev-parse --show-toplevel)

    # Lint Python
    black --exclude ".*12-ci-cd/.*/*\.py" "${TOP_DIR}"

    # Remove trailing whitespaces
    find . -type f -name '*.sql' -exec sed --in-place 's/[[:space:]]\+$//' {} \+
    find . -type f -name '*.md' -exec sed --in-place 's/[[:space:]]\+$//' {} \+

    mdformat "${TOP_DIR}"

    # If the linter produce diffs, fail the linter
    if [ -z "$(git status --porcelain)" ]; then
        echo "Working directory clean, linting passed"
        exit 0
    else
        echo "Linting failed. Please commit these changes:"
        git --no-pager diff HEAD
        exit 1
    fi

}

main