#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hooks_conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/nopci" "$tmp_dir/asahi-machine" "$tmp_dir/x86-machine"
touch "$tmp_dir/asahi-machine/asahi"

hooks_with() {
  local initcpio="$1"

  OMARCHY_INITCPIO_INSTALL_PATH="$initcpio" \
    OMARCHY_PCI_DEVICES_PATH="$tmp_dir/nopci" \
    bash -uc "
      FILES=()
      XKBLAYOUT=us
      MODULES=()
      source '$hooks_conf'
      echo \"\${HOOKS[*]}\"
    "
}

asahi=$(hooks_with "$tmp_dir/asahi-machine")
x86=$(hooks_with "$tmp_dir/x86-machine")

[[ $asahi == *" asahi "* ]] || fail "asahi is in the list" "actual: $asahi"
pass "asahi is in the list"

[[ $asahi == base\ asahi\ * ]] || fail "asahi sits directly after base" "actual: $asahi"
pass "asahi sits directly after base"

count=$(grep -o 'asahi' <<<"$asahi" | wc -l | tr -d ' ')
[[ $count == "1" ]] || fail "asahi appears exactly once" "count: $count"
pass "asahi appears exactly once"

[[ $x86 != *asahi* ]] || fail "no asahi where the hook is not installed" "actual: $x86"
pass "no asahi where the hook is not installed"

[[ ${asahi/asahi /} == "$x86" ]] ||
  fail "the list is otherwise the same" $'asahi: '"$asahi"$'\nx86: '"$x86"
pass "the list is otherwise the same"

for hook in base udev encrypt filesystems keyboard block; do
  [[ $asahi == *" $hook "* || $asahi == "$hook "* || $asahi == *" $hook" ]] ||
    fail "$hook survives" "actual: $asahi"
  pass "$hook survives"
done

# Asahi without limine-snapper-sync must not keep a hook mkinitcpio cannot find.
[[ $asahi != *btrfs-overlayfs* ]] ||
  fail "asahi without btrfs-overlayfs drops the hook" "actual: $asahi"
pass "asahi without btrfs-overlayfs drops the hook"

mkdir -p "$tmp_dir/asahi-with-overlay"
touch "$tmp_dir/asahi-with-overlay/asahi" "$tmp_dir/asahi-with-overlay/btrfs-overlayfs"
with_overlay=$(hooks_with "$tmp_dir/asahi-with-overlay")
[[ $with_overlay == *btrfs-overlayfs* ]] ||
  fail "asahi keeps btrfs-overlayfs when the hook is installed" "actual: $with_overlay"
pass "asahi keeps btrfs-overlayfs when the hook is installed"
