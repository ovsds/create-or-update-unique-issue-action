#!/bin/bash

set -euo pipefail

function print_info() {
    local MESSAGE=$1
    echo "INFO: ${MESSAGE}"
}

function print_error() {
    local MESSAGE=$1
    echo "ERROR:: ${MESSAGE}"
}

function main() {
    GITHUB_REPOSITORY=${GITHUB_REPOSITORY:?"GITHUB_REPOSITORY is not set"}
    TITLE_PREFIX=${TITLE_PREFIX:?"TITLE_PREFIX is not set"}

    local ISSUE_NUMBERS
    # shellcheck disable=SC2016 # $ENV is expanded by jq, not by the shell
    ISSUE_NUMBERS="$(
        gh api --paginate "repos/${GITHUB_REPOSITORY}/issues?state=open&per_page=100" \
            --jq '.[] | select(.pull_request == null and (.title | startswith($ENV.TITLE_PREFIX))) | .number'
    )"

    local FAILED=0
    local ISSUE_NUMBER
    for ISSUE_NUMBER in ${ISSUE_NUMBERS}; do
        if gh api --method PATCH "repos/${GITHUB_REPOSITORY}/issues/${ISSUE_NUMBER}" -f state=closed --silent; then
            print_info "Closed issue #${ISSUE_NUMBER}"
        else
            print_error "Failed to close issue #${ISSUE_NUMBER}"
            FAILED=1
        fi
    done
    exit "${FAILED}"
}

main "$@"
