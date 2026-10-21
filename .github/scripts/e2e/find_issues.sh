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
    TITLE_INCLUDES=${TITLE_INCLUDES:?"TITLE_INCLUDES is not set"}

    local ISSUES
    # shellcheck disable=SC2016 # $ENV is expanded by jq, not by the shell
    ISSUES="$(
        gh api --paginate "repos/${GITHUB_REPOSITORY}/issues?state=all&per_page=100" \
            --jq '.[] | select(.pull_request == null and (.title | contains($ENV.TITLE_INCLUDES))) | .number' |
            jq --slurp --compact-output '.'
    )"
    set_output "issues" "${ISSUES}"
}

main "$@"
