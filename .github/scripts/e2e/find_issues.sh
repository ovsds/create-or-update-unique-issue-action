#!/bin/bash

set -euo pipefail

# shellcheck source-path=SCRIPTDIR source=../../../src/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../../../src/common.sh"

function main() {
    GITHUB_REPOSITORY=${GITHUB_REPOSITORY:?"GITHUB_REPOSITORY is not set"}
    TITLE_INCLUDES=${TITLE_INCLUDES:?"TITLE_INCLUDES is not set"}

    local ISSUES
    # shellcheck disable=SC2016 # $ENV is expanded by jq, not by the shell
    ISSUES="$(
        list_issue_numbers all '.title | contains($ENV.TITLE_INCLUDES)' |
            jq --slurp --compact-output '.'
    )"
    set_output "issues" "${ISSUES}"
}

main "$@"
