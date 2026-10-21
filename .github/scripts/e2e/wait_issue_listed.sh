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

function set_output() {
    GITHUB_OUTPUT=${GITHUB_OUTPUT:?"GITHUB_OUTPUT is not set"}

    local KEY=$1
    local VALUE=$2

    print_info "Setting output: ${KEY}=${VALUE}"
    {
        echo "${KEY}<<EOF"
        echo "${VALUE}"
        echo "EOF"
    } >> "${GITHUB_OUTPUT}"
}

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
        if LISTED_NUMBERS="$(
            gh api --paginate "repos/${GITHUB_REPOSITORY}/issues?state=open&per_page=100" \
                --jq '.[] | select(.number == ($ENV.ISSUE_NUMBER | tonumber)) | .number'
        )"; then
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
