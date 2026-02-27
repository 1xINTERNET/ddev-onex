#!/usr/bin/env bash
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
