#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./acli-common.sh
source "$SCRIPT_DIR/acli-common.sh"

usage() {
  cat <<'EOF'
Usage:
  ./resource-inspect.sh project-list [limit]
  ./resource-inspect.sh project-view KEY
  ./resource-inspect.sh project-create --from-project SRC --key NEW --name "New Project"
  ./resource-inspect.sh board-search [--project KEY] [--name TEXT] [--type scrum|kanban|simple]
  ./resource-inspect.sh board-list-sprints BOARD_ID [state]
  ./resource-inspect.sh sprint-list-workitems BOARD_ID SPRINT_ID [fields]
  ./resource-inspect.sh filter-list my|favourite
  ./resource-inspect.sh filter-search [--name TEXT] [--owner EMAIL] [--limit N]
EOF
}

mode="${1:-}"

if [ -z "$mode" ]; then
  usage >&2
  exit 1
fi

shift

case "$mode" in
  project-list)
    limit="${1:-30}"
    run_acli_json jira project list --limit "$limit"
    ;;
  project-view)
    key="${1:-}"
    require_arg "key" "$key"
    run_acli_json jira project view --key "$key"
    ;;
  project-create)
    args=(jira project create)
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --from-project|--key|--name|--description|--lead-email|--url|--from-json)
          args+=("$1" "${2:-}")
          shift 2
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          printf 'Unknown project-create argument: %s\n' "$1" >&2
          usage >&2
          exit 1
          ;;
      esac
    done
    run_acli "${args[@]}"
    ;;
  board-search)
    args=(jira board search)
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --project|--name|--type|--filter|--limit|--orderBy)
          args+=("$1" "${2:-}")
          shift 2
          ;;
        --paginate|--private)
          args+=("$1")
          shift
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          printf 'Unknown board-search argument: %s\n' "$1" >&2
          usage >&2
          exit 1
          ;;
      esac
    done
    run_acli_json "${args[@]}"
    ;;
  board-list-sprints)
    board_id="${1:-}"
    state="${2:-}"
    require_arg "board id" "$board_id"
    if [ -n "$state" ]; then
      run_acli_json jira board list-sprints --id "$board_id" --state "$state"
    else
      run_acli_json jira board list-sprints --id "$board_id"
    fi
    ;;
  sprint-list-workitems)
    board_id="${1:-}"
    sprint_id="${2:-}"
    fields="${3:-key,issuetype,summary,assignee,priority,status}"
    require_arg "board id" "$board_id"
    require_arg "sprint id" "$sprint_id"
    run_acli_json jira sprint list-workitems --board "$board_id" --sprint "$sprint_id" --fields "$fields"
    ;;
  filter-list)
    scope="${1:-my}"
    case "$scope" in
      my)
        run_acli_json jira filter list --my
        ;;
      favourite)
        run_acli_json jira filter list --favourite
        ;;
      *)
        printf 'Unknown filter-list scope: %s\n' "$scope" >&2
        usage >&2
        exit 1
        ;;
    esac
    ;;
  filter-search)
    args=(jira filter search)
    while [ "$#" -gt 0 ]; do
      case "$1" in
        --name|--owner|--limit)
          args+=("$1" "${2:-}")
          shift 2
          ;;
        --paginate)
          args+=("$1")
          shift
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          printf 'Unknown filter-search argument: %s\n' "$1" >&2
          usage >&2
          exit 1
          ;;
      esac
    done
    run_acli_json "${args[@]}"
    ;;
  -h|--help)
    usage
    ;;
  *)
    printf 'Unknown mode: %s\n' "$mode" >&2
    usage >&2
    exit 1
    ;;
esac