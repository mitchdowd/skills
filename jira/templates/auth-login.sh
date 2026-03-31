#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./acli-common.sh
source "$SCRIPT_DIR/acli-common.sh"

while [ "$#" -gt 0 ]; do
	case "$1" in
		--site)
			require_arg "site" "${2:-}"
			set_jira_site "$2"
			shift 2
			;;
		--quiet)
			set_quiet 1
			shift
			;;
		*)
			printf 'Unknown argument: %s\n' "$1" >&2
			exit 1
			;;
	esac
done

ensure_acli
login_auth

if [ "$QUIET" -ne 1 ]; then
	printf 'Jira auth ready.\n'
fi