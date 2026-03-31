#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WINDOWS_BIN_DIR="$SKILL_DIR/bin/windows"
WINDOWS_BIN="$WINDOWS_BIN_DIR/acli.exe"
ACLI_BIN=""

log() {
  printf '%s\n' "$*" >&2
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
  log "Downloading Atlassian CLI to $WINDOWS_BIN"

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

ensure_auth() {
  if "$ACLI_BIN" jira auth status >/dev/null 2>&1; then
    return 0
  fi

  log "No Jira authentication is configured. Starting interactive login."
  "$ACLI_BIN" jira auth login
  "$ACLI_BIN" jira auth status >/dev/null
}

ensure_ready() {
  ensure_acli
  ensure_auth
}

run_acli() {
  ensure_ready
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

  ensure_ready

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