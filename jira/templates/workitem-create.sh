#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./acli-common.sh
source "$SCRIPT_DIR/acli-common.sh"

usage() {
  cat <<'EOF'
Usage:
  ./workitem-create.sh --project TEAM --type Task --summary "Investigate flaky test" [options]
  ./workitem-create.sh --from-json workitem.json

Options:
  --project KEY
  --type TYPE
  --summary TEXT
  --description TEXT
  --description-file PATH
  --assignee USER
  --labels LABELS
  --parent KEY
  --from-json PATH
EOF
}

project=""
work_type=""
summary=""
description=""
description_file=""
assignee=""
labels=""
parent=""
from_json=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project)
      project="${2:-}"
      shift 2
      ;;
    --type)
      work_type="${2:-}"
      shift 2
      ;;
    --summary)
      summary="${2:-}"
      shift 2
      ;;
    --description)
      description="${2:-}"
      shift 2
      ;;
    --description-file)
      description_file="${2:-}"
      shift 2
      ;;
    --assignee)
      assignee="${2:-}"
      shift 2
      ;;
    --labels)
      labels="${2:-}"
      shift 2
      ;;
    --parent)
      parent="${2:-}"
      shift 2
      ;;
    --from-json)
      from_json="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

args=(jira workitem create)

if [ -n "$from_json" ]; then
  args+=(--from-json "$from_json")
else
  require_arg "project" "$project"
  require_arg "type" "$work_type"
  require_arg "summary" "$summary"

  args+=(--project "$project" --type "$work_type" --summary "$summary")

  if [ -n "$description" ]; then
    args+=(--description "$description")
  fi

  if [ -n "$description_file" ]; then
    args+=(--description-file "$description_file")
  fi

  if [ -n "$assignee" ]; then
    args+=(--assignee "$assignee")
  fi

  if [ -n "$labels" ]; then
    args+=(--label "$labels")
  fi

  if [ -n "$parent" ]; then
    args+=(--parent "$parent")
  fi
fi

run_acli_json "${args[@]}"