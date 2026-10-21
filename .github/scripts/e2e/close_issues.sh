#!/bin/bash

set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=../../../src/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../../src/common.sh"

function main() {
    GITHUB_REPOSITORY=${GITHUB_REPOSITORY:?"GITHUB_REPOSITORY is not set"}
    TITLE_PREFIX=${TITLE_PREFIX:?"TITLE_PREFIX is not set"}

    local ISSUE_NUMBERS
    # shellcheck disable=SC2016 # $ENV is expanded by jq, not by the shell
    ISSUE_NUMBERS="$(list_issue_numbers open '.title | startswith($ENV.TITLE_PREFIX)')"

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
