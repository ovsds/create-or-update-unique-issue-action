# shellcheck shell=bash
# Functions shared by the e2e scripts, sourced by each of them.

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

# Print the numbers of the issues (not PRs) in STATE whose fields match the jq CONDITION,
# e.g. `.title | contains($ENV.TITLE_INCLUDES)`; jq reads the environment through $ENV.
function list_issue_numbers() {
    GITHUB_REPOSITORY=${GITHUB_REPOSITORY:?"GITHUB_REPOSITORY is not set"}

    local STATE=$1
    local CONDITION=$2

    gh api --paginate "repos/${GITHUB_REPOSITORY}/issues?state=${STATE}&per_page=100" \
        --jq ".[] | select(.pull_request == null and (${CONDITION})) | .number"
}
