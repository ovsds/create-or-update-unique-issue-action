#!/bin/bash

set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

function find_issue() {
    # shellcheck disable=SC2016 # $ENV is expanded by jq, not by the shell
    list_issue_numbers open '.title | contains($ENV.INPUT_UNIQUE_TITLE_INCLUDES)' | sed -n '1p'
}

function create_issue() {
    gh api "repos/${GITHUB_REPOSITORY}/issues" -f "title=${INPUT_TITLE}" -f "body=${INPUT_BODY}" --jq '.number'
}

function update_issue() {
    local ISSUE_NUMBER=$1

    local ARGS=(--method PATCH --silent)
    if [ -n "${INPUT_TITLE}" ]; then ARGS+=(-f "title=${INPUT_TITLE}"); fi
    if [ -n "${INPUT_BODY}" ]; then ARGS+=(-f "body=${INPUT_BODY}"); fi
    gh api "repos/${GITHUB_REPOSITORY}/issues/${ISSUE_NUMBER}" "${ARGS[@]}"
}

function close_issue() {
    local ISSUE_NUMBER=$1

    gh api --method PATCH "repos/${GITHUB_REPOSITORY}/issues/${ISSUE_NUMBER}" \
        -f state=closed -f state_reason=not_planned --silent
}

function main() {
    GITHUB_REPOSITORY=${GITHUB_REPOSITORY:?"GITHUB_REPOSITORY is not set"}
    # Empty values are valid: an empty title skips creation, an empty title or body keeps the current one.
    INPUT_TITLE=${INPUT_TITLE?"INPUT_TITLE is not set"}
    INPUT_BODY=${INPUT_BODY?"INPUT_BODY is not set"}
    INPUT_UNIQUE_TITLE_INCLUDES=${INPUT_UNIQUE_TITLE_INCLUDES?"INPUT_UNIQUE_TITLE_INCLUDES is not set"}
    INPUT_CLOSE=${INPUT_CLOSE?"INPUT_CLOSE is not set"}
    # Expressions compared `close` to 'true' ignoring case
    INPUT_CLOSE="$(tr '[:upper:]' '[:lower:]' <<<"${INPUT_CLOSE}")"

    local ISSUE_NUMBER
    ISSUE_NUMBER="$(find_issue)"

    if [ -z "${ISSUE_NUMBER}" ]; then
        if [ "${INPUT_CLOSE}" = "true" ]; then
            print_info "Issue not found, nothing to close"
        elif [ -z "${INPUT_TITLE}" ]; then
            echo "::warning::Issue title is empty, skipping issue creation"
        else
            ISSUE_NUMBER="$(create_issue)"
            print_info "Created issue #${ISSUE_NUMBER}"
        fi
    else
        update_issue "${ISSUE_NUMBER}"
        print_info "Updated issue #${ISSUE_NUMBER}"
        if [ "${INPUT_CLOSE}" = "true" ]; then
            close_issue "${ISSUE_NUMBER}"
            print_info "Closed issue #${ISSUE_NUMBER}"
        fi
    fi

    set_output "issue-number" "${ISSUE_NUMBER}"
}

main "$@"
