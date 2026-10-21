#!/bin/bash

set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=../../../src/main.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../../src/main.sh"

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
