#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./acli-common.sh
source "$SCRIPT_DIR/acli-common.sh"

JQL="${1:-}"
FIELDS="${2:-issuetype,key,assignee,priority,status,summary}"
LIMIT="${3:-50}"

require_arg "jql" "$JQL"

run_acli_json jira workitem search --jql "$JQL" --fields "$FIELDS" --limit "$LIMIT"