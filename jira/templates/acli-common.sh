#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WINDOWS_BIN_DIR="$SKILL_DIR/bin/windows"
WINDOWS_BIN="$WINDOWS_BIN_DIR/acli.exe"
ACLI_BIN=""
JIRA_SITE="${JIRA_SITE:-${ACLI_JIRA_SITE:-}}"
QUIET="${QUIET:-0}"

log() {
  printf '%s\n' "$*" >&2
}

info() {
  if [ "$QUIET" -ne 1 ]; then
    log "$@"
  fi
}

is_windows_shell() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

detect_windows_arch() {
  case "${PROCESSOR_ARCHITECTURE:-$(uname -m)}" in
    ARM64|arm64|aarch64)
      printf '%s\n' "arm64"
      ;;
    *)
      printf '%s\n' "amd64"
      ;;
  esac
}

download_windows_acli() {
  local arch url
  arch="$(detect_windows_arch)"
  url="https://acli.atlassian.com/windows/latest/acli_windows_${arch}/acli.exe"

  mkdir -p "$WINDOWS_BIN_DIR"
  info "Downloading Atlassian CLI to $WINDOWS_BIN"

  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri '$url' -OutFile '$WINDOWS_BIN'" >/dev/null
    return 0
  fi

  if command -v curl.exe >/dev/null 2>&1; then
    curl.exe -fsSL "$url" -o "$WINDOWS_BIN"
    return 0
  fi

  log "Could not find powershell.exe or curl.exe to download Atlassian CLI."
  return 1
}

resolve_acli() {
  if command -v acli >/dev/null 2>&1; then
    ACLI_BIN="$(command -v acli)"
    return 0
  fi

  if is_windows_shell && [ -f "$WINDOWS_BIN" ]; then
    ACLI_BIN="$WINDOWS_BIN"
    return 0
  fi

  return 1
}

ensure_acli() {
  if resolve_acli; then
    return 0
  fi

  if is_windows_shell; then
    download_windows_acli
    ACLI_BIN="$WINDOWS_BIN"
    return 0
  fi

  log "Atlassian CLI is not installed. Ask the user for permission before installing it on this platform."
  return 1
}

auth_status() {
  ensure_acli
  "$ACLI_BIN" jira auth status
}

auth_status_quiet() {
  ensure_acli
  "$ACLI_BIN" jira auth status >/dev/null 2>&1
}

require_auth() {
  ensure_acli

  if auth_status_quiet; then
    return 0
  fi

  log "No Jira authentication is configured. Run '$ACLI_BIN jira auth login --web' and retry the original command."
  return 1
}

login_auth() {
  local login_args

  ensure_acli
  login_args=(jira auth login)

  if [ -n "$JIRA_SITE" ]; then
    login_args+=(--site "$JIRA_SITE")
  fi

  login_args+=(--web)
  info "Starting Jira web login${JIRA_SITE:+ for $JIRA_SITE}."
  "$ACLI_BIN" "${login_args[@]}" >/dev/null

  if ! auth_status_quiet; then
    log "Jira authentication did not complete successfully."
    return 1
  fi
}

ensure_ready() {
  ensure_acli
}

set_jira_site() {
  JIRA_SITE="$1"
}

set_quiet() {
  QUIET="$1"
}

run_acli() {
  ensure_acli
  require_auth
  "$ACLI_BIN" "$@"
}

run_acli_json() {
  local arg has_json
  has_json=0

  for arg in "$@"; do
    if [ "$arg" = "--json" ]; then
      has_json=1
      break
    fi
  done

  ensure_acli
  require_auth

  if [ "$has_json" -eq 1 ]; then
    "$ACLI_BIN" "$@"
  else
    "$ACLI_BIN" "$@" --json
  fi
}

require_arg() {
  local name value
  name="$1"
  value="$2"

  if [ -z "$value" ]; then
    log "Missing required argument: $name"
    return 1
  fi
}