#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./acli-common.sh
source "$SCRIPT_DIR/acli-common.sh"

usage() {
  cat <<'EOF'
Usage:
  ./workitem-update.sh view KEY [fields]
  ./workitem-update.sh assign KEY ASSIGNEE
  ./workitem-update.sh comment-create KEY BODY
  ./workitem-update.sh comment-list KEY
  ./workitem-update.sh attachment-list KEY
  ./workitem-update.sh link KEY OTHER_KEY TYPE
  ./workitem-update.sh link-list KEY
  ./workitem-update.sh transition KEY STATUS
  ./workitem-update.sh clone KEY TO_PROJECT
  ./workitem-update.sh edit KEY [--summary TEXT] [--description TEXT] [--labels CSV] [--assignee USER] [--from-json PATH]
EOF
}

mode="${1:-}"

if [ -z "$mode" ]; then
  usage >&2
  exit 1
fi

shift

case "$mode" in
  view)
    key="${1:-}"
    fields="${2:-}"
    require_arg "key" "$key"
    if [ -n "$fields" ]; then
      run_acli_json jira workitem view "$key" --fields "$fields"
    else
      run_acli_json jira workitem view "$key"
    fi
    ;;
  assign)
    key="${1:-}"
    assignee="${2:-}"
    require_arg "key" "$key"
    require_arg "assignee" "$assignee"
    run_acli_json jira workitem assign --key "$key" --assignee "$assignee"
    ;;
  comment-create)
    key="${1:-}"
    body="${2:-}"
    require_arg "key" "$key"
    require_arg "body" "$body"
    run_acli_json jira workitem comment create --key "$key" --body "$body"
    ;;
  comment-list)
    key="${1:-}"
    require_arg "key" "$key"
    run_acli_json jira workitem comment list --key "$key"
    ;;
  attachment-list)
    key="${1:-}"
    require_arg "key" "$key"
    run_acli_json jira workitem attachment list --key "$key"
    ;;
  link)
    outward_key="${1:-}"
    inward_key="${2:-}"
    link_type="${3:-}"
    require_arg "outward key" "$outward_key"
    require_arg "inward key" "$inward_key"
    require_arg "link type" "$link_type"
    run_acli jira workitem link create --out "$outward_key" --in "$inward_key" --type "$link_type"
    ;;
  link-list)
    key="${1:-}"
    require_arg "key" "$key"
    run_acli_json jira workitem link list --key "$key"
    ;;
  transition)
    key="${1:-}"
    status="${2:-}"
    require_arg "key" "$key"
    require_arg "status" "$status"
    run_acli_json jira workitem transition --key "$key" --status "$status"
    ;;
  clone)
    key="${1:-}"
    to_project="${2:-}"
    require_arg "key" "$key"
    require_arg "to project" "$to_project"
    run_acli_json jira workitem clone --key "$key" --to-project "$to_project"
    ;;
  edit)
    key="${1:-}"
    require_arg "key" "$key"
    shift

    summary=""
    description=""
    labels=""
    assignee=""
    from_json=""
    args=(jira workitem edit --key "$key")

    while [ "$#" -gt 0 ]; do
      case "$1" in
        --summary)
          summary="${2:-}"
          args+=(--summary "$summary")
          shift 2
          ;;
        --description)
          description="${2:-}"
          args+=(--description "$description")
          shift 2
          ;;
        --labels)
          labels="${2:-}"
          args+=(--labels "$labels")
          shift 2
          ;;
        --assignee)
          assignee="${2:-}"
          args+=(--assignee "$assignee")
          shift 2
          ;;
        --from-json)
          from_json="${2:-}"
          args+=(--from-json "$from_json")
          shift 2
          ;;
        -h|--help)
          usage
          exit 0
          ;;
        *)
          printf 'Unknown edit argument: %s\n' "$1" >&2
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