#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./acli-common.sh
source "$SCRIPT_DIR/acli-common.sh"

ensure_ready
run_acli --version
run_acli jira auth status