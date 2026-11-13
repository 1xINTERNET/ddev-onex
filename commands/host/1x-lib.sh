#!/usr/bin/env bash

## #ddev-generated
#
# Shared helper library for 1x DDEV host commands.
# Source this from any 1x-* command with:
#   source "${BASH_SOURCE%/*}/1x-lib.sh"
#
# No ## Usage: header, so DDEV will not register this as a command.

# Colors for printing messages.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BROWN='\033[0;33m'
NC='\033[0m' # No Color

# Cross-platform "sed"
sed_compat() {
  case "$OSTYPE" in
    darwin*)
      # BSD sed (macOS) needs '' after -i
      local args=()
      for arg in "$@"; do
        if [[ "$arg" == "-i" ]]; then
          args+=("-i" "")
        else
          args+=("$arg")
        fi
      done
      sed "${args[@]}"
      ;;
    linux*)
      sed "$@"
      ;;
    *)
      echo "sed_compat: unsupported platform: $OSTYPE" >&2
      return 1
      ;;
  esac
}

# Cross-platform "date"
date_compat() {
  case "$OSTYPE" in
    darwin*)
      # BSD date (macOS) lacks GNU extensions
      if command -v gdate >/dev/null 2>&1; then
        gdate "$@"
      else
        date "$@"
      fi
      ;;
    linux*)
      date "$@"
      ;;
    *)
      echo "date_compat: unsupported platform: $OSTYPE" >&2
      return 1
      ;;
  esac
}

# Cross-platform "open"
open_compat() {
  case "$OSTYPE" in
    darwin*)
      open "$@"
      ;;
    linux*)
      xdg-open "$@"
      ;;
    *)
      echo "open_compat: unsupported platform: $OSTYPE" >&2
      return 1
      ;;
  esac
}

# Cross-platform "jq"
jq_compat() {
  if command -v jq >/dev/null 2>&1; then
    jq "$@"
  elif command -v docker >/dev/null 2>&1; then
    # Pull quietly first: docker's "Pulling image..." output would otherwise end up in the result.
    docker image inspect ghcr.io/jqlang/jq >/dev/null 2>&1 || docker pull -q ghcr.io/jqlang/jq >/dev/null 2>&1 || true
    # The container sees no local files: pass data on stdin or as --arg/--argjson, never as file arguments.
    docker run --rm -i ghcr.io/jqlang/jq "$@"
  else
    echo "Error: jq not found and docker is not available. Please install jq or docker." >&2
    return 1
  fi
}

# Cross-platform "yq" (mikefarah/yq v4). Uses the host binary when it is mikefarah's, otherwise docker.
# Files are resolved relative to the current directory, which is mounted as /workdir; stdin works too.
YQ_IMAGE="${YQ_IMAGE:-mikefarah/yq:4.54.3}"
yq_compat() {
  if command -v yq >/dev/null 2>&1 && yq --version 2>&1 | grep -q mikefarah; then
    yq "$@"
  elif command -v docker >/dev/null 2>&1; then
    docker run --rm -i --user "$(id -u):$(id -g)" -v "${PWD}:/workdir" -w /workdir "${YQ_IMAGE}" "$@"
  else
    echo "Error: yq (mikefarah) not found and docker is not available. Please install yq or docker." >&2
    return 1
  fi
}
