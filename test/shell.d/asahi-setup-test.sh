#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-mac-setup"

call_next_step() {
  bash -c '
    # shellcheck source=/dev/null
    source "$1"
    shift
    next_step "$@"
  ' -- "$setup" "$@"
}

tools_ok() {
  bash -c '
    source "$1" >/dev/null
    require_tools_present "$2" >/dev/null 2>&1
  ' -- "$setup" "$1"
}

step_is() {
  local expected="$1"
  shift
  local actual
  actual=$(call_next_step "$@")
  [[ $actual == "$expected" ]] ||
    fail "[boot=$1 crypt=$2 want=$3 installed=$4] → $expected" "got $actual"
  pass "[boot=$1 crypt=$2 want=$3 installed=$4] → $actual"
}

step_is boot-layout 0 0 1 0
step_is encrypt 1 0 1 0
step_is omarchy 1 1 1 0
step_is done 1 1 1 1

step_is omarchy 0 0 0 0
step_is omarchy 1 0 0 0
step_is done 0 0 0 1

step_is omarchy 0 1 1 0
step_is done 1 1 1 1

step_is done 0 0 1 1
step_is done 0 1 0 1

for want in 0 1; do
  for installed in 0 1; do
    result=$(call_next_step 0 0 "$want" "$installed")
    [[ $result != "encrypt" ]] ||
      fail "encrypt reached with /boot on root (want=$want installed=$installed)"
    pass "no encrypt with /boot on root (want=$want installed=$installed) → $result"
  done
done

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

tools_ok "$work" && fail "an empty checkout is refused" || pass "an empty checkout is refused"

touch "$work/bin/omarchy-system-boot-to-esp"
tools_ok "$work" && fail "half the tools is still refused" || pass "half the tools is still refused"

touch "$work/bin/omarchy-system-btrfs-migrate"
tools_ok "$work" || fail "both tools are accepted"
pass "both tools are accepted"

grep -q '^DEFAULT_REPO=basecamp/omarchy$' "$setup" ||
  fail "setup clones official omarchy by default"
pass "setup clones official omarchy by default"

grep -q '^DEFAULT_FORGE=github.com$' "$setup" ||
  fail "setup uses GitHub by default"
pass "setup uses GitHub by default"
