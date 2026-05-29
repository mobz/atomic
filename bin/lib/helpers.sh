#!/usr/bin/env bash
# Shared utilities for all atomic subcommands.
# Sourced by bin/atomic before any command file.

in_git_repo() {
  git rev-parse --git-dir &>/dev/null
}

require_git() {
  if ! in_git_repo; then
    echo '{"error":"not in a git repository"}' >&2
    exit 1
  fi
}

require_atomic_dir() {
  if [[ ! -d "$ATOMIC_DIR" ]]; then
    mkdir -p "$ATOMIC_DIR"
  fi
}

read_ref() {
  local ref="$1"
  local sha
  sha=$(git for-each-ref --format='%(objectname)' "$ref" 2>/dev/null || true)
  if [[ -z "$sha" ]]; then
    echo ""
    return
  fi
  git cat-file blob "$sha" 2>/dev/null || echo ""
}

# Read a working file, falling back to its git ref if the file is absent.
# Prints contents (possibly empty) to stdout.
read_atomic_file() {
  local file="$1"
  local ref="$2"
  if [[ -f "$file" ]]; then
    cat "$file"
    return 0
  fi
  local content
  content=$(read_ref "$ref")
  echo "$content"
}

current_stage() {
  read_ref "$REFS_PREFIX/stage"
}

output_json() {
  local stage
  stage=$(current_stage)
  local spec_summary=""
  if [[ -f "$ATOMIC_DIR/spec.md" ]]; then
    spec_summary=$(grep -m1 '^\*\*Intent:\*\*' "$ATOMIC_DIR/spec.md" 2>/dev/null | sed 's/\*\*Intent:\*\* //' || echo "")
  fi

  if [[ "$JSON_OUTPUT" == "true" ]]; then
    printf '{"stage":"%s","spec_intent":"%s","atomic_dir":"%s","specs_dir":"%s"}\n' \
      "${stage:-none}" \
      "${spec_summary//\"/\\\"}" \
      "$ATOMIC_DIR" \
      "$SPECS_DIR"
  else
    echo "Stage:   ${stage:-none}"
    if [[ -n "$spec_summary" ]]; then
      echo "Intent:  $spec_summary"
    fi
  fi
}
