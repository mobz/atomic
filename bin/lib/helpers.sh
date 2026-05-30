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

# Count checked and unchecked items in spec.md
spec_counts() {
  local unchecked=0 checked=0
  if [[ -f "$ATOMIC_DIR/spec.md" ]]; then
    unchecked=$(grep -c '^- \[ \]' "$ATOMIC_DIR/spec.md" 2>/dev/null || true)
    checked=$(grep -c '^- \[X\]' "$ATOMIC_DIR/spec.md" 2>/dev/null || true)
    unchecked=${unchecked:-0}
    checked=${checked:-0}
  fi
  echo "$checked $unchecked"
}

# Derive pipeline state from spec.md existence and checkbox state
spec_state() {
  if [[ ! -f "$ATOMIC_DIR/spec.md" ]]; then
    echo "none"
    return
  fi
  local counts checked unchecked
  counts=$(spec_counts)
  checked=${counts% *}
  unchecked=${counts#* }
  local total=$((checked + unchecked))
  if [[ $total -eq 0 ]] || [[ $unchecked -eq $total ]]; then
    echo "proposed"
  elif [[ $unchecked -eq 0 ]]; then
    echo "ready"
  else
    echo "applying"
  fi
}

output_json() {
  local state
  state=$(spec_state)
  local spec_summary="" checked=0 unchecked=0
  if [[ -f "$ATOMIC_DIR/spec.md" ]]; then
    spec_summary=$(grep -m1 '^\*\*Intent:\*\*' "$ATOMIC_DIR/spec.md" 2>/dev/null | sed 's/\*\*Intent:\*\* //' || echo "")
    local counts
    counts=$(spec_counts)
    checked=${counts% *}
    unchecked=${counts#* }
  fi
  local total=$((checked + unchecked))

  if [[ "$JSON_OUTPUT" == "true" ]]; then
    printf '{"state":"%s","spec_intent":"%s","progress":"%d/%d","atomic_dir":"%s","specs_dir":"%s"}\n' \
      "$state" \
      "${spec_summary//\"/\\\"}" \
      "$checked" "$total" \
      "$ATOMIC_DIR" \
      "$SPECS_DIR"
  else
    echo "State:   $state"
    if [[ -n "$spec_summary" ]]; then
      echo "Intent:  $spec_summary"
    fi
    if [[ $total -gt 0 ]]; then
      echo "Progress: $checked/$total changes complete"
    fi
  fi
}
