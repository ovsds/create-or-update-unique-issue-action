#!/bin/bash

set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=../../../src/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../../src/common.sh"

function main() {
    GITHUB_REPOSITORY=${GITHUB_REPOSITORY:?"GITHUB_REPOSITORY is not set"}
    ISSUE_NUMBER=${ISSUE_NUMBER:?"ISSUE_NUMBER is not set"}
    LISTED=${LISTED:?"LISTED is not set"}

    # The open issue list lags behind issue changes, and one read can hit an up-to-date replica
    # while the next one does not, so only several matching reads in a row count.
    local REQUIRED_MATCHES=3
    local TIMEOUT_SECONDS=60
    local MATCHES=0
    local DEADLINE=$((SECONDS + TIMEOUT_SECONDS))
    local LISTED_NUMBERS
    local ACTUAL_LISTED
    while [ "${SECONDS}" -lt "${DEADLINE}" ]; do
        # shellcheck disable=SC2016 # $ENV is expanded by jq, not by the shell
        if LISTED_NUMBERS="$(list_issue_numbers open '.number == ($ENV.ISSUE_NUMBER | tonumber)')"; then
            ACTUAL_LISTED="false"
            if [ -n "${LISTED_NUMBERS}" ]; then ACTUAL_LISTED="true"; fi
            if [ "${ACTUAL_LISTED}" = "${LISTED}" ]; then
                MATCHES=$((MATCHES + 1))
                if [ "${MATCHES}" -ge "${REQUIRED_MATCHES}" ]; then
                    print_info "Issue #${ISSUE_NUMBER} listed is ${LISTED} on ${REQUIRED_MATCHES} reads in a row"
                    return
                fi
            else
                print_info "Issue #${ISSUE_NUMBER} listed is not ${LISTED} yet"
                MATCHES=0
            fi
        else
            print_info "Reading the open issue list failed, retrying"
            MATCHES=0
        fi
        sleep 2
    done
    print_error "Issue #${ISSUE_NUMBER} listed is not ${LISTED} on ${REQUIRED_MATCHES} reads in a row in ${TIMEOUT_SECONDS} seconds"
    exit 1
}

main "$@"
