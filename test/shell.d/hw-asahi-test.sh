#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

hw_asahi() {
  OMARCHY_DEVICE_TREE_COMPATIBLE="$1" "$ROOT/bin/omarchy-hw-asahi"
}

missing="$tmp_dir/missing"
hw_asahi "$missing" && fail "missing device-tree is not Asahi" || pass "missing device-tree is not Asahi"

printf 'linux,dummy\0arm,dummy\n' >"$tmp_dir/other"
hw_asahi "$tmp_dir/other" && fail "non-Apple device-tree is not Asahi" || pass "non-Apple device-tree is not Asahi"

printf 'apple,j293\0apple,t8103\n' >"$tmp_dir/m1"
hw_asahi "$tmp_dir/m1" || fail "M1 MacBook Pro device-tree is Asahi"
pass "M1 MacBook Pro device-tree is Asahi"

printf 'apple,j314s\0apple,t6000\n' >"$tmp_dir/m1pro"
hw_asahi "$tmp_dir/m1pro" || fail "M1 Pro device-tree is Asahi"
pass "M1 Pro device-tree is Asahi"
