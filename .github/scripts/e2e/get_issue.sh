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

    local ISSUE
    ISSUE="$(gh api "repos/${GITHUB_REPOSITORY}/issues/${ISSUE_NUMBER}")"
    set_output "issue-title" "$(jq --raw-output '.title' <<<"${ISSUE}")"
    set_output "issue-body" "$(jq --raw-output '.body' <<<"${ISSUE}")"
    set_output "issue-state" "$(jq --raw-output '.state' <<<"${ISSUE}")"
    set_output "issue-state-reason" "$(jq --raw-output '.state_reason' <<<"${ISSUE}")"
}

main "$@"
