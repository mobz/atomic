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
    printf '{"state":"%s","spec_intent":"%s","progress":"%d/%d","atomic_dir":"%s","behaviours_dir":"%s"}\n' \
      "$state" \
      "${spec_summary//\"/\\\"}" \
      "$checked" "$total" \
      "$ATOMIC_DIR" \
      "$BEHAVIOURS_DIR"
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

# Snapshot the whole working tree (tracked changes, untracked files, spec.md;
# .gitignore respected, as with `atomic commit`) to a commit on top of HEAD that
# no branch, tag, or stash points at — git gc prunes it once it expires. Then
# revert every path except the given keep paths: tracked files back to HEAD,
# and files the snapshot added deleted. Only files held by the snapshot are
# deleted, so everything discarded is recoverable from it.
# Usage: snapshot_and_revert <message> [keep-path...]
# Prints the snapshot SHA, or nothing if the working tree matches HEAD.
snapshot_and_revert() {
  local message="$1"; shift
  local keep=("$@") excludes=() k

  for k in "${keep[@]+"${keep[@]}"}"; do
    excludes+=(":!$k")
  done

  local tmp_index tree sha
  tmp_index=$(mktemp -u)
  GIT_INDEX_FILE="$tmp_index" git read-tree HEAD
  GIT_INDEX_FILE="$tmp_index" git add -A
  tree=$(GIT_INDEX_FILE="$tmp_index" git write-tree)
  rm -f "$tmp_index"

  [[ "$tree" == "$(git rev-parse 'HEAD^{tree}')" ]] && return 0

  sha=$(git commit-tree "$tree" -p HEAD -m "$message")

  git restore --source=HEAD --staged --worktree -- . "${excludes[@]+"${excludes[@]}"}"

  local f
  while IFS= read -r f; do
    for k in "${keep[@]+"${keep[@]}"}"; do
      [[ "$f" == "$k" ]] && continue 2
    done
    rm -f "$f"
    rmdir -p "$(dirname "$f")" 2>/dev/null || true
  done < <(git diff --name-only --diff-filter=A HEAD "$sha")

  echo "$sha"
}
